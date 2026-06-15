using MediatR;
using Dentiste.Core.Shared;

namespace Dentiste.Notification.Features.Patients.Commands.Invite
{
    public record InvitePatientNotificationCommand : IRequest<Result>
    {
        public required int PatientId { get; init; }
        public required string Nom { get; init; }
        public required string Prenom { get; init; }
        public required string Email { get; init; }
        public required string TemporaryPassword { get; init; }
    }
}
