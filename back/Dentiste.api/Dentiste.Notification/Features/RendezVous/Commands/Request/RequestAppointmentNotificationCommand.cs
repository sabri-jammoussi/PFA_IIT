using MediatR;
using Dentiste.Core.Shared;

namespace Dentiste.Notification.Features.RendezVous.Commands.Request
{
    public record RequestAppointmentNotificationCommand : IRequest<Result>
    {
        public required int RendezVousId { get; init; }
        public required int DentisteId { get; init; }
        public required int PatientId { get; init; }
        public required int CreatedBy { get; init; }
    }
}
