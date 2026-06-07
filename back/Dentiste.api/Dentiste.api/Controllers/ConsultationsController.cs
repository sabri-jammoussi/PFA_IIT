using System;
using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using Dentiste.Core.Features.Consultations;
using Dentiste.Core.Features.Consultations.Commands.Add;
using Dentiste.Core.Features.Consultations.Commands.Update;
using Dentiste.Core.Features.Consultations.Commands.Delete;
using Dentiste.Core.Features.Consultations.Queries.GetById;
using Dentiste.Core.Features.Consultations.Queries.GetAll;

namespace Dentiste.api.Controllers;

[ApiController]
[Route("api/consultations")]
public class ConsultationsController : ControllerBase
{
    private readonly ISender _sender;

    public ConsultationsController(ISender sender)
    {
        _sender = sender;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 10,
        [FromQuery] int? patientId = null,
        [FromQuery] int? dentisteId = null,
        [FromQuery] DateTime? startDate = null,
        [FromQuery] DateTime? endDate = null)
    {
        var query = new GetAllConsultationsQuery
        {
            Page = page,
            PageSize = pageSize,
            PatientId = patientId,
            DentisteId = dentisteId,
            StartDate = startDate,
            EndDate = endDate
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
        var query = new GetConsultationByIdQuery { Id = id };
        var result = await _sender.Send(query);
        if (result.IsSuccess)
        {
            return Ok(result.Value);
        }
        return NotFound(result.Error);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] AddConsultationCommand command)
    {
        var result = await _sender.Send(command);
        if (result.IsSuccess)
        {
            return CreatedAtAction(nameof(GetById), new { id = result.Value }, result.Value);
        }
        return BadRequest(result.Error);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateConsultationCommand command)
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
        var command = new DeleteConsultationCommand { Id = id };
        var result = await _sender.Send(command);
        if (result.IsSuccess)
        {
            return NoContent();
        }
        return BadRequest(result.Error);
    }
}
