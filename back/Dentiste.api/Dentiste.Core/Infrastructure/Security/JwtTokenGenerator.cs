using Dentiste.Data;
using Dentiste.Data.Models;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;

namespace Dentiste.Core.Infrastructure.Security;

public class JwtTokenGenerator : IJwtTokenGenerator
{
    private readonly JwtSettings _jwtSettings;
    private readonly ISessionService _sessionService;

    public JwtTokenGenerator(IOptions<JwtSettings> jwtSettings, ISessionService sessionService)
    {
        _jwtSettings = jwtSettings.Value;
        _sessionService = sessionService;
    }

    public async Task<string> CreateToken(UserDao user)
    {
        var jti = Guid.NewGuid().ToString();
        var now = DateTime.UtcNow;
        var expires = now.AddMinutes(_jwtSettings.TokenDurationMinutes);
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtSettings.SecurityKey));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        // Map database role names to standard code role names for token authorization consistency
        var dbRole = user.Role?.Name ?? "Unknown";
        var mappedRole = dbRole;
        if (dbRole == "Administrateur" || dbRole == "Admin")
        {
            mappedRole = "Admin";
        }
        else if (dbRole == "Assistant" || dbRole == "Secretaire")
        {
            mappedRole = "Secretaire";
        }
        else if (dbRole == "Dentiste")
        {
            mappedRole = "Dentiste";
        }

        var claims = new List<Claim>
        {
            new(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new(JwtRegisteredClaimNames.Jti, jti),
            new(ClaimTypes.Name, user.Username),
            new(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new(ClaimTypes.Role, mappedRole),
            new("role", mappedRole), // For frontend client JWT decoder
            new("id", user.Id.ToString()),
            new("name", $"{user.Prenom} {user.Nom}"),
            new("email", user.Email),
            new("nom", user.Nom),
            new("prenom", user.Prenom)
        };

        if (user.CabinetId.HasValue)
        {
            claims.Add(new Claim("cabinetId", user.CabinetId.Value.ToString()));
            claims.Add(new Claim("cabinetName", user.Cabinet?.NomCabinet ?? ""));
        }

        var tokenDescriptor = new SecurityTokenDescriptor
        {
            Issuer = _jwtSettings.Issuer,
            Audience = _jwtSettings.Audience,
            IssuedAt = now,
            Expires = expires,
            NotBefore = now,
            SigningCredentials = credentials,
            Subject = new ClaimsIdentity(claims)
        };

        var tokenHandler = new JwtSecurityTokenHandler();
        var token = tokenHandler.CreateToken(tokenDescriptor);
        var encodedJwt = tokenHandler.WriteToken(token);

        // Register session in Redis whitelist
        var ttl = expires - now;
        await _sessionService.CreateSessionAsync(jti, user.Id, ttl);

        return encodedJwt;
    }
}
