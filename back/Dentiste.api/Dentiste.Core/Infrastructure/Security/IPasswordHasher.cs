namespace Dentiste.Core.Infrastructure.Security;

public interface IPasswordHasher
{
    string Hash(string password, string salt);
    bool Verify(string password, string salt, string expectedHash);
}
