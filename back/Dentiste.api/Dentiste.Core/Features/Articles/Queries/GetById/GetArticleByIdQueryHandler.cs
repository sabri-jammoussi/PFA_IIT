using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Articles.Queries.GetById;

public class GetArticleByIdQueryHandler : IQueryHandler<GetArticleByIdQuery, ArticleDto>
{
    private readonly DentisteContext _context;

    public GetArticleByIdQueryHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<ArticleDto>> Handle(GetArticleByIdQuery request, CancellationToken cancellationToken)
    {
        var article = await _context.Articles
            .AsNoTracking()
            .Where(a => a.Id == request.Id)
            .Select(a => new ArticleDto
            {
                Id = a.Id,
                Nom = a.Nom,
                Description = a.Description,
                QuantiteEnStock = a.QuantiteEnStock,
                SeuilAlerte = a.SeuilAlerte,
                Unite = a.Unite
            })
            .FirstOrDefaultAsync(cancellationToken);

        if (article == null)
        {
            return Result.Failure<ArticleDto>(Errors.ArticleNotFound);
        }

        return Result.Success(article);
    }
}
