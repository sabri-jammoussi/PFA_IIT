using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using Dentiste.Core.Features.AuditLogs;
using Dentiste.Core.Features.AuditLogs.Queries.GetById;
using Dentiste.Core.Features.AuditLogs.Queries.GetAll;

namespace Dentiste.api.Controllers;

[ApiController]
[Route("api/audit-logs")]
public class AuditLogsController : ControllerBase
{
    private readonly ISender _sender;

    public AuditLogsController(ISender sender)
    {
        _sender = sender;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 10,
        [FromQuery] string? tableName = null,
        [FromQuery] string? action = null,
        [FromQuery] string? userId = null)
    {
        var query = new GetAllAuditLogsQuery
        {
            Page = page,
            PageSize = pageSize,
            TableName = tableName,
            Action = action,
            UserId = userId
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
        var query = new GetAuditLogByIdQuery { Id = id };
        var result = await _sender.Send(query);
        if (result.IsSuccess)
        {
            return Ok(result.Value);
        }
        return NotFound(result.Error);
    }
}
