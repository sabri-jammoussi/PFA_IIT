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

namespace Dentiste.Notification.Features.Users.Commands.Add
{
    public class AddUserNotificationHandler : IRequestHandler<AddUserNotificationCommand, Result>
    {
        private readonly ILogger<AddUserNotificationHandler> _logger;
        private readonly DentisteContext _dbContext;
        private readonly ITemplateRender _templateRender;
        private readonly IEmailService _emailSender;

        public AddUserNotificationHandler(
            ILogger<AddUserNotificationHandler> logger,
            DentisteContext dbContext,
            ITemplateRender templateRender,
            IEmailService emailSender)
        {
            _logger = logger;
            _dbContext = dbContext;
            _templateRender = templateRender;
            _emailSender = emailSender;
        }

        public async Task<Result> Handle(AddUserNotificationCommand request, CancellationToken cancellationToken)
        {
            // Only send invitation email if the user role is Secretary (Role ID 3)
            if (request.RoleId != 3)
            {
                _logger.LogInformation("Skipping user email invitation for Role ID: {RoleId}", request.RoleId);
                return Result.Success();
            }

            _logger.LogInformation("Processing secretary invitation email for UserId: {UserId}, Email: {Email}", request.Id, request.Email);

            var templateData = new
            {
                Prenom = request.Prenom,
                Nom = request.Nom,
                Username = request.Username,
                Email = request.Email,
                Password = request.Password
            };

            try
            {
                var title = await _templateRender.Render("templates.Users.add-user.title.liquid", templateData);
                var emailContent = await _templateRender.Render("templates.Users.add-user.email.liquid", templateData);

                await _emailSender.Send(new AppEmail
                {
                    To = request.Email,
                    Destinateur = $"{request.Prenom} {request.Nom}",
                    Subject = title.Trim(),
                    Template = "templates.Users.add-user.email.liquid",
                    BodyTemplate = emailContent,
                    CabinetId = request.CabinetId
                });

                _logger.LogInformation("Secretary invitation email sent successfully to {Email}", request.Email);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to send secretary welcome email to {Email}", request.Email);
                // We do not fail the execution so that the in-app notification is still written.
            }

            // Create in-app system notification for the secretary
            try
            {
                var descTemplate = await _templateRender.Render("templates.Users.add-user.desc.liquid", templateData);

                var notif = new NotificationDao
                {
                    Title = "Compte Secrétaire Créé",
                    Description = descTemplate.Trim(),
                    EntityId = request.Id,
                    EntityCode = "USR",
                    DateRappel = DateTime.UtcNow,
                    Domaine = NotificationDomaine.Aucun,
                    CreatedBy = request.Id, // welcome notification
                    CreatedTo = request.Id,
                    Nature = NotificationNature.Evenement,
                    IsSeen = false,
                    DemandeId = request.Id,
                    Type = NotificationType.Creation,
                    CabinetId = request.CabinetId ?? 1
                };

                _dbContext.Notifications.Add(notif);
                await _dbContext.SaveChangesAsync(cancellationToken);
                _logger.LogInformation("In-app notification created for new secretary UserId: {UserId}", request.Id);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to create in-app notification for new secretary UserId: {UserId}", request.Id);
            }

            return Result.Success();
        }
    }
}
