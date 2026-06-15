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

namespace Dentiste.Notification.Features.RendezVous.Commands.Request
{
    public class RequestAppointmentNotificationHandler : IRequestHandler<RequestAppointmentNotificationCommand, Result>
    {
        private readonly ILogger<RequestAppointmentNotificationHandler> _logger;
        private readonly DentisteContext _dbContext;
        private readonly INotificationHubClientProvider _notificationHubClientProvider;

        public RequestAppointmentNotificationHandler(
            ILogger<RequestAppointmentNotificationHandler> logger,
            DentisteContext dbContext,
            INotificationHubClientProvider notificationHubClientProvider)
        {
            _logger = logger;
            _dbContext = dbContext;
            _notificationHubClientProvider = notificationHubClientProvider;
        }

        public async Task<Result> Handle(RequestAppointmentNotificationCommand request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("Processing requested appointment notification for RendezVousId: {RdvId}", request.RendezVousId);

            var rdv = await _dbContext.RendezVous.IgnoreQueryFilters().AsNoTracking().SingleOrDefaultAsync(r => r.Id == request.RendezVousId, cancellationToken);
            var dateStr = rdv != null ? rdv.DateHeure.ToString("dd/MM/yyyy HH:mm") : "inconnue";

            var patient = await _dbContext.Patients.IgnoreQueryFilters().AsNoTracking().SingleOrDefaultAsync(p => p.Id == request.PatientId, cancellationToken);
            var patientName = patient != null ? $"{patient.Prenom} {patient.Nom}" : "Patient";
            var cabinetId = patient?.CabinetId ?? rdv?.Dentiste?.CabinetId ?? 1;

            // Load secretaries in the cabinet
            var recipients = await _dbContext.Users
                .IgnoreQueryFilters()
                .AsNoTracking()
                .Where(u => u.CabinetId == cabinetId && u.RoleId == 3 && u.IsActive)
                .ToListAsync(cancellationToken);

            // Fallback: load dentists in the cabinet if no secretaries are found
            if (!recipients.Any())
            {
                recipients = await _dbContext.Users
                    .IgnoreQueryFilters()
                    .AsNoTracking()
                    .Where(u => u.CabinetId == cabinetId && u.RoleId == 2 && u.IsActive)
                    .ToListAsync(cancellationToken);
            }

            if (!recipients.Any())
            {
                _logger.LogWarning("No secretary or dentist found to notify in cabinet {CabinetId}", cabinetId);
                return Result.Success();
            }

            var title = "Nouvelle demande de rendez-vous";
            var description = $"Le patient {patientName} a demandé un RDV le {dateStr}.";

            var notificationList = new List<NotificationDao>();
            foreach (var user in recipients)
            {
                var notif = new NotificationDao
                {
                    Title = title,
                    Description = description,
                    EntityId = request.RendezVousId,
                    EntityCode = "RDV",
                    DateRappel = DateTime.UtcNow,
                    Domaine = NotificationDomaine.RendezVous,
                    CreatedBy = request.CreatedBy,
                    CreatedTo = user.Id,
                    Nature = NotificationNature.Evenement,
                    IsSeen = false,
                    DemandeId = request.RendezVousId,
                    Type = NotificationType.Creation,
                    CabinetId = cabinetId
                };
                notificationList.Add(notif);
            }

            _dbContext.Notifications.AddRange(notificationList);
            await _dbContext.SaveChangesAsync(cancellationToken);

            // Send Real-time SignalR Notifications
            foreach (var notif in notificationList)
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

                try
                {
                    await _notificationHubClientProvider.Get(notif.CreatedTo).ReceiveMessage(payload);
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Failed to dispatch SignalR notification to user {UserId}", notif.CreatedTo);
                }
            }

            return Result.Success();
        }
    }
}
