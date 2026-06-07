using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Roles.Commands.Delete;

public record DeleteRoleCommand : ICommand
{
    public required int Id { get; init; }
}
