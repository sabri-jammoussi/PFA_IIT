using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Core.Features.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Roles.Queries.GetAll;

public class GetAllRolesQueryHandler : IQueryHandler<GetAllRolesQuery, PagedResult<RoleDto>>
{
    private readonly DentisteContext _context;

    public GetAllRolesQueryHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<PagedResult<RoleDto>>> Handle(GetAllRolesQuery request, CancellationToken cancellationToken)
    {
        var query = _context.Roles.AsNoTracking();

        if (!string.IsNullOrWhiteSpace(request.SearchTerm))
        {
            var search = request.SearchTerm.Trim().ToLower();
            query = query.Where(r => r.Name.ToLower().Contains(search) || (r.Description != null && r.Description.ToLower().Contains(search)));
        }

        var totalCount = await query.CountAsync(cancellationToken);
        
        var page = request.Page <= 0 ? 1 : request.Page;
        var pageSize = request.PageSize <= 0 ? 10 : request.PageSize;

        var items = await query
            .OrderBy(r => r.Name)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(r => new RoleDto
            {
                Id = r.Id,
                Name = r.Name,
                Description = r.Description
            })
            .ToListAsync(cancellationToken);

        var pagedResult = new PagedResult<RoleDto>(items, totalCount, page, pageSize);
        return Result.Success(pagedResult);
    }
}
