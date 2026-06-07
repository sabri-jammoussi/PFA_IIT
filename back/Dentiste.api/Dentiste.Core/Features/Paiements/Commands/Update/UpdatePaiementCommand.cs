using System;
using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Paiements.Commands.Update;

public record UpdatePaiementCommand : ICommand
{
    public required int Id { get; init; }
    public required DateTime DatePaiement { get; init; }
    public required decimal Montant { get; init; }
    public required string ModePaiement { get; init; }
    public required int FactureId { get; init; }
}
