using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Dentiste.Core.Shared;
using Dentiste.Data.Enums;
using Dentiste.Data.Infrastructure.EF;
using Dentiste.Data.Models;
using Dentiste.Notification.Hubs;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Dentiste.Notification.Features.RendezVous.Commands.Update
{
    public class UpdateRendezVousNotificationHandler : IRequestHandler<UpdateRendezVousNotificationCommand, Result>
    {
        private readonly ILogger<UpdateRendezVousNotificationHandler> _logger;
        private readonly DentisteContext _dbContext;
        private readonly INotificationHubClientProvider _notificationHubClientProvider;

        public UpdateRendezVousNotificationHandler(
            ILogger<UpdateRendezVousNotificationHandler> logger,
            DentisteContext dbContext,
            INotificationHubClientProvider notificationHubClientProvider)
        {
            _logger = logger;
            _dbContext = dbContext;
            _notificationHubClientProvider = notificationHubClientProvider;
        }

        public async Task<Result> Handle(UpdateRendezVousNotificationCommand request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("Processing updated appointment notification for RendezVousId: {RdvId}", request.RendezVousId);

            var rdv = await _dbContext.RendezVous.IgnoreQueryFilters().AsNoTracking().SingleOrDefaultAsync(r => r.Id == request.RendezVousId, cancellationToken);
            var dateStr = rdv != null ? rdv.DateHeure.ToString("dd/MM/yyyy HH:mm") : "inconnue";

            var patient = await _dbContext.Patients.IgnoreQueryFilters().AsNoTracking().SingleOrDefaultAsync(p => p.Id == request.PatientId, cancellationToken);
            if (patient == null)
            {
                _logger.LogWarning("Patient not found for ID: {PatientId}", request.PatientId);
                return Result.Success();
            }

            var cabinetId = patient.CabinetId;

            // Load patient user account to send the in-app notification
            var patientUser = await _dbContext.Users
                .IgnoreQueryFilters()
                .AsNoTracking()
                .FirstOrDefaultAsync(u => u.Email == patient.Email && u.RoleId == 4 && u.IsActive, cancellationToken);

            if (patientUser == null)
            {
                _logger.LogWarning("Patient User account not found for email: {Email}", patient.Email);
                return Result.Success();
            }

            string title = "Statut de votre Rendez-vous";
            string description = $"Le statut de votre rendez-vous a changé.";

            if (request.Statut == "Planifie" || request.Statut == "Confirme" || request.Statut == "Confirmé")
            {
                title = "Demande de rendez-vous acceptée";
                description = $"Votre demande de RDV a été acceptée et planifiée pour le {dateStr}.";
            }
            else if (request.Statut == "Annule" || request.Statut == "Annulé")
            {
                title = "Demande de rendez-vous rejetée";
                description = $"Votre demande de RDV du {dateStr} a été rejetée par le secrétariat.";
            }

            var notification = new NotificationDao
            {
                Title = title,
                Description = description,
                EntityId = request.RendezVousId,
                EntityCode = "RDV",
                DateRappel = DateTime.UtcNow,
                Domaine = NotificationDomaine.RendezVous,
                CreatedBy = request.CreatedBy,
                CreatedTo = patientUser.Id,
                Nature = NotificationNature.Evenement,
                IsSeen = false,
                DemandeId = request.RendezVousId,
                Type = NotificationType.MiseAJour,
                CabinetId = cabinetId
            };

            _dbContext.Notifications.Add(notification);
            await _dbContext.SaveChangesAsync(cancellationToken);

            // Send Real-time SignalR Notification
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

            try
            {
                await _notificationHubClientProvider.Get(notification.CreatedTo).ReceiveMessage(payload);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to dispatch SignalR notification to user {UserId}", notification.CreatedTo);
            }

            return Result.Success();
        }
    }
}
