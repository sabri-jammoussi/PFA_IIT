using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Core.Features.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Articles.Queries.GetAll;

public class GetAllArticlesQueryHandler : IQueryHandler<GetAllArticlesQuery, PagedResult<ArticleDto>>
{
    private readonly DentisteContext _context;

    public GetAllArticlesQueryHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<PagedResult<ArticleDto>>> Handle(GetAllArticlesQuery request, CancellationToken cancellationToken)
    {
        var query = _context.Articles.AsNoTracking();

        if (!string.IsNullOrWhiteSpace(request.SearchTerm))
        {
            var search = request.SearchTerm.Trim().ToLower();
            query = query.Where(a => a.Nom.ToLower().Contains(search) || (a.Description != null && a.Description.ToLower().Contains(search)));
        }

        if (request.LowStockOnly == true)
        {
            query = query.Where(a => a.QuantiteEnStock <= a.SeuilAlerte);
        }

        var totalCount = await query.CountAsync(cancellationToken);

        var page = request.Page <= 0 ? 1 : request.Page;
        var pageSize = request.PageSize <= 0 ? 50 : request.PageSize;

        var items = await query
            .OrderBy(a => a.Nom)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(a => new ArticleDto
            {
                Id = a.Id,
                Nom = a.Nom,
                Description = a.Description,
                QuantiteEnStock = a.QuantiteEnStock,
                SeuilAlerte = a.SeuilAlerte,
                Unite = a.Unite
            })
            .ToListAsync(cancellationToken);

        var pagedResult = new PagedResult<ArticleDto>(items, totalCount, page, pageSize);
        return Result.Success(pagedResult);
    }
}
