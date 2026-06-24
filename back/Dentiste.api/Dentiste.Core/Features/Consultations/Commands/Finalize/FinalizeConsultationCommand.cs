using Dentiste.Core.Messaging;
using Dentiste.Notification.Core;

namespace Dentiste.Core.Features.Consultations.Commands.Finalize;

public record FinalizeConsultationCommand : ICommand<FinalizeConsultationResult>, IEventCommand
{
    public required int ConsultationId { get; init; }

    // ── Notification event plumbing (handled by CommandEventBehavior) ──
    public string EventName => "finalize-consultation";
    public object EventPayload { get; set; } = new { };
}
