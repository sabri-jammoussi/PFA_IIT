using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Dentiste.Core.Shared;
using Dentiste.Data.Enums;
using Dentiste.Data.Infrastructure.EF;
using Dentiste.Data.Models;
using Dentiste.Notification.Hubs;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Dentiste.Notification.Features.Consultations.Commands.Finalize
{
    public class FinalizeConsultationNotificationHandler
        : IRequestHandler<FinalizeConsultationNotificationCommand, Result>
    {
        private readonly ILogger<FinalizeConsultationNotificationHandler> _logger;
        private readonly DentisteContext _dbContext;
        private readonly ConsultationsUsersProvider _usersProvider;
        private readonly INotificationHubClientProvider _notificationHubClientProvider;

        public FinalizeConsultationNotificationHandler(
            ILogger<FinalizeConsultationNotificationHandler> logger,
            DentisteContext dbContext,
            ConsultationsUsersProvider usersProvider,
            INotificationHubClientProvider notificationHubClientProvider)
        {
            _logger = logger;
            _dbContext = dbContext;
            _usersProvider = usersProvider;
            _notificationHubClientProvider = notificationHubClientProvider;
        }

        public async Task<Result> Handle(FinalizeConsultationNotificationCommand request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("Processing finalize-consultation notification for FactureId: {FactureId}", request.FactureId);

            var facture = await _dbContext.Factures
                .IgnoreQueryFilters()
                .AsNoTracking()
                .SingleOrDefaultAsync(f => f.Id == request.FactureId, cancellationToken);

            if (facture == null)
            {
                _logger.LogWarning("Facture {FactureId} not found for finalize notification", request.FactureId);
                return Result.Success();
            }

            var users = await _usersProvider.Get(facture.CabinetId, cancellationToken);
            if (!users.Any())
            {
                _logger.LogWarning("No secretary found to notify for finalized consultation in cabinet {CabinetId}", facture.CabinetId);
                return Result.Success();
            }

            var numeroFacture = facture.NumeroFacture ?? $"#{request.FactureId}";
            var montant = request.Montant.ToString("0.##");
            var title = "Consultation terminée";
            var description = $"{request.PatientName} : {montant} DT à encaisser (facture {numeroFacture}).";

            // 1. Persist a notification per secretary (notification center, web + mobile)
            var notifications = new List<NotificationDao>();
            foreach (var user in users)
            {
                notifications.Add(new NotificationDao
                {
                    Title = title,
                    Description = description,
                    EntityId = request.FactureId,
                    EntityCode = "FIN",
                    DateRappel = DateTime.UtcNow,
                    Domaine = NotificationDomaine.Facture,
                    CreatedBy = request.CreatedBy,
                    CreatedTo = user.Id,
                    Nature = NotificationNature.Evenement,
                    IsSeen = false,
                    DemandeId = request.FactureId,
                    Type = NotificationType.Information,
                    CabinetId = user.CabinetId ?? facture.CabinetId
                });
            }

            _dbContext.Notifications.AddRange(notifications);
            await _dbContext.SaveChangesAsync(cancellationToken);

            // 2. Push in real time to each secretary
            foreach (var notif in notifications)
            {
                var payload = new
                {
                    id = notif.Id,
                    nature = (int)notif.Nature,
                    entityId = notif.EntityId,
                    entityCode = notif.EntityCode,
                    title = notif.Title,
                    description = notif.Description,
                    domaine = (int)notif.Domaine,
                    createdBy = notif.CreatedBy,
                    createdTo = notif.CreatedTo,
                    dateRappel = notif.DateRappel,
                    isSeen = notif.IsSeen,
                    type = (int)notif.Type,
                    demandeId = notif.DemandeId
                };

                await _notificationHubClientProvider.Get(notif.CreatedTo).ReceiveMessage(payload);
            }

            return Result.Success();
        }
    }
}
