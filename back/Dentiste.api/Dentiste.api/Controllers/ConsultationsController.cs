using System;
using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using Dentiste.Data;
using Dentiste.Core.Features.Consultations;
using Dentiste.Core.Features.Consultations.Commands.Add;
using Dentiste.Core.Features.Consultations.Commands.Update;
using Dentiste.Core.Features.Consultations.Commands.Delete;
using Dentiste.Core.Features.Consultations.Commands.Finalize;
using Dentiste.Core.Features.Consultations.Queries.GetById;
using Dentiste.Core.Features.Consultations.Queries.GetAll;

namespace Dentiste.api.Controllers;

[ApiController]
[Route("api/consultations")]
[Authorize(Roles = nameof(UserRole.Dentiste))]
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

    /// <summary>
    /// Closes a consultation: generates a single invoice equal to the sum of the
    /// visit's treatments and notifies the secretary (real-time + notification center)
    /// of the amount to collect from the patient.
    /// </summary>
    [HttpPost("{id:int}/finalize")]
    public async Task<IActionResult> Finalize(
        int id,
        [FromServices] Microsoft.AspNetCore.SignalR.IHubContext<Dentiste.api.Hubs.ClinicHub> hubContext,
        [FromServices] Dentiste.Data.Infrastructure.ITenantProvider tenantProvider)
    {
        var result = await _sender.Send(new FinalizeConsultationCommand { ConsultationId = id });
        if (!result.IsSuccess)
        {
            return BadRequest(result.Error);
        }

        // Live toast for the secretary's web client (same ClinicHub channel as check-in).
        // The persisted notification (notification center + mobile) is handled separately
        // by the notification microservice via the finalize-consultation event.
        var cabinetId = tenantProvider.GetCabinetId();
        await hubContext.Clients.Group($"cabinet_{cabinetId}").SendAsync("NotifyInvoiceReady", result.Value);

        return Ok(result.Value);
    }
}
