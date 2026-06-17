using Dentiste.Data.Infrastructure;
using Dentiste.Data.Infrastructure.EF;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using CloudinaryDotNet;

namespace Dentiste.Core.Infrastructure.Storage;

public class ImageOptions
{
    public string? ImagesKey { get; set; }
    public string? ImagesUploadUrl { get; set; }
    public string? ImagesUrl { get; set; }
    public string? ImagesPrefix { get; set; }
    public string? ImagesLogoPrefix { get; set; }
    public string? ImagesUserPrefix { get; set; }
    public string? ImagesBackgroundPrefix { get; set; }
    public string? ImagesFolder { get; set; }
}

public class SignCloudinary
{
    public string? PublicId { get; set; }
    public int Timestamp { get; set; }
    public string? Signature { get; set; }
    public string? PublicKey { get; set; }
    public string? Transformation { get; set; }
}

public interface ICloudinaryService
{
    string GetUploadFolder(string subfolder = "radios");
    Task<ImageOptions> GetImageOptionsAsync();
    Task<SignCloudinary> SignAsync(string publicId, bool isTransform);
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

    public string GetUploadFolder(string subfolder = "radios")
    {
        var cabinetId = _tenantProvider.GetCabinetId();
        var rootFolder = _context.Options
            .FirstOrDefault(o => o.Name == "cloudinary.folder")?.Value;

        if (string.IsNullOrWhiteSpace(rootFolder))
        {
            rootFolder = "dentiflow";
        }

        if (cabinetId == null)
        {
            return $"{rootFolder}/cabinet_0/{subfolder}";
        }

        var cabinet = _context.Cabinets.FirstOrDefault(c => c.Id == cabinetId.Value);
        if (cabinet == null)
        {
            return $"{rootFolder}/cabinet_{cabinetId.Value}/{subfolder}";
        }

        if (string.IsNullOrWhiteSpace(cabinet.CloudinaryFolder))
        {
            var sanitizedName = SanitizeFolderName(cabinet.NomCabinet);
            cabinet.CloudinaryFolder = $"cab_{cabinet.Id}_{sanitizedName}";
            _context.SaveChanges();
        }

        return $"{rootFolder}/{cabinet.CloudinaryFolder}/{subfolder}";
    }

    public async Task<ImageOptions> GetImageOptionsAsync()
    {
        var name = _context.Options.FirstOrDefault(o => o.Name == "cloudinary.name")?.Value;
        var key = _context.Options.FirstOrDefault(o => o.Name == "cloudinary.key")?.Value;
        var secret = _context.Options.FirstOrDefault(o => o.Name == "cloudinary.secret")?.Value;

        var account = new Account(name, key, secret);
        var cloudinary = new Cloudinary(account);
        var api = cloudinary.Api;
        api.Secure = true;

        return new ImageOptions
        {
            ImagesKey = key,
            ImagesUploadUrl = api.GetUploadUrl(),
            ImagesUrl = $"{api.Url.BuildUrl()}",
            ImagesPrefix = "pfa",
            ImagesLogoPrefix = "l",
            ImagesUserPrefix = "u",
            ImagesBackgroundPrefix = "b",
            ImagesFolder = GetUploadFolder("users")
        };
    }

    public async Task<SignCloudinary> SignAsync(string publicId, bool isTransform)
    {
        var name = _context.Options.FirstOrDefault(o => o.Name == "cloudinary.name")?.Value;
        var key = _context.Options.FirstOrDefault(o => o.Name == "cloudinary.key")?.Value;
        var secret = _context.Options.FirstOrDefault(o => o.Name == "cloudinary.secret")?.Value;

        var account = new Account(name, key, secret);
        var cloudinary = new Cloudinary(account);
        var api = cloudinary.Api;
        api.Secure = true;

        var folder = GetUploadFolder("users");
        var fullPublicId = $"{folder}/{publicId}";

        var timestamp = (int)DateTimeOffset.UtcNow.ToUnixTimeSeconds();

        if (isTransform)
        {
            var parameters = new SortedDictionary<string, object>
            {
                { "public_id", fullPublicId },
                { "timestamp", timestamp },
                { "invalidate", "true" },
            };

            var signature = api.SignParameters(parameters);
            return new SignCloudinary
            {
                PublicId = fullPublicId,
                Timestamp = timestamp,
                Signature = signature,
                PublicKey = key
            };
        }
        else
        {
            var transformationObj = new Transformation()
                .Crop("auto")
                .Gravity("face")
                .Width(300)
                .Height(300)
                .Quality("auto:eco");

            string transformation = transformationObj.Generate();
            var parameters = new SortedDictionary<string, object>
            {
                { "public_id", fullPublicId },
                { "timestamp", timestamp },
                { "invalidate", "true" },
                { "transformation", transformation }
            };

            var signature = api.SignParameters(parameters);
            return new SignCloudinary
            {
                PublicId = fullPublicId,
                Timestamp = timestamp,
                Signature = signature,
                PublicKey = key,
                Transformation = transformation
            };
        }
    }

    private string SanitizeFolderName(string name)
    {
        if (string.IsNullOrWhiteSpace(name)) return "unknown";
        var sanitized = name.Trim().ToLowerInvariant();
        sanitized = Regex.Replace(sanitized, @"\s+", "_"); // Replace spaces with underscores
        sanitized = Regex.Replace(sanitized, @"[^a-z0-9_-]", ""); // Keep only safe chars
        return sanitized;
    }
}
