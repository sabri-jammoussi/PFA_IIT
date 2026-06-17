using System;
using System.Security.Cryptography;
using System.Text;

namespace Dentiste.Core.Infrastructure.Security;

/// <summary>
/// Password hashing using BCrypt (adaptive, salt embedded in the hash).
/// The <paramref name="salt"/> parameter is kept for interface compatibility with the
/// stored USR_PASSWORD_SALT column but is no longer used by BCrypt — BCrypt manages its
/// own per-hash salt. Verification transparently falls back to the legacy salted-SHA256
/// scheme so accounts created before the migration keep working until their next login.
/// </summary>
public class PasswordHasher : IPasswordHasher
{
    // Work factor 12 — solid default for 2026 hardware.
    private const int WorkFactor = 12;

    public string Hash(string password, string salt)
    {
        return BCrypt.Net.BCrypt.HashPassword(password, WorkFactor);
    }

    public bool Verify(string password, string salt, string expectedHash)
    {
        if (string.IsNullOrEmpty(expectedHash))
        {
            return false;
        }

        // BCrypt hashes start with $2a$/$2b$/$2y$.
        if (expectedHash.StartsWith("$2", StringComparison.Ordinal))
        {
            try
            {
                return BCrypt.Net.BCrypt.Verify(password, expectedHash);
            }
            catch (BCrypt.Net.SaltParseException)
            {
                return false;
            }
        }

        // Legacy fallback: salted SHA-256 (constant-time comparison).
        return VerifyLegacySha256(password, salt, expectedHash);
    }

    private static bool VerifyLegacySha256(string password, string salt, string expectedHash)
    {
        using var sha256 = SHA256.Create();
        var bytes = Encoding.UTF8.GetBytes(password + salt);
        var computed = Convert.ToBase64String(sha256.ComputeHash(bytes));
        var a = Encoding.UTF8.GetBytes(computed);
        var b = Encoding.UTF8.GetBytes(expectedHash);
        return CryptographicOperations.FixedTimeEquals(a, b);
    }
}
