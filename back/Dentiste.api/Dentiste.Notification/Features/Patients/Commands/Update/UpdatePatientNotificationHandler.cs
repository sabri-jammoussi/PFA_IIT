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

namespace Dentiste.Notification.Features.Patients.Commands.Update
{
    public class UpdatePatientNotificationHandler : IRequestHandler<UpdatePatientNotificationCommand, Result>
    {
        private readonly ILogger<UpdatePatientNotificationHandler> _logger;
        private readonly DentisteContext _dbContext;
        private readonly ITemplateRender _templateRender;
        private readonly PatientsUsersProvider _usersProvider;
        private readonly IEmailService _emailSender;
        private readonly IEmailRenderSubject _emailRenderSubject;
        private readonly INotificationHubClientProvider _notificationHubClientProvider;

        private IList<UserDao> _notificationUsers = new List<UserDao>();
        private string _titleTemplateRender = string.Empty;
        private string _descriptionTemplateRender = string.Empty;
        private string _contentTemplateRender = string.Empty;

        public UpdatePatientNotificationHandler(
            ILogger<UpdatePatientNotificationHandler> logger,
            DentisteContext dbContext,
            ITemplateRender templateRender,
            PatientsUsersProvider usersProvider,
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

        public async Task<Result> Handle(UpdatePatientNotificationCommand request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("Processing patient update notification for PatientId: {PatientId}", request.PatientId);

            var patient = await _dbContext.Patients
                .IgnoreQueryFilters()
                .AsNoTracking()
                .SingleOrDefaultAsync(p => p.Id == request.PatientId, cancellationToken);

            if (patient == null)
            {
                _logger.LogWarning("Patient not found for update notification: {PatientId}", request.PatientId);
                return Result.Success();
            }

            _notificationUsers = await _usersProvider.Get(patient.CabinetId, request.CreatedBy, cancellationToken);
            if (!_notificationUsers.Any())
            {
                _logger.LogWarning("No other admin/dentist found to notify for patient update in cabinet {CabinetId}", patient.CabinetId);
                return Result.Success();
            }

            var notifTemplateData = new
            {
                PatientId = request.PatientId,
                Nom = request.Nom,
                Prenom = request.Prenom
            };

            // Render templates
            _titleTemplateRender = await _templateRender.Render("templates.Patients.update-patient.title.liquid", notifTemplateData);
            _descriptionTemplateRender = await _templateRender.Render("templates.Patients.update-patient.desc.liquid", notifTemplateData);
            _contentTemplateRender = await _templateRender.Render("templates.Patients.update-patient.notif.liquid", notifTemplateData);

            // 1. Send System Notification (Database)
            var notifications = await SendSystemNotification(request, patient.CabinetId, cancellationToken);

            // 2. Send Real-time Notification (SignalR)
            await SendRealtimeNotification(notifications, cancellationToken);

            // 3. Send Email Notification
            try
            {
                await SendEmailNotification(request, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to send email notification for patient update {PatientId}", request.PatientId);
            }

            return Result.Success();
        }

        private async Task<List<NotificationDao>> SendSystemNotification(
            UpdatePatientNotificationCommand request,
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
                    EntityId = request.PatientId,
                    EntityCode = "PAT",
                    DateRappel = DateTime.UtcNow,
                    Domaine = NotificationDomaine.Patient,
                    CreatedBy = request.CreatedBy,
                    CreatedTo = user.Id,
                    Nature = NotificationNature.Evenement,
                    IsSeen = false,
                    DemandeId = request.PatientId,
                    Type = NotificationType.MiseAJour,
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
            UpdatePatientNotificationCommand request,
            CancellationToken cancellationToken)
        {
            foreach (var user in _notificationUsers)
            {
                if (string.IsNullOrWhiteSpace(user.Email)) continue;

                var emailTemplateData = new
                {
                    Nom = request.Nom,
                    Prenom = request.Prenom,
                    PatientId = request.PatientId,
                    Destinateur = $"{user.Prenom} {user.Nom}",
                    Date = DateTime.Now.ToString("dd/MM/yyyy")
                };

                var emailContent = await _templateRender.Render("templates.Patients.update-patient.email.liquid", emailTemplateData);

                await _emailSender.Send(new AppEmail
                {
                    To = user.Email,
                    Destinateur = $"{user.Prenom} {user.Nom}",
                    Subject = "Dossier patient modifié",
                    Template = "templates.Patients.update-patient.email.liquid",
                    BodyTemplate = emailContent,
                    CabinetId = user.CabinetId
                });
            }
        }
    }
}
