using System;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Users.Commands.Update;

public class UpdateUserCommandHandler : ICommandHandler<UpdateUserCommand>
{
    private readonly DentisteContext _context;

    public UpdateUserCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result> Handle(UpdateUserCommand request, CancellationToken cancellationToken)
    {
        var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == request.Id, cancellationToken);
        if (user == null)
        {
            return Result.Failure(Errors.UserNotFound);
        }

        var roleExists = await _context.Roles.AnyAsync(r => r.Id == request.RoleId, cancellationToken);
        if (!roleExists)
        {
            return Result.Failure(Errors.RoleNotFound);
        }

        if (user.Username != request.Username)
        {
            var usernameExists = await _context.Users.AnyAsync(u => u.Username == request.Username && u.Id != request.Id, cancellationToken);
            if (usernameExists)
            {
                return Result.Failure(Errors.UsernameAlreadyExists);
            }
        }

        if (user.Email != request.Email)
        {
            var emailExists = await _context.Users.AnyAsync(u => u.Email == request.Email && u.Id != request.Id, cancellationToken);
            if (emailExists)
            {
                return Result.Failure(Errors.EmailAlreadyExists);
            }
        }

        user.Username = request.Username;
        user.Email = request.Email;
        user.Nom = request.Nom;
        user.Prenom = request.Prenom;
        user.IsActive = request.IsActive;
        user.RoleId = request.RoleId;

        if (!string.IsNullOrWhiteSpace(request.Password))
        {
            var salt = Guid.NewGuid().ToString("N");
            user.PasswordSalt = salt;
            user.PasswordHash = HashPassword(request.Password, salt);
        }

        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success();
    }

    private static string HashPassword(string password, string salt)
    {
        using var sha256 = SHA256.Create();
        var saltedPassword = password + salt;
        var bytes = Encoding.UTF8.GetBytes(saltedPassword);
        var hash = sha256.ComputeHash(bytes);
        return Convert.ToBase64String(hash);
    }
}
