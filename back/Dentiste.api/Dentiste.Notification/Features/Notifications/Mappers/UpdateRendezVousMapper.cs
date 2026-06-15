using MediatR;
using Dentiste.Notification.Core;
using Dentiste.Notification.Features.RendezVous.Commands.Update;

namespace Dentiste.Notification.Features.Notifications.Mappers
{
    public class UpdateRendezVousMapper : IEventCommandMapper
    {
        public IBaseRequest? Convert(dynamic payload)
        {
            return new UpdateRendezVousNotificationCommand
            {
                RendezVousId = (int)payload.RendezVousId,
                DentisteId = (int)payload.DentisteId,
                PatientId = (int)payload.PatientId,
                Statut = (string)payload.Statut,
                CreatedBy = (int)payload.CreatedBy
            };
        }
    }
}
