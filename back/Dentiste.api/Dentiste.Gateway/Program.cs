using HealthChecks.UI.Client;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Serilog;
using System.Reflection;
using Yarp.ReverseProxy.Configuration;

var name = "Dentiste Gateway";

// initialize app
var builder = WebApplication.CreateBuilder(new WebApplicationOptions
{
    Args = args,
    ApplicationName = "Dentiste.Gateway"
});

// initialize logger
Log.Logger = new LoggerConfiguration()
    .ReadFrom.Configuration(builder.Configuration)
    .CreateLogger();
var logger = Log.Logger.ForContext<Program>();

// read version
var appVersion = Assembly.GetEntryAssembly()
    ?.GetCustomAttribute<AssemblyInformationalVersionAttribute>()
    ?.InformationalVersion;

logger.Information($"[{name}] v{appVersion}");
if (Environment.UserInteractive)
{
    Console.Title = $"{name} v{appVersion}";
    logger.Verbose("Running on user interactive mode");
}
else
{
    logger.Verbose("Running as windows service mode");
}

// Add services to the container.
builder.Services.AddSerilog(config => config.ReadFrom.Configuration(builder.Configuration));

builder.Services.AddCors();

builder.Services.AddHealthChecks()
    .AddProcessAllocatedMemoryHealthCheck(maximumMegabytesAllocated: 300, name: "memory", tags: ["system", "memory"]);

var initialClusters = new List<ClusterConfig>();

builder.Services.AddReverseProxy()
    .LoadFromConfig(builder.Configuration.GetSection("ReverseProxy"))
    .LoadFromMemory(Array.Empty<RouteConfig>(), initialClusters);

var app = builder.Build();

app.UseCors(policy => policy
    .AllowAnyOrigin()
    .AllowAnyHeader()
    .AllowAnyMethod());

app.MapHealthChecks("/health", new HealthCheckOptions
{
    ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse,
});

app.UseWebSockets();

app.MapReverseProxy();

app.Run();
