using MediatR;
using Dentiste.Core.Shared;

namespace Dentiste.Notification.Features.Consultations.Commands.Finalize
{
    public record FinalizeConsultationNotificationCommand : IRequest<Result>
    {
        public required int FactureId { get; init; }
        public required int ConsultationId { get; init; }
        public required decimal Montant { get; init; }
        public required string PatientName { get; init; }
        public required int CreatedBy { get; init; }
    }
}
