using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Features.Users;
using Dentiste.Core.Infrastructure.Security;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Auth.Commands.Login;

public class LoginCommandHandler : ICommandHandler<LoginCommand, LoginResponse>
{
    private readonly DentisteContext _context;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IJwtTokenGenerator _jwtTokenGenerator;

    public LoginCommandHandler(
        DentisteContext context,
        IPasswordHasher passwordHasher,
        IJwtTokenGenerator jwtTokenGenerator)
    {
        _context = context;
        _passwordHasher = passwordHasher;
        _jwtTokenGenerator = jwtTokenGenerator;
    }

    public async Task<Result<LoginResponse>> Handle(LoginCommand request, CancellationToken cancellationToken)
    {
        // Find user by username or email (include Role for claims, ignoring query filters since tenant context is not resolved yet during login)
        var user = await _context.Users
            .IgnoreQueryFilters()
            .Include(u => u.Role)
            .Include(u => u.Cabinet)
            .FirstOrDefaultAsync(u => u.Username == request.Username || u.Email == request.Username, cancellationToken);

        if (user == null)
        {
            return Result.Failure<LoginResponse>(Errors.InvalidCredentials);
        }

        // Verify password
        if (!_passwordHasher.Verify(request.Password, user.PasswordSalt, user.PasswordHash))
        {
            return Result.Failure<LoginResponse>(Errors.InvalidCredentials);
        }

        // Check active status
        if (!user.IsActive)
        {
            return Result.Failure<LoginResponse>(Errors.AccountDisabled);
        }

        // Check SaaS subscription active status
        if (user.CabinetId.HasValue && user.Cabinet != null && !user.Cabinet.IsSubscriptionActive)
        {
            return Result.Failure<LoginResponse>(Errors.SaaS.SubscriptionExpired);
        }

        // Generate JWT (this also registers the session in Redis)
        var token = await _jwtTokenGenerator.CreateToken(user);

        return Result.Success(new LoginResponse(token));
    }
}
