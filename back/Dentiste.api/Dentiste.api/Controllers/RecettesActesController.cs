using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Dentiste.Data;
using Dentiste.Core.Features.RecettesActes;
using Dentiste.Core.Features.RecettesActes.Commands.Add;
using Dentiste.Core.Features.RecettesActes.Commands.Delete;
using Dentiste.Core.Features.RecettesActes.Queries.GetByActe;

namespace Dentiste.api.Controllers;

[ApiController]
[Route("api/recettes-actes")]
[Authorize(Roles = nameof(UserRole.Dentiste))]
public class RecettesActesController : ControllerBase
{
    private readonly ISender _sender;

    public RecettesActesController(ISender sender)
    {
        _sender = sender;
    }

    [HttpGet("{acteMedicalId:int}")]
    [Authorize(Roles = $"{nameof(UserRole.Dentiste)},{nameof(UserRole.Secretaire)}")]
    public async Task<IActionResult> GetByActe(int acteMedicalId)
    {
        var query = new GetRecettesByActeQuery { ActeMedicalId = acteMedicalId };
        var result = await _sender.Send(query);
        if (result.IsSuccess)
        {
            return Ok(result.Value);
        }
        return BadRequest(result.Error);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] AddRecetteActeCommand command)
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
        var command = new DeleteRecetteActeCommand { Id = id };
        var result = await _sender.Send(command);
        if (result.IsSuccess)
        {
            return NoContent();
        }
        return BadRequest(result.Error);
    }
}
