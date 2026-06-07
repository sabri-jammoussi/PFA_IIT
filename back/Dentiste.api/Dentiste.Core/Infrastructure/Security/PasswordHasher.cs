using System;
using System.Security.Cryptography;
using System.Text;

namespace Dentiste.Core.Infrastructure.Security;

public class PasswordHasher : IPasswordHasher
{
    public string Hash(string password, string salt)
    {
        using var sha256 = SHA256.Create();
        var saltedPassword = password + salt;
        var bytes = Encoding.UTF8.GetBytes(saltedPassword);
        var hash = sha256.ComputeHash(bytes);
        return Convert.ToBase64String(hash);
    }

    public bool Verify(string password, string salt, string expectedHash)
    {
        var computedHash = Hash(password, salt);
        return string.Equals(computedHash, expectedHash, StringComparison.Ordinal);
    }
}
