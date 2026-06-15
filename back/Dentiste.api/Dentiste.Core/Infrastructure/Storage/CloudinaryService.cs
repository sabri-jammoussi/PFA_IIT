using Dentiste.Data.Infrastructure;
using Dentiste.Data.Infrastructure.EF;
using System.Linq;

namespace Dentiste.Core.Infrastructure.Storage;

public interface ICloudinaryService
{
    string GetUploadFolder();
}

public class CloudinaryService : ICloudinaryService
{
    private readonly ITenantProvider _tenantProvider;
    private readonly DentisteContext _context;

    public CloudinaryService(ITenantProvider tenantProvider, DentisteContext context)
    {
        _tenantProvider = tenantProvider;
        _context = context;
    }

    public string GetUploadFolder()
    {
        var cabinetId = _tenantProvider.GetCabinetId();
        var rootFolder = _context.Options
            .FirstOrDefault(o => o.Name == "cloudinary.folder")?.Value;

        if (string.IsNullOrWhiteSpace(rootFolder))
        {
            rootFolder = "dentiflow";
        }

        return $"{rootFolder}/cabinet_{cabinetId ?? 0}/radios";
    }
}
