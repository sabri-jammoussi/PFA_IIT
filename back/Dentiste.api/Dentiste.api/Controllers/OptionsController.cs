using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Dentiste.Core.Features.Options.Queries.GetSmtp;
using Dentiste.Core.Features.Options.Commands.UpdateSmtp;
using Dentiste.Core.Features.Options.Queries.GetCloudinary;
using Dentiste.Core.Features.Options.Commands.UpdateCloudinary;
using Dentiste.Core.Features.Options.Queries.GetStorage;
using Dentiste.Core.Features.Options.Commands.UpdateStorage;

namespace Dentiste.api.Controllers;

[ApiController]
[Route("api/options")]
[Authorize(Roles = "Admin")]
public class OptionsController : ControllerBase
{
    private readonly ISender _sender;

    public OptionsController(ISender sender)
    {
        _sender = sender;
    }

    /// <summary>
    /// Returns SMTP options.
    /// </summary>
    [HttpGet("smtp")]
    public async Task<IActionResult> GetSmtp()
    {
        var result = await _sender.Send(new GetSmtpOptionsQuery());
        return Ok(result);
    }

    /// <summary>
    /// Updates SMTP options.
    /// </summary>
    [HttpPost("smtp")]
    public async Task<IActionResult> UpdateSmtp([FromBody] UpdateSmtpOptionsCommand command)
    {
        var success = await _sender.Send(command);
        return Ok(new { success });
    }

    /// <summary>
    /// Returns Cloudinary options.
    /// </summary>
    [HttpGet("cloudinary")]
    public async Task<IActionResult> GetCloudinary()
    {
        var result = await _sender.Send(new GetCloudinaryOptionsQuery());
        return Ok(result);
    }

    /// <summary>
    /// Updates Cloudinary options.
    /// </summary>
    [HttpPost("cloudinary")]
    public async Task<IActionResult> UpdateCloudinary([FromBody] UpdateCloudinaryOptionsCommand command)
    {
        var success = await _sender.Send(command);
        return Ok(new { success });
    }

    /// <summary>
    /// Returns Storage options.
    /// </summary>
    [HttpGet("storage")]
    public async Task<IActionResult> GetStorage()
    {
        var result = await _sender.Send(new GetStorageOptionsQuery());
        return Ok(result);
    }

    /// <summary>
    /// Updates Storage options.
    /// </summary>
    [HttpPost("storage")]
    public async Task<IActionResult> UpdateStorage([FromBody] UpdateStorageOptionsCommand command)
    {
        var success = await _sender.Send(command);
        return Ok(new { success });
    }
}
