using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Users.Queries.GetById;

public record GetUserByIdQuery : IQuery<UserDto>
{
    public required int Id { get; init; }
}
