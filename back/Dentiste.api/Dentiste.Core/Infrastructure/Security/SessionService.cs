using Microsoft.Extensions.Logging;
using StackExchange.Redis;
using System;
using System.Text.Json;
using System.Threading.Tasks;

namespace Dentiste.Core.Infrastructure.Security;

/// <summary>
/// Redis-backed session store using a whitelist approach.
///
/// Key layout:
///   dentiste:session:{jti}          — session entry (JSON), TTL = token lifetime
///   dentiste:user_sessions:{userId} — sorted set of active JTIs per user
///
/// A token NOT present in the whitelist is considered blacklisted/revoked.
/// </summary>
public class SessionService : ISessionService
{
    private static string SessionKey(string jti) => $"dentiste:session:{jti}";
    private static string UserSessionsKey(int userId) => $"dentiste:user_sessions:{userId}";

    private readonly IConnectionMultiplexer _redis;
    private readonly ILogger<SessionService> _logger;
    private IDatabase Db => _redis.GetDatabase();

    public SessionService(IConnectionMultiplexer redis, ILogger<SessionService> logger)
    {
        _redis = redis;
        _logger = logger;
    }

    public async Task CreateSessionAsync(string jti, int userId, TimeSpan ttl)
    {
        var db = Db;
        var entry = new { Jti = jti, UserId = userId };
        var json = JsonSerializer.Serialize(entry);
        var expiresScore = DateTimeOffset.UtcNow.Add(ttl).ToUnixTimeSeconds();

        // Whitelist marker — just needs to exist for IsSessionActiveAsync
        await db.StringSetAsync(SessionKey(jti), json, ttl);

        // Track JTI in user's sorted set for bulk revocation
        await db.SortedSetAddAsync(UserSessionsKey(userId), jti, expiresScore);
        await db.KeyExpireAsync(UserSessionsKey(userId), ttl.Add(TimeSpan.FromMinutes(5)));

        _logger.LogInformation("[Session] Created — JTI:{Jti} User:{UserId} TTL:{Ttl}m",
            jti, userId, (int)ttl.TotalMinutes);
    }

    public async Task<bool> IsSessionActiveAsync(string jti)
    {
        var exists = await Db.KeyExistsAsync(SessionKey(jti));
        if (!exists)
            _logger.LogWarning("[Session] Rejected — JTI:{Jti} not in whitelist", jti);
        return exists;
    }

    public async Task RevokeSessionAsync(string jti)
    {
        var db = Db;

        // Read entry to get userId for cleanup
        var json = await db.StringGetAsync(SessionKey(jti));
        if (!json.IsNull)
        {
            try
            {
                var entry = JsonSerializer.Deserialize<SessionEntry>(json.ToString());
                if (entry != null)
                    await db.SortedSetRemoveAsync(UserSessionsKey(entry.UserId), jti);
            }
            catch { /* skip malformed entries */ }
        }

        await db.KeyDeleteAsync(SessionKey(jti));
        _logger.LogInformation("[Session] Revoked — JTI:{Jti}", jti);
    }

    public async Task RevokeAllUserSessionsAsync(int userId)
    {
        var db = Db;
        var userKey = UserSessionsKey(userId);

        var jtis = await db.SortedSetRangeByScoreAsync(
            userKey, start: 0);

        foreach (var jti in jtis)
        {
            await db.KeyDeleteAsync(SessionKey(jti!));
        }

        await db.KeyDeleteAsync(userKey);
        _logger.LogInformation("[Session] Revoked all sessions for user {UserId} ({Count} JTIs)",
            userId, jtis.Length);
    }

    // Internal record for deserializing session entries
    private record SessionEntry(string Jti, int UserId);
}
