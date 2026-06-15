using MediatR;
using Dentiste.Core.Shared;

namespace Dentiste.Notification.Features.Notifications.Commands.MarkAsSeenById
{
    public class MarkAsSeenByIdCommand : IRequest<Result>
    {
        public required int Id { get; init; }
    }
}
