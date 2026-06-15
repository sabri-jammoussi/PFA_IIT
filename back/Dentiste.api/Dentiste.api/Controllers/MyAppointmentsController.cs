using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Dentiste.Data;
using Dentiste.Core.Features.RendezVous.Queries.GetMy;
using Dentiste.Core.Features.RendezVous.Commands.Request;
using Dentiste.Core.Features.Patients.Queries.GetMy;
using Dentiste.Core.Features.RendezVous.Queries.GetAvailability;

namespace Dentiste.api.Controllers;

[ApiController]
[Route("api/my/appointments")]
[Authorize(Roles = "Patient")]
public class MyAppointmentsController : ControllerBase
{
    private readonly ISender _sender;

    public MyAppointmentsController(ISender sender)
    {
        _sender = sender;
    }

    /// <summary>
    /// Gets the list of available 30-minute appointment slots for a dentist on a specific date.
    /// </summary>
    [HttpGet("availability")]
    public async Task<IActionResult> GetAvailability([FromQuery] System.DateTime date, [FromQuery] int dentistId)
    {
        var query = new GetAppointmentAvailabilityQuery { Date = date, DentistId = dentistId };
        var result = await _sender.Send(query);
        if (result.IsSuccess)
        {
            return Ok(result.Value);
        }
        return BadRequest(result.Error);
    }

    /// <summary>
    /// Gets the full visit history for the logged-in patient.
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetMyHistory()
    {
        var result = await _sender.Send(new GetMyAppointmentsQuery());
        if (result.IsSuccess)
        {
            return Ok(result.Value);
        }
        return BadRequest(result.Error);
    }

    /// <summary>
    /// Gets the full medical record for the logged-in patient.
    /// </summary>
    [HttpGet("medical-record")]
    public async Task<IActionResult> GetMyMedicalRecord()
    {
        var result = await _sender.Send(new GetMyMedicalRecordQuery());
        if (result.IsSuccess)
        {
            return Ok(result.Value);
        }
        return BadRequest(result.Error);
    }

    /// <summary>
    /// Submits a new appointment request by the patient.
    /// </summary>
    [HttpPost("request")]
    public async Task<IActionResult> RequestAppointment([FromBody] RequestAppointmentCommand command)
    {
        var result = await _sender.Send(command);
        if (result.IsSuccess)
        {
            return Ok(new { id = result.Value });
        }
        return BadRequest(result.Error);
    }
}
