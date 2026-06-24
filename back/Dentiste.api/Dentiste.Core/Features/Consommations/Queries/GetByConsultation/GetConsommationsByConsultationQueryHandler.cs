using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Consommations.Queries.GetByConsultation;

public class GetConsommationsByConsultationQueryHandler
    : IQueryHandler<GetConsommationsByConsultationQuery, List<ConsommationArticleDto>>
{
    private readonly DentisteContext _context;

    public GetConsommationsByConsultationQueryHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<List<ConsommationArticleDto>>> Handle(
        GetConsommationsByConsultationQuery request, CancellationToken cancellationToken)
    {
        var items = await _context.ConsommationsArticles
            .AsNoTracking()
            .Where(c => c.ConsultationId == request.ConsultationId)
            .OrderByDescending(c => c.DateConsommation)
            .Select(c => new ConsommationArticleDto
            {
                Id = c.Id,
                Quantite = c.Quantite,
                DateConsommation = c.DateConsommation,
                ConsultationId = c.ConsultationId,
                ArticleId = c.ArticleId,
                ArticleNom = c.Article.Nom,
                ArticleUnite = c.Article.Unite
            })
            .ToListAsync(cancellationToken);

        return Result.Success(items);
    }
}
