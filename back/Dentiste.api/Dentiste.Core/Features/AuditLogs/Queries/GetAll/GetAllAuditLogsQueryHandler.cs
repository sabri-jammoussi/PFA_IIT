using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Core.Features.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.AuditLogs.Queries.GetAll;

public class GetAllAuditLogsQueryHandler : IQueryHandler<GetAllAuditLogsQuery, PagedResult<AuditLogDto>>
{
    private readonly DentisteContext _context;

    public GetAllAuditLogsQueryHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<PagedResult<AuditLogDto>>> Handle(GetAllAuditLogsQuery request, CancellationToken cancellationToken)
    {
        var query = _context.AuditLogs.AsNoTracking();

        if (!string.IsNullOrWhiteSpace(request.TableName))
        {
            query = query.Where(l => l.TableName == request.TableName.Trim());
        }

        if (!string.IsNullOrWhiteSpace(request.Action))
        {
            query = query.Where(l => l.Action == request.Action.Trim());
        }

        if (!string.IsNullOrWhiteSpace(request.UserId))
        {
            query = query.Where(l => l.UserId == request.UserId.Trim());
        }

        var totalCount = await query.CountAsync(cancellationToken);
        
        var page = request.Page <= 0 ? 1 : request.Page;
        var pageSize = request.PageSize <= 0 ? 10 : request.PageSize;

        var items = await query
            .OrderByDescending(l => l.Timestamp)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
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
            .ToListAsync(cancellationToken);

        var pagedResult = new PagedResult<AuditLogDto>(items, totalCount, page, pageSize);
        return Result.Success(pagedResult);
    }
}
