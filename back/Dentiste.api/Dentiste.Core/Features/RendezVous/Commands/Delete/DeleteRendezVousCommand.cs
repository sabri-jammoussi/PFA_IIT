using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.RendezVous.Commands.Delete;

public record DeleteRendezVousCommand : ICommand
{
    public required int Id { get; init; }
}
