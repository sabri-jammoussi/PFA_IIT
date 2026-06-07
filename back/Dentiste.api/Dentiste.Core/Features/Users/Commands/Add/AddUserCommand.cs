using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Users.Commands.Add;

public record AddUserCommand : ICommand<int>
{
    public required string Username { get; init; }
    public required string Email { get; init; }
    public required string Password { get; init; }
    public required string Nom { get; init; }
    public required string Prenom { get; init; }
    public required int RoleId { get; init; }
}
