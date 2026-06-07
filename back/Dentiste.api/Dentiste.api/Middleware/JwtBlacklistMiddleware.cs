using System.IdentityModel.Tokens.Jwt;
using System.Threading.Tasks;
using Dentiste.Core.Infrastructure.Security;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;

namespace Dentiste.api.Middleware;

/// <summary>
/// Validates every authenticated request against the active session whitelist in Redis.
/// A token not present in the whitelist (expired, revoked, or never issued here) is rejected with 401.
/// </summary>
public class JwtBlacklistMiddleware
{
    private readonly RequestDelegate _next;

    public JwtBlacklistMiddleware(RequestDelegate next) => _next = next;

    public async Task InvokeAsync(HttpContext context, ISessionService sessionService)
    {
        var endpoint = context.GetEndpoint();
        var allowAnonymous = endpoint?.Metadata?.GetMetadata<AllowAnonymousAttribute>() != null;

        if (allowAnonymous)
        {
            await _next(context);
            return;
        }

        var jti = context.User.FindFirst(JwtRegisteredClaimNames.Jti)?.Value;

        // No jti claim — not an authenticated request, let the auth middleware handle it
        if (string.IsNullOrEmpty(jti))
        {
            await _next(context);
            return;
        }

        // Whitelist check — reject if the session is not registered in Redis
        if (!await sessionService.IsSessionActiveAsync(jti))
        {
            context.Response.StatusCode = StatusCodes.Status401Unauthorized;
            await context.Response.WriteAsync("Session expirée ou révoquée.");
            return;
        }

        await _next(context);
    }
}
