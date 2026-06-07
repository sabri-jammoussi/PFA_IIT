using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using Dentiste.Core.Features.SoinsEffectues;
using Dentiste.Core.Features.SoinsEffectues.Commands.Add;
using Dentiste.Core.Features.SoinsEffectues.Commands.Update;
using Dentiste.Core.Features.SoinsEffectues.Commands.Delete;
using Dentiste.Core.Features.SoinsEffectues.Queries.GetById;
using Dentiste.Core.Features.SoinsEffectues.Queries.GetAll;

namespace Dentiste.api.Controllers;

[ApiController]
[Route("api/soins-effectues")]
public class SoinsEffectuesController : ControllerBase
{
    private readonly ISender _sender;

    public SoinsEffectuesController(ISender sender)
    {
        _sender = sender;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 10,
        [FromQuery] int? consultationId = null,
        [FromQuery] int? acteMedicalId = null)
    {
        var query = new GetAllSoinsEffectuesQuery
        {
            Page = page,
            PageSize = pageSize,
            ConsultationId = consultationId,
            ActeMedicalId = acteMedicalId
        };
        var result = await _sender.Send(query);
        if (result.IsSuccess)
        {
            return Ok(result.Value);
        }
        return BadRequest(result.Error);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var query = new GetSoinEffectueByIdQuery { Id = id };
        var result = await _sender.Send(query);
        if (result.IsSuccess)
        {
            return Ok(result.Value);
        }
        return NotFound(result.Error);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] AddSoinEffectueCommand command)
    {
        var result = await _sender.Send(command);
        if (result.IsSuccess)
        {
            return CreatedAtAction(nameof(GetById), new { id = result.Value }, result.Value);
        }
        return BadRequest(result.Error);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateSoinEffectueCommand command)
    {
        if (id != command.Id)
        {
            return BadRequest("L'ID spécifié dans l'URL ne correspond pas à celui du corps de la requête.");
        }

        var result = await _sender.Send(command);
        if (result.IsSuccess)
        {
            return NoContent();
        }
        return BadRequest(result.Error);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var command = new DeleteSoinEffectueCommand { Id = id };
        var result = await _sender.Send(command);
        if (result.IsSuccess)
        {
            return NoContent();
        }
        return BadRequest(result.Error);
    }
}
