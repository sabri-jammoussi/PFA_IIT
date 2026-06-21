using MediatR;
using Microsoft.Extensions.Logging;
using Dentiste.Core.Shared;
using Dentiste.Notification.Core.Mailing;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Dentiste.Notification.Features.Auth.Commands.ForgetPassword
{
    public class ForgetPasswordNotificationHandler : IRequestHandler<ForgetPasswordNotificationCommand, Result>
    {
        private readonly ILogger<ForgetPasswordNotificationHandler> _logger;
        private readonly ITemplateRender _templateRender;
        private readonly IEmailService _emailSender;

        public ForgetPasswordNotificationHandler(
            ILogger<ForgetPasswordNotificationHandler> logger,
            ITemplateRender templateRender,
            IEmailService emailSender)
        {
            _logger = logger;
            _templateRender = templateRender;
            _emailSender = emailSender;
        }

        public async Task<Result> Handle(ForgetPasswordNotificationCommand request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("Processing forget password email for Email: {Email}", request.Email);

            // Data to inject into the template
            var templateData = new
            {
                Host = request.Host,
                NomPrenom = request.NomPrenom,
                NewPassword = request.NewPassword,
                Year = DateTime.UtcNow.Year
            };

            try
            {
                var title = await _templateRender.Render("templates.Auth.forget-password.title.liquid", templateData);
                var emailContent = await _templateRender.Render("templates.Auth.forget-password.email.liquid", templateData);

                await _emailSender.Send(new AppEmail
                {
                    To = request.Email,
                    Destinateur = request.NomPrenom,
                    Subject = title.Trim(),
                    Template = "templates.Auth.forget-password.email.liquid",
                    BodyTemplate = emailContent
                });

                _logger.LogInformation("Forget password email sent successfully to {Email}", request.Email);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to send forget password email to {Email}", request.Email);
                return Result.Failure("Failed to send forget password email.");
            }

            return Result.Success();
        }
    }
}
