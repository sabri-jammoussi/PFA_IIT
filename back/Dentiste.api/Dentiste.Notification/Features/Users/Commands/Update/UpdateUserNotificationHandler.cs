using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Dentiste.Core.Shared;
using Dentiste.Data.Enums;
using Dentiste.Data.Infrastructure.EF;
using Dentiste.Data.Models;
using Dentiste.Notification.Core.Mailing;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Dentiste.Notification.Features.Users.Commands.Update
{
    public class UpdateUserNotificationHandler : IRequestHandler<UpdateUserNotificationCommand, Result>
    {
        private readonly ILogger<UpdateUserNotificationHandler> _logger;
        private readonly DentisteContext _dbContext;
        private readonly ITemplateRender _templateRender;
        private readonly IEmailService _emailSender;

        public UpdateUserNotificationHandler(
            ILogger<UpdateUserNotificationHandler> logger,
            DentisteContext dbContext,
            ITemplateRender templateRender,
            IEmailService emailSender)
        {
            _logger = logger;
            _dbContext = dbContext;
            _templateRender = templateRender;
            _emailSender = emailSender;
        }

        public async Task<Result> Handle(UpdateUserNotificationCommand request, CancellationToken cancellationToken)
        {
            // Only send update email if the user role is Secretary (Role ID 3)
            if (request.RoleId != 3)
            {
                _logger.LogInformation("Skipping user email update notification for Role ID: {RoleId}", request.RoleId);
                return Result.Success();
            }

            _logger.LogInformation("Processing secretary update email for UserId: {UserId}, Email: {Email}", request.Id, request.Email);

            var templateData = new
            {
                Prenom = request.Prenom,
                Nom = request.Nom,
                Username = request.Username,
                Email = request.Email,
                Password = request.Password,
                HasNewPassword = !string.IsNullOrEmpty(request.Password),
                IsActive = request.IsActive
            };

            try
            {
                var title = await _templateRender.Render("templates.Users.update-user.title.liquid", templateData);
                var emailContent = await _templateRender.Render("templates.Users.update-user.email.liquid", templateData);

                await _emailSender.Send(new AppEmail
                {
                    To = request.Email,
                    Destinateur = $"{request.Prenom} {request.Nom}",
                    Subject = string.IsNullOrWhiteSpace(title) ? "Mise à jour de votre compte Secrétaire" : title.Trim(),
                    Template = "templates.Users.update-user.email.liquid",
                    BodyTemplate = emailContent,
                    CabinetId = request.CabinetId
                });

                _logger.LogInformation("Secretary update email sent successfully to {Email}", request.Email);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to send secretary welcome email update to {Email}", request.Email);
            }

            // Create in-app system notification for the secretary
            try
            {
                var descTemplate = await _templateRender.Render("templates.Users.update-user.desc.liquid", templateData);

                var notif = new NotificationDao
                {
                    Title = "Compte Secrétaire Mis à Jour",
                    Description = string.IsNullOrWhiteSpace(descTemplate) ? $"Les détails du compte de la secrétaire {request.Prenom} {request.Nom} ont été modifiés." : descTemplate.Trim(),
                    EntityId = request.Id,
                    EntityCode = "USR",
                    DateRappel = DateTime.UtcNow,
                    Domaine = NotificationDomaine.Aucun,
                    CreatedBy = request.Id,
                    CreatedTo = request.Id,
                    Nature = NotificationNature.Evenement,
                    IsSeen = false,
                    DemandeId = request.Id,
                    Type = NotificationType.MiseAJour,
                    CabinetId = request.CabinetId ?? 1
                };

                _dbContext.Notifications.Add(notif);
                await _dbContext.SaveChangesAsync(cancellationToken);
                _logger.LogInformation("In-app update notification created for secretary UserId: {UserId}", request.Id);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to create in-app update notification for secretary UserId: {UserId}", request.Id);
            }

            return Result.Success();
        }
    }
}
