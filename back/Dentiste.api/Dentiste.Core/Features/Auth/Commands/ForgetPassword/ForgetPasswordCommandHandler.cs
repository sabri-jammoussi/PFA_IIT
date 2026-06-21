using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;
using Microsoft.EntityFrameworkCore;
using System.Text.RegularExpressions;

using Dentiste.Core.Infrastructure.Security;

namespace Dentiste.Core.Features.Auth.Commands.ForgetPassword;

public class ForgetPasswordCommandHandler : ICommandHandler<ForgetPasswordCommand>
{
    private readonly DentisteContext _context;
    private readonly IPasswordHasher _passwordHasher;

    public ForgetPasswordCommandHandler(DentisteContext context, IPasswordHasher passwordHasher)
    {
        _context = context;
        _passwordHasher = passwordHasher;
    }

    public async Task<Result> Handle(ForgetPasswordCommand request, CancellationToken cancellationToken)
    {
        var credential = request.MatriculeOrEmail.Trim();

        var regMatricule = @"^[a-zA-Z0-9]+$";
        var regEmail = @"^[\w\.]+@([\w]+\.)+[\w]{2,4}";

        var query = _context.Users.IgnoreQueryFilters();

        var user = await query.FirstOrDefaultAsync(u => u.Email == credential || u.Username == credential, cancellationToken);

        if (user == null)
        {
            // Do not leak that the user does not exist for security reasons
            return Result.Success();
        }

        if (!user.IsActive)
        {
            return Result.Success(); // Or return failure depending on security requirements
        }

        if (string.IsNullOrEmpty(user.Email))
        {
            return Result.Success();
        }

        var newPassword = Guid.NewGuid().ToString("N").Substring(0, 8);
        var salt = Guid.NewGuid().ToString("N");
        var hash = _passwordHasher.Hash(newPassword, salt);

        user.PasswordSalt = salt;
        user.PasswordHash = hash;
        
        // Clear tokens just in case
        user.ResetToken = null;
        user.ResetTokenExpiresAt = null;

        await _context.SaveChangesAsync(cancellationToken);

        // Populate request so EventCommandBehavior picks them up
        request.ResolvedEmail = user.Email;
        request.NewPassword = newPassword;
        request.NomPrenom = $"{user.Prenom} {user.Nom}".Trim();

        // The Hangfire job will be triggered automatically because ForgetPasswordCommand implements IEventCommand
        // and returns a Success result here.

        return Result.Success();
    }
}
