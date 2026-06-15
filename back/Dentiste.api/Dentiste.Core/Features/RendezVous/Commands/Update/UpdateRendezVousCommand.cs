using System;
using Dentiste.Core.Messaging;
using Dentiste.Notification.Core;

namespace Dentiste.Core.Features.RendezVous.Commands.Update;

public record UpdateRendezVousCommand : ICommand, IEventCommand
{
    public required int Id { get; init; }
    public required DateTime DateHeure { get; init; }
    public required TimeSpan DureeEstimee { get; init; }
    public required string Statut { get; init; }
    public string? Motif { get; init; }
    public string? Note { get; init; }
    public required int PatientId { get; init; }
    public required int DentisteId { get; init; }

    public string EventName => "update-rendezvous";
    public object EventPayload { get; set; } = new { };
}
