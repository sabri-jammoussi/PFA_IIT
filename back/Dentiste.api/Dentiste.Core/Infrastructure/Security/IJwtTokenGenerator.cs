using Dentiste.Data.Models;
using System.Threading.Tasks;

namespace Dentiste.Core.Infrastructure.Security;

public interface IJwtTokenGenerator
{
    /// <summary>
    /// Creates a JWT token for the given user and registers the session in Redis.
    /// </summary>
    Task<string> CreateToken(UserDao user);
}
