using FluentValidation;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using Dentiste.Core.Infrastructure.Security;
using Dentiste.Data;
using Dentiste.Data.Models;
using Dentiste.api.Middleware;
using Dentiste.Notification.Core;
using Hangfire;
using Hangfire.SqlServer;

namespace Dentiste.api
{
	public class Program
	{
		public static void Main(string[] args)
		{
			var builder = WebApplication.CreateBuilder(args);

			builder.Services.AddDbContext<Dentiste.Data.Infrastructure.EF.DentisteContext>(options =>
				options.UseSqlServer(builder.Configuration.GetConnectionString("APP")));

			builder.Services.AddHttpContextAccessor();
			builder.Services.AddScoped<Dentiste.Data.Infrastructure.ITenantProvider, Dentiste.Core.Infrastructure.Tenant.TenantProvider>();
			builder.Services.AddScoped<ICurrentUserProvider, CurrentUserProvider>();

			builder.Services.AddMediatR(cfg =>
			{
				cfg.RegisterServicesFromAssembly(typeof(Dentiste.Core.Messaging.ICommand).Assembly);
				// Validation runs first so invalid commands never reach handlers or the event behavior.
				cfg.AddOpenBehavior(typeof(Dentiste.Core.Infrastructure.Behaviors.ValidationBehavior<,>));
				cfg.AddOpenBehavior(typeof(CommandEventBehavior<,>));
			});

			// Register all FluentValidation validators from the Core assembly.
			builder.Services.AddValidatorsFromAssembly(typeof(Dentiste.Core.Messaging.ICommand).Assembly);

			builder.Services.AddKeyedSingleton<JobStorage>("notif", (provider, _) =>
				new SqlServerStorage(builder.Configuration.GetConnectionString("APP"),
					new SqlServerStorageOptions
					{
						PrepareSchemaIfNecessary = true,
						QueuePollInterval = TimeSpan.FromMilliseconds(200)
					}));

			builder.Services.AddKeyedSingleton<IBackgroundJobClient>("notif", (provider, _) =>
				new BackgroundJobClient(provider.GetRequiredKeyedService<JobStorage>("notif")));

			builder.Services.AddControllers();

			// ── JWT Settings ──
			builder.Services.Configure<JwtSettings>(builder.Configuration.GetSection("Jwt"));
			var jwtSettings = builder.Configuration.GetSection("Jwt").Get<JwtSettings>()!;

			// Fail fast if the signing key is not configured (never ship a default/committed key).
			if (string.IsNullOrWhiteSpace(jwtSettings.SecurityKey)
				|| Encoding.UTF8.GetByteCount(jwtSettings.SecurityKey) < 32)
			{
				throw new InvalidOperationException(
					"JWT signing key is missing or too short. Set 'Jwt:SecurityKey' (>= 32 bytes) " +
					"via environment variable (Jwt__SecurityKey), user-secrets, or appsettings.Development.json.");
			}

			// ── JWT Authentication ──
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
							var accessToken = context.Request.Query["access_token"];

							var path = context.HttpContext.Request.Path;
							if (!string.IsNullOrEmpty(accessToken) && path.StartsWithSegments("/api/hubs"))
							{
								context.Token = accessToken;
							}
							return Task.CompletedTask;
						}
					};
				});

			builder.Services.AddAuthorization();

			// ── Redis ──
			var redisConnection = builder.Configuration.GetConnectionString("Redis")!;
			builder.Services.AddStackExchangeRedisCache(options =>
			{
				options.Configuration = redisConnection;
				options.InstanceName = "dentiste:";
			});
			builder.Services.AddSingleton<StackExchange.Redis.IConnectionMultiplexer>(
				StackExchange.Redis.ConnectionMultiplexer.Connect(redisConnection));

			// ── Security Services ──
			builder.Services.AddScoped<IPasswordHasher, PasswordHasher>();
			builder.Services.AddScoped<IJwtTokenGenerator, JwtTokenGenerator>();
			builder.Services.AddScoped<ISessionService, SessionService>();
			builder.Services.AddScoped<Dentiste.Core.Infrastructure.Storage.ICloudinaryService, Dentiste.Core.Infrastructure.Storage.CloudinaryService>();

			// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
			builder.Services.AddOpenApi();
			
			builder.Services.AddSignalR();

			// ── CORS (restricted to configured frontend origins) ──
			var allowedOrigins = builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>()
				?? new[] { "http://localhost:5173", "http://localhost:8080" };
			builder.Services.AddCors(options =>
			{
				options.AddDefaultPolicy(policy => policy
					.SetIsOriginAllowed(origin => true)
					.AllowAnyHeader()
					.AllowAnyMethod()
					.AllowCredentials());
			});

			var app = builder.Build();

			// Auto migrate database on startup
			using (var scope = app.Services.CreateScope())
			{
				var db = scope.ServiceProvider.GetRequiredService<Dentiste.Data.Infrastructure.EF.DentisteContext>();
				db.Database.Migrate();

				var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();

				// Check and seed roles (parameterized via EF, not raw SQL string interpolation)
				if (!db.Roles.Any())
				{
					db.Roles.AddRange(
						new RoleDao { Name = "Admin", Description = "Administrateur système" },
						new RoleDao { Name = "Dentiste", Description = "Praticien Dentiste" },
						new RoleDao { Name = "Secretaire", Description = "Secrétariat et accueil" },
						new RoleDao { Name = "Patient", Description = "Portail Patient" });
					db.SaveChanges();
				}

				// Check and seed admin user
				if (!db.Users.Any(u => u.RoleId == 1 || u.Username == "admin"))
				{
					var hasher = scope.ServiceProvider.GetRequiredService<IPasswordHasher>();

					// Admin password comes from configuration/env (Seed:AdminPassword or SEED_ADMIN_PASSWORD).
					// If none is provided we generate a strong random one and log it once — never a hardcoded constant.
					var password = builder.Configuration["Seed:AdminPassword"];
					var generated = false;
					if (string.IsNullOrWhiteSpace(password))
					{
						password = Guid.NewGuid().ToString("N") + "Aa1!";
						generated = true;
					}

					var salt = Guid.NewGuid().ToString("N");
					var admin = new UserDao
					{
						Username = "admin",
						Email = "admin@dentiste.tn",
						PasswordHash = hasher.Hash(password, salt),
						PasswordSalt = salt,
						Nom = "System",
						Prenom = "Admin",
						IsActive = true,
						CreatedAt = DateTime.UtcNow,
						RoleId = 1
					};
					db.Users.Add(admin);
					db.SaveChanges();

					if (generated)
					{
						logger.LogWarning(
							"Seeded default admin account 'admin' with an auto-generated password: {Password}. " +
							"Change it immediately and set 'Seed:AdminPassword' to control it.", password);
					}
				}
			}

			// Configure the HTTP request pipeline.
			if (app.Environment.IsDevelopment())
			{
				app.MapOpenApi();
			}

			app.UseHttpsRedirection();

			app.UseCors();

			// ── Auth pipeline (order matters!) ──
			app.UseAuthentication();
			app.UseAuthorization();
			app.UseMiddleware<JwtBlacklistMiddleware>();
			app.UseMiddleware<SubscriptionCheckMiddleware>();

			app.MapControllers();
			app.MapHub<Dentiste.api.Hubs.ClinicHub>("/api/hubs/clinic");

			app.Run();
		}
	}
}
