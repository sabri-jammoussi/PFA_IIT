using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Auth.Commands.Login;

public record LoginCommand : ICommand<LoginResponse>
{
    public required string Username { get; init; }
    public required string Password { get; init; }
}
