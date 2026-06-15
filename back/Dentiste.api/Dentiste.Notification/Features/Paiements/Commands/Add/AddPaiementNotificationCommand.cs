using MediatR;
using Dentiste.Core.Shared;

namespace Dentiste.Notification.Features.Paiements.Commands.Add
{
    public record AddPaiementNotificationCommand : IRequest<Result>
    {
        public required int PaiementId { get; init; }
        public required int FactureId { get; init; }
        public required decimal Montant { get; init; }
        public required int CreatedBy { get; init; }
    }
}
