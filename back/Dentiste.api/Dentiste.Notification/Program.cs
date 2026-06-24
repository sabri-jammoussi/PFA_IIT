using Hangfire;
using Hangfire.SqlServer;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using Dentiste.Core.Infrastructure.Security;
using Dentiste.Data;
using Dentiste.Data.Infrastructure.EF;
using Dentiste.Notification.Core;
using Dentiste.Notification.Hubs;
using Dentiste.Notification.Features.Notifications.Mappers;
using Dentiste.Notification.Core.Mailing;
using Dentiste.Notification.Features.Auth.Mappers;
using Dentiste.Notification.Features.RendezVous;
using Dentiste.Notification.Features.Paiements;
using Dentiste.Notification.Features.Patients;

namespace Dentiste.Notification
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // ── Database ──
            builder.Services.AddDbContext<DentisteContext>(options =>
                options.UseSqlServer(builder.Configuration.GetConnectionString("APP")));

            // ── CORS (restricted to configured frontend origins) ──
            var allowedOrigins = builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>()
                ?? new[] { "http://localhost:5173", "http://localhost:8080" };
            builder.Services.AddCors(options =>
            {
                options.AddDefaultPolicy(policy =>
                {
                    policy.SetIsOriginAllowed(origin => true)
                          .AllowAnyHeader()
                          .AllowAnyMethod()
                          .AllowCredentials(); // Required for SignalR
                });
            });

            // ── Standard WebAPI & Controllers ──
            builder.Services.AddControllers();

            // ── HttpContext Accessor & Current User ──
            builder.Services.AddHttpContextAccessor();
            builder.Services.AddScoped<Dentiste.Data.Infrastructure.ITenantProvider, Dentiste.Core.Infrastructure.Tenant.TenantProvider>();
            builder.Services.AddScoped<ICurrentUserProvider, CurrentUserProvider>();

            // ── SignalR Hub Client Provider ──
            builder.Services.AddTransient<INotificationHubClientProvider, NotificationHubClientProvider>();

            // ── Core Mailing & Templating ──
            builder.Services.AddTransient<ITextFileReader, TextFileReader>();
            builder.Services.AddTransient<ITemplateRender, LiquidTemplateRender>();
            builder.Services.AddTransient<IEmailRenderSubject, EmailRenderSubject>();
            builder.Services.AddTransient<IEmailService, EmailService>();

            // ── Notification Recipient Providers ──
            builder.Services.AddTransient<RendezVousUsersProvider>();
            builder.Services.AddTransient<PaiementsUsersProvider>();
            builder.Services.AddTransient<PatientsUsersProvider>();
            builder.Services.AddTransient<Dentiste.Notification.Features.Consultations.ConsultationsUsersProvider>();

            // ── Keyed Event Mappers ──
            builder.Services.AddKeyedTransient<IEventCommandMapper, AddRendezVousMapper>(NotificationEventCommand.AddRendezVous);
            builder.Services.AddKeyedTransient<IEventCommandMapper, AddPaiementMapper>(NotificationEventCommand.AddPaiement);
            builder.Services.AddKeyedTransient<IEventCommandMapper, FinalizeConsultationMapper>(NotificationEventCommand.FinalizeConsultation);
            builder.Services.AddKeyedTransient<IEventCommandMapper, UpdatePatientMapper>(NotificationEventCommand.UpdatePatient);
            builder.Services.AddKeyedTransient<IEventCommandMapper, InvitePatientMapper>(NotificationEventCommand.InvitePatient);
            builder.Services.AddKeyedTransient<IEventCommandMapper, RegisterClinicMapper>("register-clinic");
            builder.Services.AddKeyedTransient<IEventCommandMapper, AddUserMapper>("add-user");
            builder.Services.AddKeyedTransient<IEventCommandMapper, RequestAppointmentMapper>("request-appointment");
            builder.Services.AddKeyedTransient<IEventCommandMapper, UpdateRendezVousMapper>("update-rendezvous");
            builder.Services.AddKeyedTransient<IEventCommandMapper, UpdateUserMapper>("update-user");
            builder.Services.AddKeyedTransient<IEventCommandMapper, ForgetPasswordMapper>("forget-password");

            // ── SignalR ──
            builder.Services.AddSignalR(options =>
            {
                options.ClientTimeoutInterval = TimeSpan.FromSeconds(60);
                options.KeepAliveInterval = TimeSpan.FromSeconds(15);
                options.EnableDetailedErrors = true;
                options.MaximumReceiveMessageSize = null;
            });

            // ── MediatR ──
            builder.Services.AddMediatR(config =>
            {
                config.RegisterServicesFromAssembly(typeof(Program).Assembly);
            });

            // ── JWT Settings & Authentication ──
            builder.Services.Configure<JwtSettings>(builder.Configuration.GetSection("Jwt"));
            var jwtSettings = builder.Configuration.GetSection("Jwt").Get<JwtSettings>()!;

            if (string.IsNullOrWhiteSpace(jwtSettings.SecurityKey)
                || Encoding.UTF8.GetByteCount(jwtSettings.SecurityKey) < 32)
            {
                throw new InvalidOperationException(
                    "JWT signing key is missing or too short. Set 'Jwt:SecurityKey' (>= 32 bytes) " +
                    "via environment variable (Jwt__SecurityKey), user-secrets, or appsettings.Development.json.");
            }

            builder.Services
                .AddAuthentication(options =>
                {
                    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
                    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
                })
                .AddJwtBearer(options =>
                {
                    options.TokenValidationParameters = new TokenValidationParameters
                    {
                        ValidateIssuerSigningKey = true,
                        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSettings.SecurityKey)),
                        ValidateIssuer = true,
                        ValidIssuer = jwtSettings.Issuer,
                        ValidateAudience = true,
                        ValidAudience = jwtSettings.Audience,
                        ValidateLifetime = true,
                        ClockSkew = TimeSpan.Zero
                    };

                    options.Events = new JwtBearerEvents
                    {
                        OnMessageReceived = context =>
                        {
                            var authHeader = context.HttpContext.Request.Headers.Authorization.FirstOrDefault();
                            if (!string.IsNullOrEmpty(authHeader))
                            {
                                if (authHeader.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
                                {
                                    context.Token = authHeader.Substring("Bearer ".Length).Trim();
                                    return Task.CompletedTask;
                                }
                            }

                            // Extract the access token from the query string if request is for SignalR Hub
                            var path = context.HttpContext.Request.Path;
                            if (path.StartsWithSegments("/hubs"))
                            {
                                var accessToken = context.HttpContext.Request.Query
                                    .FirstOrDefault(q => q.Key.Equals("access_token", StringComparison.OrdinalIgnoreCase))
                                    .Value;

                                if (!string.IsNullOrEmpty(accessToken))
                                {
                                    context.Token = accessToken;
                                }
                            }

                            return Task.CompletedTask;
                        }
                    };
                });

            builder.Services.AddAuthorization();

            // ── OpenApi ──
            builder.Services.AddOpenApi();

            // ── Hangfire Storage ──
            builder.Services.AddHangfire(config =>
            {
                config.UseSqlServerStorage(builder.Configuration.GetConnectionString("APP"),
                    new SqlServerStorageOptions
                    {
                        PrepareSchemaIfNecessary = true,
                        QueuePollInterval = TimeSpan.FromSeconds(2)
                    });
            });

            // ── Hangfire Server ──
            builder.Services.AddHangfireServer(options =>
            {
                options.ServerName = "DENTIST.NOTIF";
                options.Queues = new[] { "010_notif" };
            });

            var app = builder.Build();

            // Configure the HTTP request pipeline.
            if (app.Environment.IsDevelopment())
            {
                app.MapOpenApi();
            }

            app.UseCors();
            app.UseWebSockets();

            app.UseRouting();

            app.UseAuthentication();
            app.UseAuthorization();

            app.MapControllers();
            app.MapHub<NotificationHub>("/hubs/notif");

            app.Run();
        }
    }
}
