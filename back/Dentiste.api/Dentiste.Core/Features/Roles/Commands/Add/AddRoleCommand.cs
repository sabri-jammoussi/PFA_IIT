using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Roles.Commands.Add;

public record AddRoleCommand : ICommand<int>
{
    public required string Name { get; init; }
    public string? Description { get; init; }
}
