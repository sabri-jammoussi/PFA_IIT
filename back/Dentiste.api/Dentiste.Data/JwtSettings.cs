namespace Dentiste.Data;

public class JwtSettings
{
    public string SecurityKey { get; set; } = string.Empty;
    public string Issuer { get; set; } = string.Empty;
    public string Audience { get; set; } = string.Empty;
    public int TokenDurationMinutes { get; set; } = 60;
}
