using MediatR;
using Dentiste.Notification.Core;
using Dentiste.Notification.Features.RendezVous.Commands.Request;

namespace Dentiste.Notification.Features.Notifications.Mappers
{
    public class RequestAppointmentMapper : IEventCommandMapper
    {
        public IBaseRequest? Convert(dynamic payload)
        {
            return new RequestAppointmentNotificationCommand
            {
                RendezVousId = (int)payload.RendezVousId,
                DentisteId = (int)payload.DentisteId,
                PatientId = (int)payload.PatientId,
                CreatedBy = (int)payload.CreatedBy
            };
        }
    }
}
