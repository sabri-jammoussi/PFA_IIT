using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Users.Commands.Delete;

public record DeleteUserCommand : ICommand
{
    public required int Id { get; init; }
}
