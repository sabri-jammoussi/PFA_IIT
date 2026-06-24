using System;
using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using Dentiste.Data;
using Dentiste.Core.Features.RendezVous;
using Dentiste.Core.Features.RendezVous.Commands.Add;
using Dentiste.Core.Features.RendezVous.Commands.Update;
using Dentiste.Core.Features.RendezVous.Commands.Delete;
using Dentiste.Core.Features.RendezVous.Queries.GetById;
using Dentiste.Core.Features.RendezVous.Queries.GetAll;
using Dentiste.Core.Features.RendezVous.Queries.GetPending;
using Dentiste.Core.Features.Appointments.Queries.GetWaitingRoom;

namespace Dentiste.api.Controllers;

[ApiController]
[Route("api/rendezvous")]
[Authorize(Roles = $"{nameof(UserRole.Dentiste)},{nameof(UserRole.Secretaire)}")]
public class RendezVousController : ControllerBase
{
    private readonly ISender _sender;

    public RendezVousController(ISender sender)
    {
        _sender = sender;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 10,
        [FromQuery] DateTime? startDate = null,
        [FromQuery] DateTime? endDate = null,
        [FromQuery] int? patientId = null,
        [FromQuery] int? dentisteId = null,
        [FromQuery] string? statut = null)
    {
        var query = new GetAllRendezVousQuery
        {
            Page = page,
            PageSize = pageSize,
            StartDate = startDate,
            EndDate = endDate,
            PatientId = patientId,
            DentisteId = dentisteId,
            Statut = statut
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
        var query = new GetRendezVousByIdQuery { Id = id };
        var result = await _sender.Send(query);
        if (result.IsSuccess)
        {
            return Ok(result.Value);
        }
        return NotFound(result.Error);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] AddRendezVousCommand command)
    {
        var result = await _sender.Send(command);
        if (result.IsSuccess)
        {
            return CreatedAtAction(nameof(GetById), new { id = result.Value }, result.Value);
        }
        return BadRequest(result.Error);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateRendezVousCommand command)
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
        var command = new DeleteRendezVousCommand { Id = id };
        var result = await _sender.Send(command);
        if (result.IsSuccess)
        {
            return NoContent();
        }
        return BadRequest(result.Error);
    }

    [HttpGet("pending")]
    public async Task<IActionResult> GetPending()
    {
        var result = await _sender.Send(new GetPendingAppointmentsQuery());
        if (result.IsSuccess)
        {
            return Ok(result.Value);
        }
        return BadRequest(result.Error);
    }

    /// <summary>
    /// Patients checked in (status "EnConsultation") and waiting for the doctor.
    /// Pass dentisteId to restrict the queue to a single practitioner's chair.
    /// </summary>
    [HttpGet("waiting-room")]
    public async Task<IActionResult> GetWaitingRoom([FromQuery] int? dentisteId = null)
    {
        var result = await _sender.Send(new GetWaitingRoomQuery { DentisteId = dentisteId });
        if (result.IsSuccess)
        {
            return Ok(result.Value);
        }
        return BadRequest(result.Error);
    }

    [HttpPost("{id:int}/checkin")]
    public async Task<IActionResult> CheckIn(
        int id, 
        [FromServices] Microsoft.AspNetCore.SignalR.IHubContext<Dentiste.api.Hubs.ClinicHub> hubContext,
        [FromServices] Dentiste.Data.Infrastructure.ITenantProvider tenantProvider)
    {
        var command = new Dentiste.Core.Features.Appointments.Commands.CheckIn.ConfirmPatientArrivalCommand { AppointmentId = id };
        var result = await _sender.Send(command);

        if (result.IsSuccess)
        {
            var cabinetId = tenantProvider.GetCabinetId();
            var groupName = $"cabinet_{cabinetId}";
            
            await hubContext.Clients.Group(groupName).SendAsync("NotifyPatientArrived", result.Value);
            return Ok(result.Value);
        }

        return BadRequest(result.Error);
    }
}
