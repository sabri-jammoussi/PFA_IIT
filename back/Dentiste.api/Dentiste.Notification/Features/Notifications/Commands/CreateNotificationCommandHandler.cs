using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Dentiste.Core.Shared;
using Dentiste.Notification.Hubs;
using Dentiste.Data.Infrastructure.EF;
using Dentiste.Data.Models;

namespace Dentiste.Notification.Features.Notifications.Commands
{
    public class CreateNotificationCommandHandler : IRequestHandler<CreateNotificationCommand, Result>
    {
        private readonly DentisteContext _context;
        private readonly INotificationHubClientProvider _hubClientProvider;
        private readonly ILogger<CreateNotificationCommandHandler> _logger;

        public CreateNotificationCommandHandler(
            DentisteContext context,
            INotificationHubClientProvider hubClientProvider,
            ILogger<CreateNotificationCommandHandler> logger)
        {
            _context = context;
            _hubClientProvider = hubClientProvider;
            _logger = logger;
        }

        public async Task<Result> Handle(CreateNotificationCommand request, CancellationToken cancellationToken)
        {
            try
            {
                var recipientUser = await _context.Users
                    .AsNoTracking()
                    .FirstOrDefaultAsync(u => u.Id == request.CreatedTo, cancellationToken);
                var cabinetId = recipientUser?.CabinetId ?? 1;

                var notification = new NotificationDao
                {
                    Nature = request.Nature,
                    EntityId = request.EntityId,
                    EntityCode = request.EntityCode,
                    Title = request.Title,
                    Description = request.Description,
                    Domaine = request.Domaine,
                    CreatedBy = request.CreatedBy,
                    CreatedTo = request.CreatedTo,
                    DateRappel = DateTime.UtcNow,
                    IsSeen = false,
                    Type = request.Type,
                    DemandeId = request.DemandeId,
                    CabinetId = cabinetId
                };

                _context.Notifications.Add(notification);
                await _context.SaveChangesAsync(cancellationToken);

                var payload = new
                {
                    id = notification.Id,
                    nature = (int)notification.Nature,
                    entityId = notification.EntityId,
                    entityCode = notification.EntityCode,
                    title = notification.Title,
                    description = notification.Description,
                    domaine = (int)notification.Domaine,
                    createdBy = notification.CreatedBy,
                    createdTo = notification.CreatedTo,
                    dateRappel = notification.DateRappel,
                    isSeen = notification.IsSeen,
                    type = (int)notification.Type,
                    demandeId = notification.DemandeId
                };

                await _hubClientProvider.Get(notification.CreatedTo).ReceiveMessage(payload);

                return Result.Success();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while creating notification");
                return Result.Failure(ex.Message);
            }
        }
    }
}
