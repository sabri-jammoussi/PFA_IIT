using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Roles.Commands.Update;

public record UpdateRoleCommand : ICommand
{
    public required int Id { get; init; }
    public required string Name { get; init; }
    public string? Description { get; init; }
}
