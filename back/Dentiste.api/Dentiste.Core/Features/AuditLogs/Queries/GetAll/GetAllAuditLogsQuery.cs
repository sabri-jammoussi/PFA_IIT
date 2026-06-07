using Dentiste.Core.Messaging;
using Dentiste.Core.Features.Shared;

namespace Dentiste.Core.Features.AuditLogs.Queries.GetAll;

public record GetAllAuditLogsQuery : IQuery<PagedResult<AuditLogDto>>
{
    public int Page { get; init; } = 1;
    public int PageSize { get; init; } = 10;
    public string? TableName { get; init; }
    public string? Action { get; init; }
    public string? UserId { get; init; }
}
