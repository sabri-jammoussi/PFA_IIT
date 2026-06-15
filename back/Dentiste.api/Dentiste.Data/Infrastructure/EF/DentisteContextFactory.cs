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

        // Utilise la chaîne de connexion dynamique ou celle par défaut
        optionsBuilder.UseSqlServer(
            connectionString ?? "Server=.;Database=dentiste_db2;User Id=sa;Password=123456.aA;TrustServerCertificate=True;");

        return new DentisteContext(optionsBuilder.Options);
    }
}
