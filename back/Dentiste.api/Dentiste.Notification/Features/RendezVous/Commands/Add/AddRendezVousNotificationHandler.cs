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

namespace Dentiste.Notification.Features.RendezVous.Commands.Add
{
    public class AddRendezVousNotificationHandler : IRequestHandler<AddRendezVousNotificationCommand, Result>
    {
        private readonly ILogger<AddRendezVousNotificationHandler> _logger;
        private readonly DentisteContext _dbContext;
        private readonly ITemplateRender _templateRender;
        private readonly RendezVousUsersProvider _usersProvider;
        private readonly IEmailService _emailSender;
        private readonly IEmailRenderSubject _emailRenderSubject;
        private readonly INotificationHubClientProvider _notificationHubClientProvider;

        private IList<UserDao> _notificationUsers = new List<UserDao>();
        private string _titleTemplateRender = string.Empty;
        private string _descriptionTemplateRender = string.Empty;
        private string _contentTemplateRender = string.Empty;

        public AddRendezVousNotificationHandler(
            ILogger<AddRendezVousNotificationHandler> logger,
            DentisteContext dbContext,
            ITemplateRender templateRender,
            RendezVousUsersProvider usersProvider,
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

        public async Task<Result> Handle(AddRendezVousNotificationCommand request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("Processing appointment notification for RendezVousId: {RdvId}", request.RendezVousId);

            _notificationUsers = await _usersProvider.Get(request.DentisteId, cancellationToken);
            if (!_notificationUsers.Any())
            {
                _logger.LogWarning("No dentist found to notify for DentistId: {DentisteId}", request.DentisteId);
                return Result.Success();
            }

            var patient = await _dbContext.Patients.IgnoreQueryFilters().AsNoTracking().SingleOrDefaultAsync(p => p.Id == request.PatientId, cancellationToken);
            var patientName = patient != null ? $"{patient.Prenom} {patient.Nom}" : "Patient";
            var cabinetId = patient?.CabinetId ?? 1;

            var notifTemplateData = new
            {
                RendezVousId = request.RendezVousId,
                PatientName = patientName
            };

            // Render Liquid templates (using dot convention matching how Embedded Resources helper operates)
            _titleTemplateRender = await _templateRender.Render("templates.RendezVous.add-rendezvous.title.liquid", notifTemplateData);
            _descriptionTemplateRender = await _templateRender.Render("templates.RendezVous.add-rendezvous.desc.liquid", notifTemplateData);
            _contentTemplateRender = await _templateRender.Render("templates.RendezVous.add-rendezvous.notif.liquid", notifTemplateData);

            // 1. Send System Notification (Database)
            var notifications = await SendSystemNotification(request, cabinetId, cancellationToken);

            // 2. Send Real-time Notification (SignalR)
            await SendRealtimeNotification(notifications, cancellationToken);

            // 3. Send Email Notification
            try
            {
                await SendEmailNotification(request, patientName, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to send email notification for appointment {RdvId}", request.RendezVousId);
            }

            return Result.Success();
        }

        private async Task<List<NotificationDao>> SendSystemNotification(
            AddRendezVousNotificationCommand request,
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
            AddRendezVousNotificationCommand request,
            string patientName,
            CancellationToken cancellationToken)
        {
            foreach (var user in _notificationUsers)
            {
                if (string.IsNullOrWhiteSpace(user.Email)) continue;

                var emailTemplateData = new
                {
                    PatientName = patientName,
                    Destinateur = $"{user.Prenom} {user.Nom}",
                    Date = DateTime.Now.ToString("dd/MM/yyyy")
                };

                var emailContent = await _templateRender.Render("templates.RendezVous.add-rendezvous.email.liquid", emailTemplateData);
                
                await _emailSender.Send(new AppEmail
                {
                    To = user.Email,
                    Destinateur = $"{user.Prenom} {user.Nom}",
                    Subject = "Nouveau Rendez-vous",
                    Template = "templates.RendezVous.add-rendezvous.email.liquid",
                    BodyTemplate = emailContent,
                    CabinetId = user.CabinetId
                });
            }
        }
    }
}
