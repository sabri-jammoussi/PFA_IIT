using System;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Infrastructure.Storage;
using Dentiste.Data.Infrastructure.EF;
using Dentiste.Data.Models;

namespace Dentiste.api.Controllers;

[ApiController]
public class ImageController : ControllerBase
{
    private readonly ICloudinaryService _cloudinaryService;
    private readonly DentisteContext _context;

    public ImageController(ICloudinaryService cloudinaryService, DentisteContext context)
    {
        _cloudinaryService = cloudinaryService;
        _context = context;
    }

    [HttpGet("api/images/options")]
    [Authorize]
    public async Task<IActionResult> GetOptions()
    {
        try
        {
            var options = await _cloudinaryService.GetImageOptionsAsync();
            return Ok(options);
        }
        catch (Exception ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpGet("api/images/sign")]
    [Authorize]
    public async Task<IActionResult> Sign([Required][FromQuery(Name = "public_id")] string publicId, [FromQuery(Name = "isTransform")] bool isTransform)
    {
        try
        {
            var result = await _cloudinaryService.SignAsync(publicId, isTransform);
            return Ok(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new { error = $"Cloudinary: configuration invalide. {ex.Message}" });
        }
    }

    [HttpGet("api/m/ImageVersion/{imageId}")]
    [Authorize]
    public async Task<IActionResult> GetImageVersion([Required] string imageId)
    {
        var decodedImageId = Uri.UnescapeDataString(imageId);
        var imageData = await _context.ImageVersions.FirstOrDefaultAsync(x => x.ImageId == decodedImageId);
        if (imageData == null)
        {
            return Ok(new { imageId = decodedImageId, imageVersion = 0 });
        }

        return Ok(new { imageId = imageData.ImageId, imageVersion = imageData.Version });
    }

    [HttpPost("api/m/ImageVersion")]
    [Authorize]
    public async Task<IActionResult> AddImageVersion([FromBody] ImageVersionDto dto)
    {
        if (dto == null || string.IsNullOrEmpty(dto.ImageId))
        {
            return BadRequest(new { error = "ImageId requis." });
        }

        var existing = await _context.ImageVersions.FirstOrDefaultAsync(x => x.ImageId == dto.ImageId);
        if (existing != null)
        {
            existing.Version = dto.ImageVersion;
            await _context.SaveChangesAsync();
            return Ok();
        }

        var newVersion = new ImageVersionDao
        {
            ImageId = dto.ImageId,
            Version = dto.ImageVersion
        };
        _context.ImageVersions.Add(newVersion);
        await _context.SaveChangesAsync();
        return Ok();
    }
}

public class ImageVersionDto
{
    public string ImageId { get; set; } = string.Empty;
    public long ImageVersion { get; set; }
}
