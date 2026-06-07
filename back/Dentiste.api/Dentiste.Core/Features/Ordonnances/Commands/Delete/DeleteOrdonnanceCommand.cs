using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Ordonnances.Commands.Delete;

public record DeleteOrdonnanceCommand : ICommand
{
    public required int Id { get; init; }
}
