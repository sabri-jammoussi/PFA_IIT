using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Infrastructure.Security;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;
using Dentiste.Data.Models;

namespace Dentiste.Core.Features.Users.Commands.Add;

public class AddUserCommandHandler : ICommandHandler<AddUserCommand, int>
{
    private readonly DentisteContext _context;
    private readonly IPasswordHasher _passwordHasher;

    public AddUserCommandHandler(DentisteContext context, IPasswordHasher passwordHasher)
    {
        _context = context;
        _passwordHasher = passwordHasher;
    }

    public async Task<Result<int>> Handle(AddUserCommand request, CancellationToken cancellationToken)
    {
        var roleExists = await _context.Roles.AnyAsync(r => r.Id == request.RoleId, cancellationToken);
        if (!roleExists)
        {
            return Result.Failure<int>(Errors.RoleNotFound);
        }

        var usernameExists = await _context.Users.AnyAsync(u => u.Username == request.Username, cancellationToken);
        if (usernameExists)
        {
            return Result.Failure<int>(Errors.UsernameAlreadyExists);
        }

        var emailExists = await _context.Users.AnyAsync(u => u.Email == request.Email, cancellationToken);
        if (emailExists)
        {
            return Result.Failure<int>(Errors.EmailAlreadyExists);
        }

        // Generate salt and hash using the shared IPasswordHasher
        var salt = Guid.NewGuid().ToString("N");
        var passwordHash = _passwordHasher.Hash(request.Password, salt);

        var user = new UserDao
        {
            Username = request.Username,
            Email = request.Email,
            PasswordHash = passwordHash,
            PasswordSalt = salt,
            Nom = request.Nom,
            Prenom = request.Prenom,
            IsActive = true,
            RoleId = request.RoleId,
            CreatedAt = DateTime.UtcNow
        };

        _context.Users.Add(user);
        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success(user.Id);
    }
}

