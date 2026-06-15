using MediatR;
using Dentiste.Core.Shared;

namespace Dentiste.Notification.Features.SaaS.Commands.RegisterClinic
{
    public record RegisterClinicNotificationCommand : IRequest<Result>
    {
        public int CabinetId { get; init; }
        public required string NomCabinet { get; init; }
        public required string DoctorEmail { get; init; }
        public required string DoctorNom { get; init; }
        public required string DoctorPrenom { get; init; }
    }
}
