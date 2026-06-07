using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Core.Features.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Users.Queries.GetAll;

public class GetAllUsersQueryHandler : IQueryHandler<GetAllUsersQuery, PagedResult<UserDto>>
{
    private readonly DentisteContext _context;

    public GetAllUsersQueryHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<PagedResult<UserDto>>> Handle(GetAllUsersQuery request, CancellationToken cancellationToken)
    {
        var query = _context.Users.AsNoTracking();

        if (request.RoleId.HasValue)
        {
            query = query.Where(u => u.RoleId == request.RoleId.Value);
        }

        if (!string.IsNullOrWhiteSpace(request.SearchTerm))
        {
            var search = request.SearchTerm.Trim().ToLower();
            query = query.Where(u => u.Username.ToLower().Contains(search) || u.Email.ToLower().Contains(search) || u.Nom.ToLower().Contains(search) || u.Prenom.ToLower().Contains(search));
        }

        var totalCount = await query.CountAsync(cancellationToken);
        
        var page = request.Page <= 0 ? 1 : request.Page;
        var pageSize = request.PageSize <= 0 ? 10 : request.PageSize;

        var items = await query
            .OrderByDescending(u => u.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(u => new UserDto
            {
                Id = u.Id,
                Username = u.Username,
                Email = u.Email,
                Nom = u.Nom,
                Prenom = u.Prenom,
                IsActive = u.IsActive,
                CreatedAt = u.CreatedAt,
                RoleId = u.RoleId,
                RoleName = u.Role.Name
            })
            .ToListAsync(cancellationToken);

        var pagedResult = new PagedResult<UserDto>(items, totalCount, page, pageSize);
        return Result.Success(pagedResult);
    }
}
