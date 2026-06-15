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
using System.Threading;
using System.Threading.Tasks;

namespace Dentiste.Notification.Features.Patients.Commands.Invite
{
    public class InvitePatientNotificationHandler : IRequestHandler<InvitePatientNotificationCommand, Result>
    {
        private readonly ILogger<InvitePatientNotificationHandler> _logger;
        private readonly DentisteContext _dbContext;
        private readonly ITemplateRender _templateRender;
        private readonly IEmailService _emailSender;

        public InvitePatientNotificationHandler(
            ILogger<InvitePatientNotificationHandler> logger,
            DentisteContext dbContext,
            ITemplateRender templateRender,
            IEmailService emailSender)
        {
            _logger = logger;
            _dbContext = dbContext;
            _templateRender = templateRender;
            _emailSender = emailSender;
        }

        public async Task<Result> Handle(InvitePatientNotificationCommand request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("Processing patient invitation notification for PatientId: {PatientId}, Email: {Email}", request.PatientId, request.Email);

            var notifTemplateData = new
            {
                PatientId = request.PatientId,
                Nom = request.Nom,
                Prenom = request.Prenom,
                Email = request.Email,
                TemporaryPassword = request.TemporaryPassword
            };

            // Render email subject & content templates
            var title = await _templateRender.Render("templates.Patients.invite-patient.title.liquid", notifTemplateData);
            var desc = await _templateRender.Render("templates.Patients.invite-patient.desc.liquid", notifTemplateData);
            var emailContent = await _templateRender.Render("templates.Patients.invite-patient.email.liquid", notifTemplateData);

            // 1. Fetch patient and user account records to resolve cabinet context and user IDs
            var patient = await _dbContext.Patients
                .IgnoreQueryFilters()
                .AsNoTracking()
                .FirstOrDefaultAsync(p => p.Email == request.Email, cancellationToken);

            var userAccount = await _dbContext.Users
                .IgnoreQueryFilters()
                .AsNoTracking()
                .FirstOrDefaultAsync(u => u.Email == request.Email, cancellationToken);

            var cabinetId = patient?.CabinetId;

            // 2. Send welcome email to patient
            try
            {
                await _emailSender.Send(new AppEmail
                {
                    To = request.Email,
                    Destinateur = $"{request.Prenom} {request.Nom}",
                    Subject = title.Trim(),
                    Template = "templates.Patients.invite-patient.email.liquid",
                    BodyTemplate = emailContent,
                    CabinetId = cabinetId
                });
                _logger.LogInformation("Invitation email sent successfully to {Email}", request.Email);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to send invitation email to {Email}. Proceeding with in-app notification creation.", request.Email);
            }

            // 3. Create in-app system notification for the patient
            if (userAccount != null)
            {
                var notif = new NotificationDao
                {
                    Title = title.Trim(),
                    Description = desc.Trim(),
                    EntityId = request.PatientId,
                    EntityCode = "PAT",
                    DateRappel = DateTime.UtcNow,
                    Domaine = NotificationDomaine.Patient,
                    CreatedBy = userAccount.Id, // Correctly references UserDao ID
                    CreatedTo = userAccount.Id,
                    Nature = NotificationNature.Evenement,
                    IsSeen = false,
                    DemandeId = request.PatientId,
                    Type = NotificationType.Creation,
                    CabinetId = cabinetId ?? 1
                };

                _dbContext.Notifications.Add(notif);
                await _dbContext.SaveChangesAsync(cancellationToken);
            }

            return Result.Success();
        }
    }
}
