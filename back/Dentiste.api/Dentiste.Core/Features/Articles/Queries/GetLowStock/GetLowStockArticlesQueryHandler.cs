using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Articles.Queries.GetLowStock;

public class GetLowStockArticlesQueryHandler : IQueryHandler<GetLowStockArticlesQuery, List<ArticleDto>>
{
    private readonly DentisteContext _context;

    public GetLowStockArticlesQueryHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<List<ArticleDto>>> Handle(GetLowStockArticlesQuery request, CancellationToken cancellationToken)
    {
        var items = await _context.Articles
            .AsNoTracking()
            .Where(a => a.QuantiteEnStock <= a.SeuilAlerte)
            .OrderBy(a => a.QuantiteEnStock)
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

        return Result.Success(items);
    }
}
