using System;
using System.Security.Cryptography;
using System.Text;
using Dentiste.Core.Infrastructure.Security;
using Xunit;

namespace Dentiste.Tests;

public class PasswordHasherTests
{
    private readonly IPasswordHasher _hasher = new PasswordHasher();

    [Fact]
    public void Hash_ProducesBCryptHash()
    {
        var hash = _hasher.Hash("Sup3rSecret!", salt: "ignored");

        Assert.StartsWith("$2", hash);
        Assert.NotEqual("Sup3rSecret!", hash);
    }

    [Fact]
    public void Verify_ReturnsTrue_ForCorrectPassword()
    {
        var hash = _hasher.Hash("Sup3rSecret!", salt: "ignored");

        Assert.True(_hasher.Verify("Sup3rSecret!", "ignored", hash));
    }

    [Fact]
    public void Verify_ReturnsFalse_ForWrongPassword()
    {
        var hash = _hasher.Hash("Sup3rSecret!", salt: "ignored");

        Assert.False(_hasher.Verify("wrong-password", "ignored", hash));
    }

    [Fact]
    public void Hash_IsSalted_SoSamePasswordYieldsDifferentHashes()
    {
        var a = _hasher.Hash("samePassword", salt: "x");
        var b = _hasher.Hash("samePassword", salt: "y");

        Assert.NotEqual(a, b);
        Assert.True(_hasher.Verify("samePassword", "x", a));
        Assert.True(_hasher.Verify("samePassword", "y", b));
    }

    [Fact]
    public void Verify_StillAccepts_LegacySha256Hashes()
    {
        // Reproduce the legacy scheme: Base64(SHA256(password + salt)).
        const string password = "legacyPass1";
        const string salt = "deadbeef";
        using var sha256 = SHA256.Create();
        var legacyHash = Convert.ToBase64String(sha256.ComputeHash(Encoding.UTF8.GetBytes(password + salt)));

        Assert.True(_hasher.Verify(password, salt, legacyHash));
        Assert.False(_hasher.Verify("not-it", salt, legacyHash));
    }

    [Fact]
    public void Verify_ReturnsFalse_ForEmptyHash()
    {
        Assert.False(_hasher.Verify("anything", "salt", string.Empty));
    }
}
