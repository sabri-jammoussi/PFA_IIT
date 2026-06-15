using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Dentiste.Core.Features.SaaS.Commands.RegisterClinic;

namespace Dentiste.api.Controllers
{
    [ApiController]
    [Route("api/saas")]
    public class SaaSController : ControllerBase
    {
        private readonly ISender _sender;

        public SaaSController(ISender sender)
        {
            _sender = sender;
        }

        [HttpPost("register")]
        [AllowAnonymous]
        public async Task<IActionResult> RegisterClinic([FromBody] RegisterClinicCommand command)
        {
            var result = await _sender.Send(command);
            if (result.IsSuccess)
            {
                return Ok(new { cabinetId = result.Value, message = "Cabinet enregistré avec succès." });
            }
            return BadRequest(new { error = result.Error });
        }
    }
}
