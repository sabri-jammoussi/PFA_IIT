using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Auth.Commands.Logout;

public record LogoutCommand : ICommand
{
    public required string Jti { get; init; }
}
