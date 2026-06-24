using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Consommations.Commands.Delete;

public record DeleteConsommationCommand : ICommand
{
    public required int Id { get; init; }
}
