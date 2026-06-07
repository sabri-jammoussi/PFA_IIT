using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Users.Commands.Update;

public record UpdateUserCommand : ICommand
{
    public required int Id { get; init; }
    public required string Username { get; init; }
    public required string Email { get; init; }
    public string? Password { get; init; }
    public required string Nom { get; init; }
    public required string Prenom { get; init; }
    public required bool IsActive { get; init; }
    public required int RoleId { get; init; }
}
