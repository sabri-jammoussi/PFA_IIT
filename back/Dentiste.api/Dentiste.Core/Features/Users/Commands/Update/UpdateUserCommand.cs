using Dentiste.Core.Messaging;
using Dentiste.Notification.Core;

namespace Dentiste.Core.Features.Users.Commands.Update;

public record UpdateUserCommand : ICommand, IEventCommand
{
    public required int Id { get; init; }
    public required string Username { get; init; }
    public required string Email { get; init; }
    public string? Password { get; init; }
    public required string Nom { get; init; }
    public required string Prenom { get; init; }
    public required bool IsActive { get; init; }
    public required int RoleId { get; init; }

    // MediatR pipeline event mapping properties
    public string EventName => "update-user";
    public object EventPayload { get; set; } = new { };
}
