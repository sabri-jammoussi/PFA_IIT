using MediatR;

namespace Dentiste.Core.Features.Options.Queries.GetSmtp;

public record GetSmtpOptionsQuery() : IRequest<SmtpOptionsDto>;

public class SmtpOptionsDto
{
    public string Host { get; set; } = string.Empty;
    public string Port { get; set; } = string.Empty;
    public string Username { get; set; } = string.Empty;
    /// <summary>Password is never returned as plain text — always masked.</summary>
    public bool HasPassword { get; set; }
    public bool Ssl { get; set; }
}
