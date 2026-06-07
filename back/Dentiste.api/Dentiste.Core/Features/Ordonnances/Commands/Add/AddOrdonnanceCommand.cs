using System;
using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Ordonnances.Commands.Add;

public record AddOrdonnanceCommand : ICommand<int>
{
    public required DateTime DateEmission { get; init; }
    public required string Traitement { get; init; }
    public required int ConsultationId { get; init; }
}
