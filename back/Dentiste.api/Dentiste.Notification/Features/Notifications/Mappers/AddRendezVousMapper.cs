using MediatR;
using Dentiste.Notification.Core;
using Dentiste.Notification.Features.RendezVous.Commands.Add;

namespace Dentiste.Notification.Features.Notifications.Mappers
{
    public class AddRendezVousMapper : IEventCommandMapper
    {
        public IBaseRequest? Convert(dynamic payload)
        {
            return new AddRendezVousNotificationCommand
            {
                RendezVousId = payload.RendezVousId,
                DentisteId = payload.DentisteId,
                PatientId = payload.PatientId,
                CreatedBy = payload.CreatedBy
            };
        }
    }
}
