using MediatR;
using Dentiste.Notification.Core;
using Dentiste.Notification.Features.Patients.Commands.Invite;

namespace Dentiste.Notification.Features.Notifications.Mappers
{
    public class InvitePatientMapper : IEventCommandMapper
    {
        public IBaseRequest? Convert(dynamic payload)
        {
            return new InvitePatientNotificationCommand
            {
                PatientId = payload.PatientId,
                Nom = payload.Nom,
                Prenom = payload.Prenom,
                Email = payload.Email,
                TemporaryPassword = payload.TemporaryPassword
            };
        }
    }
}
