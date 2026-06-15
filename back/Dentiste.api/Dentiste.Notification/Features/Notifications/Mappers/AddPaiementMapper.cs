using MediatR;
using Dentiste.Notification.Core;
using Dentiste.Notification.Features.Paiements.Commands.Add;

namespace Dentiste.Notification.Features.Notifications.Mappers
{
    public class AddPaiementMapper : IEventCommandMapper
    {
        public IBaseRequest? Convert(dynamic payload)
        {
            return new AddPaiementNotificationCommand
            {
                PaiementId = payload.PaiementId,
                FactureId = payload.FactureId,
                Montant = payload.Montant,
                CreatedBy = payload.CreatedBy
            };
        }
    }
}
