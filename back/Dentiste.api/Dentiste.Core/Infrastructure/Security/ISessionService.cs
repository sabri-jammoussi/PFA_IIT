using System;
using System.Threading.Tasks;

namespace Dentiste.Core.Infrastructure.Security;

public interface ISessionService
{
    /// <summary>
    /// Registers a session in Redis (whitelist). Called after token creation.
    /// </summary>
    Task CreateSessionAsync(string jti, int userId, TimeSpan ttl);

    /// <summary>
    /// Checks if a session is still active in Redis. Used by the blacklist middleware.
    /// </summary>
    Task<bool> IsSessionActiveAsync(string jti);

    /// <summary>
    /// Revokes a single session (removes from Redis). Called on logout.
    /// </summary>
    Task RevokeSessionAsync(string jti);

    /// <summary>
    /// Revokes all sessions for a user (e.g., on role change or password reset).
    /// </summary>
    Task RevokeAllUserSessionsAsync(int userId);
}
