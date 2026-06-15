using System;
using Dentiste.Core.Messaging;
using Dentiste.Notification.Core;

namespace Dentiste.Core.Features.Paiements.Commands.Add;

public record AddPaiementCommand : ICommand<int>, IEventCommand
{
    public required DateTime DatePaiement { get; init; }
    public required decimal Montant { get; init; }
    public required string ModePaiement { get; init; }
    public required int FactureId { get; init; }

    public string EventName => "add-paiement";
    public object EventPayload { get; set; } = new { };
}
