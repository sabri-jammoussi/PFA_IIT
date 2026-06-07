using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.AuditLogs.Queries.GetById;

public class GetAuditLogByIdQueryHandler : IQueryHandler<GetAuditLogByIdQuery, AuditLogDto>
{
    private readonly DentisteContext _context;

    public GetAuditLogByIdQueryHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<AuditLogDto>> Handle(GetAuditLogByIdQuery request, CancellationToken cancellationToken)
    {
        var log = await _context.AuditLogs
            .AsNoTracking()
            .Select(l => new AuditLogDto
            {
                Id = l.Id,
                Action = l.Action,
                TableName = l.TableName,
                Timestamp = l.Timestamp,
                UserId = l.UserId,
                KeyValues = l.KeyValues,
                OldValues = l.OldValues,
                NewValues = l.NewValues
            })
            .FirstOrDefaultAsync(l => l.Id == request.Id, cancellationToken);

        if (log == null)
        {
            return Result.Failure<AuditLogDto>(Errors.AuditLogNotFound);
        }

        return Result.Success(log);
    }
}
