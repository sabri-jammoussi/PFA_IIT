using MediatR;
using Dentiste.Core.Shared;
using Dentiste.Data.Enums;

namespace Dentiste.Notification.Features.Notifications.Commands
{
    public record CreateNotificationCommand : IRequest<Result>
    {
        public required NotificationNature Nature { get; init; }
        public required int EntityId { get; init; }
        public required string EntityCode { get; init; }
        public required string Title { get; init; }
        public required string Description { get; init; }
        public required NotificationDomaine Domaine { get; init; }
        public required int CreatedBy { get; init; }
        public required int CreatedTo { get; init; }
        public required NotificationType Type { get; init; }
        public int DemandeId { get; init; }
    }
}
