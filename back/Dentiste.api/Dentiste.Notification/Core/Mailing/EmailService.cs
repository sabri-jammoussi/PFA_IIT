using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Net;
using System.Net.Mail;
using System.Threading.Tasks;
using System.Linq;
using Microsoft.EntityFrameworkCore;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Notification.Core.Mailing
{
    public class EmailService : IEmailService
    {
        private readonly ILogger<EmailService> _logger;
        private readonly IConfiguration _configuration;
        private readonly DentisteContext _dbContext;

        public EmailService(ILogger<EmailService> logger, IConfiguration configuration, DentisteContext dbContext)
        {
            _logger = logger;
            _configuration = configuration;
            _dbContext = dbContext;
        }

        public async Task Send(AppEmail email)
        {
            _logger.LogInformation("Attempting to send email to {To} ({Name}): {Subject}", email.To, email.Destinateur, email.Subject);
            
            string? host = null;
            string? portStr = null;
            string? username = null;
            string? password = null;
            bool enableSsl = false;
            string? senderName = null;

            // 1. Try to load cabinet-specific SMTP configuration
            if (email.CabinetId !=null)
            {
                try
                {
                    // Ignore query filters since background tasks run outside request tenant context
                    var cabinetConfig = await _dbContext.ConfigurationsCabinets
                        .IgnoreQueryFilters()
                        .FirstOrDefaultAsync(c => c.CabinetId == email.CabinetId.Value);

                    if (cabinetConfig != null && !string.IsNullOrEmpty(cabinetConfig.SmtpHost) && !string.IsNullOrEmpty(cabinetConfig.SmtpUsername))
                    {
                        host = cabinetConfig.SmtpHost;
                        portStr = cabinetConfig.SmtpPort?.ToString() ?? "587";
                        username = cabinetConfig.SmtpUsername;
                        password = cabinetConfig.SmtpPassword;
                        enableSsl = cabinetConfig.SmtpEnableSsl ?? true;
                        senderName = cabinetConfig.SenderName;
                        _logger.LogInformation("Using cabinet-specific SMTP settings for CabinetId: {CabinetId}", email.CabinetId.Value);
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Failed to load custom SMTP configuration for CabinetId: {CabinetId}. Falling back to default settings.", email.CabinetId.Value);
                }
            }

            // 2. Fallback to global database option settings
            if (string.IsNullOrEmpty(host) || string.IsNullOrEmpty(username))
            {
                try
                {
                    var dbOptions = await _dbContext.Options
                        .IgnoreQueryFilters()
                        .Where(o => o.Group == "SMTP")
                        .ToListAsync();

                    var dbHost = dbOptions.FirstOrDefault(o => o.Name == "smtp.host")?.Value;
                    var dbPort = dbOptions.FirstOrDefault(o => o.Name == "smtp.port")?.Value;
                    var dbUsername = dbOptions.FirstOrDefault(o => o.Name == "smtp.username")?.Value;
                    var dbPassword = dbOptions.FirstOrDefault(o => o.Name == "smtp.password")?.Value;
                    var dbSsl = dbOptions.FirstOrDefault(o => o.Name == "smtp.ssl")?.Value;

                    if (!string.IsNullOrEmpty(dbHost) && !string.IsNullOrEmpty(dbUsername))
                    {
                        host = dbHost;
                        portStr = dbPort ?? "587";
                        username = dbUsername;
                        password = dbPassword;
                        enableSsl = dbSsl == "true";
                        senderName = "Cabinet Dentaire";
                        _logger.LogInformation("Using global database SMTP settings from OPTION table.");
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Failed to load global database SMTP settings from OPTION table.");
                }
            }

            // 3. Fallback to global application configuration settings
            if (string.IsNullOrEmpty(host) || string.IsNullOrEmpty(username))
            {
                host = _configuration["Smtp:Host"];
                portStr = _configuration["Smtp:Port"];
                username = _configuration["Smtp:Username"];
                password = _configuration["Smtp:Password"];
                enableSsl = _configuration.GetValue<bool>("Smtp:EnableSsl");
                senderName = _configuration["Smtp:SenderName"] ?? "Cabinet Dentaire";
                _logger.LogInformation("Using global fallback SMTP settings from appsettings.");
            }

            if (string.IsNullOrEmpty(host) || string.IsNullOrEmpty(username))
            {
                _logger.LogWarning("SMTP settings not configured. Log-delivery fallback:\n--- Email Begin ---\nTo: {To}\nSubject: {Subject}\nBody:\n{Body}\n--- Email End ---", 
                    email.To, email.Subject, email.BodyTemplate);
                return;
            }

            try
            {
                using var client = new SmtpClient(host, int.Parse(portStr ?? "587"))
                {
                    Credentials = new NetworkCredential(username, password),
                    EnableSsl = enableSsl
                };

                using var mailMessage = new MailMessage
                {
                    From = new MailAddress(username, senderName),
                    Subject = email.Subject,
                    Body = email.BodyTemplate,
                    IsBodyHtml = true
                };

                mailMessage.To.Add(new MailAddress(email.To, email.Destinateur));

                await client.SendMailAsync(mailMessage);
                 _logger.LogInformation("Email successfully sent to {To}", email.To);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to send email to {To}", email.To);
                throw;
            }
        }
    }
}
