using MediatR;
using Dentiste.Core.Shared;

namespace Dentiste.Notification.Features.RendezVous.Commands.Update
{
    public record UpdateRendezVousNotificationCommand : IRequest<Result>
    {
        public required int RendezVousId { get; init; }
        public required int DentisteId { get; init; }
        public required int PatientId { get; init; }
        public required string Statut { get; init; }
        public required int CreatedBy { get; init; }
    }
}
