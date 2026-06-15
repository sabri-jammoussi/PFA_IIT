using MediatR;
using Dentiste.Core.Shared;

namespace Dentiste.Notification.Features.Patients.Commands.Update
{
    public record UpdatePatientNotificationCommand : IRequest<Result>
    {
        public required int PatientId { get; init; }
        public required string Nom { get; init; }
        public required string Prenom { get; init; }
        public required int CreatedBy { get; init; }
    }
}
