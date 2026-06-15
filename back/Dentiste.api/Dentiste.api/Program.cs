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
				cfg.AddOpenBehavior(typeof(CommandEventBehavior<,>));
			});

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

			builder.Services.AddCors();

			var app = builder.Build();

			// Auto migrate database on startup
			using (var scope = app.Services.CreateScope())
			{
				var db = scope.ServiceProvider.GetRequiredService<Dentiste.Data.Infrastructure.EF.DentisteContext>();
				db.Database.Migrate();

				// Check and seed roles
				if (!db.Roles.Any())
				{
					db.Database.ExecuteSqlRaw(@"
						INSERT INTO [ROLE] ( ROL_NAME, ROL_DESCRIPTION) VALUES
						( 'Admin', 'Administrateur système'),
						('Dentiste', 'Praticien Dentiste'),
						('Secretaire', 'Secrétariat et accueil'),
						('Patient', 'Portail Patient')");
				}

				// Check and seed admin user
				if (!db.Users.Any(u => u.RoleId == 1 || u.Username == "admin"))
				{
					var hasher = scope.ServiceProvider.GetRequiredService<IPasswordHasher>();
					var password = "SecurePassword123!";
					var salt = Guid.NewGuid().ToString("N");
					var hash = hasher.Hash(password, salt);

					db.Database.ExecuteSqlRaw(
						"INSERT INTO [USER] (USR_USERNAME, USR_EMAIL, USR_PASSWORD_HASH, USR_PASSWORD_SALT, USR_NOM, USR_PRENOM, USR_IS_ACTIVE, USR_CREATED_AT, USR_ROLE_ID) VALUES " +
						$"('admin', 'admin@dentiste.tn', '{hash}', '{salt}', 'System', 'Admin', 1, GETDATE(), 1)"
					);
				}
			}

			// Configure the HTTP request pipeline.
			if (app.Environment.IsDevelopment())
			{
				app.MapOpenApi();
			}

			app.UseHttpsRedirection();

			app.UseCors(policy => policy
				.SetIsOriginAllowed(_ => true)
				.AllowAnyHeader()
				.AllowAnyMethod()
				.AllowCredentials());

			// ── Auth pipeline (order matters!) ──
			app.UseAuthentication();
			app.UseAuthorization();
			app.UseMiddleware<JwtBlacklistMiddleware>();
			app.UseMiddleware<SubscriptionCheckMiddleware>();

			app.MapControllers();

			app.Run();
		}
	}
}
