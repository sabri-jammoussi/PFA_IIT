using System;
using Dentiste.Core.Messaging;
using Dentiste.Notification.Core;

namespace Dentiste.Core.Features.RendezVous.Commands.Request;

public record RequestAppointmentCommand : ICommand<int>, IEventCommand
{
    public required DateTime DateHeure { get; init; }
    public required string Motif { get; init; }
    public required int DentisteId { get; init; }

    public string EventName => "request-appointment";
    public object EventPayload { get; set; } = new { };
}
