using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using Dentiste.Core.Features.Ordonnances;
using Dentiste.Core.Features.Ordonnances.Commands.Add;
using Dentiste.Core.Features.Ordonnances.Commands.Update;
using Dentiste.Core.Features.Ordonnances.Commands.Delete;
using Dentiste.Core.Features.Ordonnances.Queries.GetById;
using Dentiste.Core.Features.Ordonnances.Queries.GetAll;

namespace Dentiste.api.Controllers;

[ApiController]
[Route("api/ordonnances")]
public class OrdonnancesController : ControllerBase
{
    private readonly ISender _sender;

    public OrdonnancesController(ISender sender)
    {
        _sender = sender;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 10,
        [FromQuery] int? consultationId = null,
        [FromQuery] string? search = null)
    {
        var query = new GetAllOrdonnancesQuery
        {
            Page = page,
            PageSize = pageSize,
            ConsultationId = consultationId,
            SearchTerm = search
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
        var query = new GetOrdonnanceByIdQuery { Id = id };
        var result = await _sender.Send(query);
        if (result.IsSuccess)
        {
            return Ok(result.Value);
        }
        return NotFound(result.Error);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] AddOrdonnanceCommand command)
    {
        var result = await _sender.Send(command);
        if (result.IsSuccess)
        {
            return CreatedAtAction(nameof(GetById), new { id = result.Value }, result.Value);
        }
        return BadRequest(result.Error);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateOrdonnanceCommand command)
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
        var command = new DeleteOrdonnanceCommand { Id = id };
        var result = await _sender.Send(command);
        if (result.IsSuccess)
        {
            return NoContent();
        }
        return BadRequest(result.Error);
    }
}
