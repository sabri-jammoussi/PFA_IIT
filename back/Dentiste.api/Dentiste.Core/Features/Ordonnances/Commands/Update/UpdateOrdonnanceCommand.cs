using System;
using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Ordonnances.Commands.Update;

public record UpdateOrdonnanceCommand : ICommand
{
    public required int Id { get; init; }
    public required DateTime DateEmission { get; init; }
    public required string Traitement { get; init; }
    public required int ConsultationId { get; init; }
}
