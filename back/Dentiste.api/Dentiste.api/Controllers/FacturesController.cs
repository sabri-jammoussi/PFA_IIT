using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using Dentiste.Core.Features.Factures;
using Dentiste.Core.Features.Factures.Commands.Add;
using Dentiste.Core.Features.Factures.Commands.Update;
using Dentiste.Core.Features.Factures.Commands.Delete;
using Dentiste.Core.Features.Factures.Queries.GetById;
using Dentiste.Core.Features.Factures.Queries.GetAll;

namespace Dentiste.api.Controllers;

[ApiController]
[Route("api/factures")]
public class FacturesController : ControllerBase
{
    private readonly ISender _sender;

    public FacturesController(ISender sender)
    {
        _sender = sender;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 10,
        [FromQuery] int? patientId = null,
        [FromQuery] string? statutPaiement = null,
        [FromQuery] string? search = null)
    {
        var query = new GetAllFacturesQuery
        {
            Page = page,
            PageSize = pageSize,
            PatientId = patientId,
            StatutPaiement = statutPaiement,
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
        var query = new GetFactureByIdQuery { Id = id };
        var result = await _sender.Send(query);
        if (result.IsSuccess)
        {
            return Ok(result.Value);
        }
        return NotFound(result.Error);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] AddFactureCommand command)
    {
        var result = await _sender.Send(command);
        if (result.IsSuccess)
        {
            return CreatedAtAction(nameof(GetById), new { id = result.Value }, result.Value);
        }
        return BadRequest(result.Error);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateFactureCommand command)
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
        var command = new DeleteFactureCommand { Id = id };
        var result = await _sender.Send(command);
        if (result.IsSuccess)
        {
            return NoContent();
        }
        return BadRequest(result.Error);
    }
}
