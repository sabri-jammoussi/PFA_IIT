using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Dentiste.Data;
using Dentiste.Core.Features.ActesMedicaux;
using Dentiste.Core.Features.ActesMedicaux.Commands.Add;
using Dentiste.Core.Features.ActesMedicaux.Commands.Update;
using Dentiste.Core.Features.ActesMedicaux.Commands.Delete;
using Dentiste.Core.Features.ActesMedicaux.Queries.GetById;
using Dentiste.Core.Features.ActesMedicaux.Queries.GetAll;

namespace Dentiste.api.Controllers;

[ApiController]
[Route("api/actes-medicaux")]
[Authorize(Roles = nameof(UserRole.Dentiste))]
public class ActesMedicauxController : ControllerBase
{
    private readonly ISender _sender;

    public ActesMedicauxController(ISender sender)
    {
        _sender = sender;
    }

    [HttpGet]
    [Authorize(Roles = $"{nameof(UserRole.Dentiste)},{nameof(UserRole.Secretaire)}")]
    public async Task<IActionResult> GetAll([FromQuery] int page = 1, [FromQuery] int pageSize = 10, [FromQuery] string? search = null)
    {
        var query = new GetAllActesMedicauxQuery
        {
            Page = page,
            PageSize = pageSize,
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
    [Authorize(Roles = $"{nameof(UserRole.Dentiste)},{nameof(UserRole.Secretaire)}")]
    public async Task<IActionResult> GetById(int id)
    {
        var query = new GetActeMedicalByIdQuery { Id = id };
        var result = await _sender.Send(query);
        if (result.IsSuccess)
        {
            return Ok(result.Value);
        }
        return NotFound(result.Error);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] AddActeMedicalCommand command)
    {
        var result = await _sender.Send(command);
        if (result.IsSuccess)
        {
            return CreatedAtAction(nameof(GetById), new { id = result.Value }, result.Value);
        }
        return BadRequest(result.Error);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateActeMedicalCommand command)
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
        var command = new DeleteActeMedicalCommand { Id = id };
        var result = await _sender.Send(command);
        if (result.IsSuccess)
        {
            return NoContent();
        }
        return BadRequest(result.Error);
    }
}
