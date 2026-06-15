using MediatR;
using Dentiste.Notification.Core;
using Dentiste.Notification.Features.Patients.Commands.Update;

namespace Dentiste.Notification.Features.Notifications.Mappers
{
    public class UpdatePatientMapper : IEventCommandMapper
    {
        public IBaseRequest? Convert(dynamic payload)
        {
            return new UpdatePatientNotificationCommand
            {
                PatientId = payload.PatientId,
                Nom = payload.Nom,
                Prenom = payload.Prenom,
                CreatedBy = payload.CreatedBy
            };
        }
    }
}
