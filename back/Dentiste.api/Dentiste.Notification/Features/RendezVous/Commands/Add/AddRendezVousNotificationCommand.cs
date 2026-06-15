using MediatR;
using Dentiste.Core.Shared;

namespace Dentiste.Notification.Features.RendezVous.Commands.Add
{
    public record AddRendezVousNotificationCommand : IRequest<Result>
    {
        public required int RendezVousId { get; init; }
        public required int DentisteId { get; init; }
        public required int PatientId { get; init; }
        public required int CreatedBy { get; init; }
    }
}
