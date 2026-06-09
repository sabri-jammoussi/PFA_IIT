using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Dentiste.Data;
using Dentiste.Core.Features.Paiements;
using Dentiste.Core.Features.Paiements.Commands.Add;
using Dentiste.Core.Features.Paiements.Commands.Update;
using Dentiste.Core.Features.Paiements.Commands.Delete;
using Dentiste.Core.Features.Paiements.Queries.GetById;
using Dentiste.Core.Features.Paiements.Queries.GetAll;

namespace Dentiste.api.Controllers;

[ApiController]
[Route("api/paiements")]
[Authorize(Roles = $"{nameof(UserRole.Dentiste)},{nameof(UserRole.Secretaire)}")]
public class PaiementsController : ControllerBase
{
    private readonly ISender _sender;

    public PaiementsController(ISender sender)
    {
        _sender = sender;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 10,
        [FromQuery] int? factureId = null,
        [FromQuery] string? modePaiement = null)
    {
        var query = new GetAllPaiementsQuery
        {
            Page = page,
            PageSize = pageSize,
            FactureId = factureId,
            ModePaiement = modePaiement
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
        var query = new GetPaiementByIdQuery { Id = id };
        var result = await _sender.Send(query);
        if (result.IsSuccess)
        {
            return Ok(result.Value);
        }
        return NotFound(result.Error);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] AddPaiementCommand command)
    {
        var result = await _sender.Send(command);
        if (result.IsSuccess)
        {
            return CreatedAtAction(nameof(GetById), new { id = result.Value }, result.Value);
        }
        return BadRequest(result.Error);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdatePaiementCommand command)
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
        var command = new DeletePaiementCommand { Id = id };
        var result = await _sender.Send(command);
        if (result.IsSuccess)
        {
            return NoContent();
        }
        return BadRequest(result.Error);
    }
}
