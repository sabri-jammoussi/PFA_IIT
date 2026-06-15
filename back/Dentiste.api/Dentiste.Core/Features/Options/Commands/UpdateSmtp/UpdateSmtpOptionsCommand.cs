using MediatR;

namespace Dentiste.Core.Features.Options.Commands.UpdateSmtp;

public record UpdateSmtpOptionsCommand(
    string Host,
    string Port,
    string Username,
    /// <summary>Null or empty = do not change the stored password.</summary>
    string? Password,
    bool Ssl
) : IRequest<bool>;
