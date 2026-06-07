using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Roles.Queries.GetById;

public record GetRoleByIdQuery : IQuery<RoleDto>
{
    public required int Id { get; init; }
}
