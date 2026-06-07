using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.AuditLogs.Queries.GetById;

public record GetAuditLogByIdQuery : IQuery<AuditLogDto>
{
    public required int Id { get; init; }
}
