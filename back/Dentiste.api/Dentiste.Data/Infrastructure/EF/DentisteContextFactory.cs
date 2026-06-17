using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using System.IO;
using System.Text.Json;

namespace Dentiste.Data.Infrastructure.EF;

/// <summary>
/// Factory utilisée par les outils EF Core (dotnet ef migrations add, update, etc.)
/// pour créer une instance de DentisteContext au moment du design.
/// </summary>
public class DentisteContextFactory : IDesignTimeDbContextFactory<DentisteContext>
{
    public DentisteContext CreateDbContext(string[] args)
    {
        var optionsBuilder = new DbContextOptionsBuilder<DentisteContext>();

        string? connectionString = null;
        try
        {
            // Tente de charger la chaîne de connexion depuis appsettings.Development.json
            var basePath = Path.Combine(Directory.GetCurrentDirectory(), "../Dentiste.api");
            if (!Directory.Exists(basePath))
            {
                basePath = Directory.GetCurrentDirectory();
            }

            var configPath = Path.Combine(basePath, "appsettings.Development.json");
            if (!File.Exists(configPath))
            {
                configPath = Path.Combine(basePath, "appsettings.json");
            }

            if (File.Exists(configPath))
            {
                var json = File.ReadAllText(configPath);
                using (var doc = JsonDocument.Parse(json))
                {
                    if (doc.RootElement.TryGetProperty("ConnectionStrings", out var connStrings) &&
                        connStrings.TryGetProperty("APP", out var appConn))
                    {
                        connectionString = appConn.GetString();
                    }
                }
            }
        }
        catch
        {
            // Fallback si la lecture échoue
        }

        // Fallback sur la variable d'environnement (jamais de secret en dur dans le code).
        connectionString ??= Environment.GetEnvironmentVariable("ConnectionStrings__APP");

        if (string.IsNullOrWhiteSpace(connectionString))
        {
            throw new InvalidOperationException(
                "No design-time connection string found. Set it in appsettings.Development.json " +
                "(ConnectionStrings:APP) or the ConnectionStrings__APP environment variable.");
        }

        optionsBuilder.UseSqlServer(connectionString);

        return new DentisteContext(optionsBuilder.Options);
    }
}
