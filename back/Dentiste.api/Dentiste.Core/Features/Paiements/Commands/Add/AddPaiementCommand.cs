using System;
using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Paiements.Commands.Add;

public record AddPaiementCommand : ICommand<int>
{
    public required DateTime DatePaiement { get; init; }
    public required decimal Montant { get; init; }
    public required string ModePaiement { get; init; }
    public required int FactureId { get; init; }
}
