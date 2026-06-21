using System.IdentityModel.Tokens.Jwt;
using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Dentiste.Core.Features.Auth.Commands.Login;
using Dentiste.Core.Features.Auth.Commands.Logout;
using Dentiste.Core.Features.Auth.Commands.ForgetPassword;

namespace Dentiste.api.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly ISender _sender;

    public AuthController(ISender sender)
    {
        _sender = sender;
    }

    [HttpPost("login")]
    [AllowAnonymous]
    public async Task<IActionResult> Login([FromBody] LoginCommand command)
    {
        var result = await _sender.Send(command);
        if (result.IsSuccess)
        {
            return Ok(result.Value);
        }
        return Unauthorized(new { error = result.Error });
    }

    [HttpPost("logout")]
    [Authorize]
    public async Task<IActionResult> Logout()
    {
        var jti = User.FindFirst(JwtRegisteredClaimNames.Jti)?.Value;
        if (string.IsNullOrEmpty(jti))
        {
            return BadRequest(new { error = "Token invalide — claim JTI manquant." });
        }

        var command = new LogoutCommand { Jti = jti };
        var result = await _sender.Send(command);
        if (result.IsSuccess)
        {
            return Ok(new { message = "Déconnexion réussie." });
        }
        return BadRequest(new { error = result.Error });
    }

    [HttpPost("forget-password")]
    [AllowAnonymous]
    public async Task<IActionResult> ForgetPassword([FromBody] ForgetPasswordCommand command)
    {
        var result = await _sender.Send(command);
        if (result.IsSuccess)
        {
            return Ok(new { message = "Si ce compte existe, un email a été envoyé." });
        }
        return BadRequest(new { error = result.Error });
    }
}
