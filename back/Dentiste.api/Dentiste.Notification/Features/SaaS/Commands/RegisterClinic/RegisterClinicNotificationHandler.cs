using MediatR;
using Microsoft.Extensions.Logging;
using Dentiste.Core.Shared;
using Dentiste.Notification.Core.Mailing;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Dentiste.Notification.Features.SaaS.Commands.RegisterClinic
{
    public class RegisterClinicNotificationHandler : IRequestHandler<RegisterClinicNotificationCommand, Result>
    {
        private readonly ILogger<RegisterClinicNotificationHandler> _logger;
        private readonly ITemplateRender _templateRender;
        private readonly IEmailService _emailSender;

        public RegisterClinicNotificationHandler(
            ILogger<RegisterClinicNotificationHandler> logger,
            ITemplateRender templateRender,
            IEmailService emailSender)
        {
            _logger = logger;
            _templateRender = templateRender;
            _emailSender = emailSender;
        }

        public async Task<Result> Handle(RegisterClinicNotificationCommand request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("Processing clinic registration welcome email for CabinetId: {CabinetId}, Email: {Email}", request.CabinetId, request.DoctorEmail);

            var templateData = new
            {
                CabinetId = request.CabinetId,
                NomCabinet = request.NomCabinet,
                DoctorEmail = request.DoctorEmail,
                DoctorNom = request.DoctorNom,
                DoctorPrenom = request.DoctorPrenom
            };

            try
            {
                var title = await _templateRender.Render("templates.SaaS.register-clinic.title.liquid", templateData);
                var emailContent = await _templateRender.Render("templates.SaaS.register-clinic.email.liquid", templateData);

                await _emailSender.Send(new AppEmail
                {
                    To = request.DoctorEmail,
                    Destinateur = $"{request.DoctorPrenom} {request.DoctorNom}",
                    Subject = title.Trim(),
                    Template = "templates.SaaS.register-clinic.email.liquid",
                    BodyTemplate = emailContent,
                    CabinetId = request.CabinetId
                });

                _logger.LogInformation("Welcome email sent successfully to {Email}", request.DoctorEmail);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to send welcome email to {Email}", request.DoctorEmail);
                return Result.Failure("Failed to send welcome email.");
            }

            return Result.Success();
        }
    }
}
