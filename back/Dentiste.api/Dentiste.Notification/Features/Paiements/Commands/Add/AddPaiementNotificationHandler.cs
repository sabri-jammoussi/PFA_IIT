using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Dentiste.Core.Shared;
using Dentiste.Data.Enums;
using Dentiste.Data.Infrastructure.EF;
using Dentiste.Data.Models;
using Dentiste.Notification.Core.Mailing;
using Dentiste.Notification.Hubs;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Dentiste.Notification.Features.Paiements.Commands.Add
{
    public class AddPaiementNotificationHandler : IRequestHandler<AddPaiementNotificationCommand, Result>
    {
        private readonly ILogger<AddPaiementNotificationHandler> _logger;
        private readonly DentisteContext _dbContext;
        private readonly ITemplateRender _templateRender;
        private readonly PaiementsUsersProvider _usersProvider;
        private readonly IEmailService _emailSender;
        private readonly IEmailRenderSubject _emailRenderSubject;
        private readonly INotificationHubClientProvider _notificationHubClientProvider;

        private IList<UserDao> _notificationUsers = new List<UserDao>();
        private string _titleTemplateRender = string.Empty;
        private string _descriptionTemplateRender = string.Empty;
        private string _contentTemplateRender = string.Empty;

        public AddPaiementNotificationHandler(
            ILogger<AddPaiementNotificationHandler> logger,
            DentisteContext dbContext,
            ITemplateRender templateRender,
            PaiementsUsersProvider usersProvider,
            IEmailService emailSender,
            IEmailRenderSubject emailRenderSubject,
            INotificationHubClientProvider notificationHubClientProvider)
        {
            _logger = logger;
            _dbContext = dbContext;
            _templateRender = templateRender;
            _usersProvider = usersProvider;
            _emailSender = emailSender;
            _emailRenderSubject = emailRenderSubject;
            _notificationHubClientProvider = notificationHubClientProvider;
        }

        public async Task<Result> Handle(AddPaiementNotificationCommand request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("Processing payment notification for PaiementId: {PaiementId}", request.PaiementId);

            var facture = await _dbContext.Factures
                .IgnoreQueryFilters()
                .Include(f => f.Patient)
                .AsNoTracking()
                .SingleOrDefaultAsync(f => f.Id == request.FactureId, cancellationToken);

            if (facture == null)
            {
                _logger.LogWarning("Facture not found for payment notification: {FactureId}", request.FactureId);
                return Result.Success();
            }

            _notificationUsers = await _usersProvider.Get(facture.CabinetId, cancellationToken);
            if (!_notificationUsers.Any())
            {
                _logger.LogWarning("No users found to notify for payment in cabinet {CabinetId}", facture.CabinetId);
                return Result.Success();
            }

            var patientName = facture.Patient != null ? $"{facture.Patient.Prenom} {facture.Patient.Nom}" : "Patient";
            var numeroFacture = facture.NumeroFacture ?? $"#{request.FactureId}";

            var notifTemplateData = new
            {
                PaiementId = request.PaiementId,
                FactureId = request.FactureId,
                NumeroFacture = numeroFacture,
                Montant = request.Montant,
                PatientName = patientName
            };

            // Render templates
            _titleTemplateRender = await _templateRender.Render("templates.Paiements.add-paiement.title.liquid", notifTemplateData);
            _descriptionTemplateRender = await _templateRender.Render("templates.Paiements.add-paiement.desc.liquid", notifTemplateData);
            _contentTemplateRender = await _templateRender.Render("templates.Paiements.add-paiement.notif.liquid", notifTemplateData);

            // 1. Send System Notification (Database)
            var notifications = await SendSystemNotification(request, facture.CabinetId, cancellationToken);

            // 2. Send Real-time Notification (SignalR)
            await SendRealtimeNotification(notifications, cancellationToken);

            // 3. Send Email Notification
            try
            {
                await SendEmailNotification(request, numeroFacture, request.Montant, patientName, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to send email notification for payment {PaiementId}", request.PaiementId);
            }

            return Result.Success();
        }

        private async Task<List<NotificationDao>> SendSystemNotification(
            AddPaiementNotificationCommand request,
            int cabinetId,
            CancellationToken cancellationToken)
        {
            var list = new List<NotificationDao>();
            foreach (var user in _notificationUsers)
            {
                var notif = new NotificationDao
                {
                    Title = _titleTemplateRender,
                    Description = _descriptionTemplateRender,
                    EntityId = request.PaiementId,
                    EntityCode = "PAY",
                    DateRappel = DateTime.UtcNow,
                    Domaine = NotificationDomaine.Facture,
                    CreatedBy = request.CreatedBy,
                    CreatedTo = user.Id,
                    Nature = NotificationNature.Evenement,
                    IsSeen = false,
                    DemandeId = request.FactureId,
                    Type = NotificationType.Information,
                    CabinetId = user.CabinetId ?? cabinetId
                };
                list.Add(notif);
            }

            if (list.Any())
            {
                _dbContext.Notifications.AddRange(list);
                await _dbContext.SaveChangesAsync(cancellationToken);
            }

            return list;
        }

        private async Task SendRealtimeNotification(
            List<NotificationDao> notifications,
            CancellationToken cancellationToken)
        {
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
        }

        private async Task SendEmailNotification(
            AddPaiementNotificationCommand request,
            string numeroFacture,
            decimal montant,
            string patientName,
            CancellationToken cancellationToken)
        {
            foreach (var user in _notificationUsers)
            {
                if (string.IsNullOrWhiteSpace(user.Email)) continue;

                var emailTemplateData = new
                {
                    NumeroFacture = numeroFacture,
                    Montant = montant,
                    PatientName = patientName,
                    Destinateur = $"{user.Prenom} {user.Nom}",
                    Date = DateTime.Now.ToString("dd/MM/yyyy")
                };

                var emailContent = await _templateRender.Render("templates.Paiements.add-paiement.email.liquid", emailTemplateData);

                await _emailSender.Send(new AppEmail
                {
                    To = user.Email,
                    Destinateur = $"{user.Prenom} {user.Nom}",
                    Subject = "Facture réglée",
                    Template = "templates.Paiements.add-paiement.email.liquid",
                    BodyTemplate = emailContent,
                    CabinetId = user.CabinetId
                });
            }
        }
    }
}
