using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using Dentiste.Core.Infrastructure.Security;
using Dentiste.Data;
using Dentiste.api.Middleware;

namespace Dentiste.api
{
	public class Program
	{
		public static void Main(string[] args)
		{
			var builder = WebApplication.CreateBuilder(args);

			// Add services to the container.
			builder.Services.AddDbContext<Dentiste.Data.Infrastructure.EF.DentisteContext>(options =>
				options.UseSqlServer(builder.Configuration.GetConnectionString("APP")));

			builder.Services.AddMediatR(cfg =>
				cfg.RegisterServicesFromAssembly(typeof(Dentiste.Core.Messaging.ICommand).Assembly));

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

			// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
			builder.Services.AddOpenApi();

			var app = builder.Build();

			// Configure the HTTP request pipeline.
			if (app.Environment.IsDevelopment())
			{
				app.MapOpenApi();
			}

			app.UseHttpsRedirection();

			// ── Auth pipeline (order matters!) ──
			app.UseAuthentication();
			app.UseAuthorization();
			app.UseMiddleware<JwtBlacklistMiddleware>();

			app.MapControllers();

			app.Run();
		}
	}
}
