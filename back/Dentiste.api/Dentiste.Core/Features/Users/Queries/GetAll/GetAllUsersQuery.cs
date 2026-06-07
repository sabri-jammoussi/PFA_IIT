using Dentiste.Core.Messaging;
using Dentiste.Core.Features.Shared;

namespace Dentiste.Core.Features.Users.Queries.GetAll;

public record GetAllUsersQuery : IQuery<PagedResult<UserDto>>
{
    public int Page { get; init; } = 1;
    public int PageSize { get; init; } = 10;
    public string? SearchTerm { get; init; }
    public int? RoleId { get; init; }
}
