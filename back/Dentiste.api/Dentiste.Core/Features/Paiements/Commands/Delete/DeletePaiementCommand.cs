using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Paiements.Commands.Delete;

public record DeletePaiementCommand : ICommand
{
    public required int Id { get; init; }
}
