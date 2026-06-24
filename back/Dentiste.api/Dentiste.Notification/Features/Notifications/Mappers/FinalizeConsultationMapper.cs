using MediatR;
using Dentiste.Notification.Core;
using Dentiste.Notification.Features.Consultations.Commands.Finalize;

namespace Dentiste.Notification.Features.Notifications.Mappers
{
    public class FinalizeConsultationMapper : IEventCommandMapper
    {
        public IBaseRequest? Convert(dynamic payload)
        {
            return new FinalizeConsultationNotificationCommand
            {
                FactureId = payload.FactureId,
                ConsultationId = payload.ConsultationId,
                Montant = payload.Montant,
                PatientName = (string)payload.PatientName,
                CreatedBy = payload.CreatedBy
            };
        }
    }
}
