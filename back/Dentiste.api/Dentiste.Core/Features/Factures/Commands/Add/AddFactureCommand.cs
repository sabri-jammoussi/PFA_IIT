using System;
using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Factures.Commands.Add;

public record AddFactureCommand : ICommand<int>
{
    public required string NumeroFacture { get; init; }
    public required DateTime DateEmission { get; init; }
    public required decimal MontantTotal { get; init; }
    public required decimal MontantPaye { get; init; }
    public required string StatutPaiement { get; init; }
    public required int PatientId { get; init; }
}
