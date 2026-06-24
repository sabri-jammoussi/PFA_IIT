using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Dentiste.Data;
using Dentiste.Core.Features.Consommations.Commands.Add;
using Dentiste.Core.Features.Consommations.Commands.Delete;
using Dentiste.Core.Features.Consommations.Queries.GetByConsultation;

namespace Dentiste.api.Controllers;

[ApiController]
[Route("api/consommations")]
[Authorize(Roles = nameof(UserRole.Dentiste))]
public class ConsommationsController : ControllerBase
{
    private readonly ISender _sender;

    public ConsommationsController(ISender sender)
    {
        _sender = sender;
    }

    [HttpGet]
    public async Task<IActionResult> GetByConsultation([FromQuery] int consultationId)
    {
        var result = await _sender.Send(new GetConsommationsByConsultationQuery { ConsultationId = consultationId });
        if (result.IsSuccess)
        {
            return Ok(result.Value);
        }
        return BadRequest(result.Error);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] AddConsommationCommand command)
    {
        var result = await _sender.Send(command);
        if (result.IsSuccess)
        {
            return Ok(result.Value);
        }
        return BadRequest(result.Error);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var result = await _sender.Send(new DeleteConsommationCommand { Id = id });
        if (result.IsSuccess)
        {
            return NoContent();
        }
        return BadRequest(result.Error);
    }
}
