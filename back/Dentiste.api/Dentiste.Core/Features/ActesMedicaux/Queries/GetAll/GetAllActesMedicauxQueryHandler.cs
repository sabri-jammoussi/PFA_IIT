using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Core.Features.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.ActesMedicaux.Queries.GetAll;

public class GetAllActesMedicauxQueryHandler : IQueryHandler<GetAllActesMedicauxQuery, PagedResult<ActeMedicalDto>>
{
    private readonly DentisteContext _context;

    public GetAllActesMedicauxQueryHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<PagedResult<ActeMedicalDto>>> Handle(GetAllActesMedicauxQuery request, CancellationToken cancellationToken)
    {
        var query = _context.ActesMedicaux.AsNoTracking();

        if (!string.IsNullOrWhiteSpace(request.SearchTerm))
        {
            var search = request.SearchTerm.Trim().ToLower();
            query = query.Where(a => a.Libelle.ToLower().Contains(search) || (a.CodeNomenclature != null && a.CodeNomenclature.ToLower().Contains(search)));
        }

        var totalCount = await query.CountAsync(cancellationToken);
        
        var page = request.Page <= 0 ? 1 : request.Page;
        var pageSize = request.PageSize <= 0 ? 10 : request.PageSize;

        var items = await query
            .OrderBy(a => a.Libelle)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(a => new ActeMedicalDto
            {
                Id = a.Id,
                Libelle = a.Libelle,
                TarifDeBase = a.TarifDeBase,
                CodeNomenclature = a.CodeNomenclature
            })
            .ToListAsync(cancellationToken);

        var pagedResult = new PagedResult<ActeMedicalDto>(items, totalCount, page, pageSize);
        return Result.Success(pagedResult);
    }
}
