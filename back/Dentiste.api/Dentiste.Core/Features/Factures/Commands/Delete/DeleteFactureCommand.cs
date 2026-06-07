using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Factures.Commands.Delete;

public record DeleteFactureCommand : ICommand
{
    public required int Id { get; init; }
}
