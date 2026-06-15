using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.RecettesActes.Queries.GetByActe;

public class GetRecettesByActeQueryHandler : IQueryHandler<GetRecettesByActeQuery, List<RecetteActeDto>>
{
    private readonly DentisteContext _context;

    public GetRecettesByActeQueryHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<List<RecetteActeDto>>> Handle(GetRecettesByActeQuery request, CancellationToken cancellationToken)
    {
        var items = await _context.RecettesActes
            .AsNoTracking()
            .Where(r => r.ActeMedicalId == request.ActeMedicalId)
            .Include(r => r.ActeMedical)
            .Include(r => r.Article)
            .Select(r => new RecetteActeDto
            {
                Id = r.Id,
                QuantiteRequise = r.QuantiteRequise,
                ActeMedicalId = r.ActeMedicalId,
                ActeMedicalLibelle = r.ActeMedical.Libelle,
                ArticleId = r.ArticleId,
                ArticleNom = r.Article.Nom,
                ArticleUnite = r.Article.Unite
            })
            .OrderBy(r => r.ArticleNom)
            .ToListAsync(cancellationToken);

        return Result.Success(items);
    }
}
