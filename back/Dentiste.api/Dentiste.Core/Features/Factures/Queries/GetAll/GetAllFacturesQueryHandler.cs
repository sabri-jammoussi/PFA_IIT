using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Core.Features.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Factures.Queries.GetAll;

public class GetAllFacturesQueryHandler : IQueryHandler<GetAllFacturesQuery, PagedResult<FactureDto>>
{
    private readonly DentisteContext _context;

    public GetAllFacturesQueryHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<PagedResult<FactureDto>>> Handle(GetAllFacturesQuery request, CancellationToken cancellationToken)
    {
        var query = _context.Factures.AsNoTracking();

        if (request.PatientId.HasValue)
        {
            query = query.Where(f => f.PatientId == request.PatientId.Value);
        }

        if (!string.IsNullOrWhiteSpace(request.StatutPaiement))
        {
            query = query.Where(f => f.StatutPaiement == request.StatutPaiement.Trim());
        }

        if (!string.IsNullOrWhiteSpace(request.SearchTerm))
        {
            var search = request.SearchTerm.Trim().ToLower();
            query = query.Where(f => f.NumeroFacture.ToLower().Contains(search) || f.Patient.Nom.ToLower().Contains(search) || f.Patient.Prenom.ToLower().Contains(search));
        }

        var totalCount = await query.CountAsync(cancellationToken);
        
        var page = request.Page <= 0 ? 1 : request.Page;
        var pageSize = request.PageSize <= 0 ? 10 : request.PageSize;

        var items = await query
            .OrderByDescending(f => f.DateEmission)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(f => new FactureDto
            {
                Id = f.Id,
                NumeroFacture = f.NumeroFacture,
                DateEmission = f.DateEmission,
                MontantTotal = f.MontantTotal,
                MontantPaye = f.MontantPaye,
                StatutPaiement = f.StatutPaiement,
                PatientId = f.PatientId,
                PatientNomComplet = f.Patient.Nom + " " + f.Patient.Prenom
            })
            .ToListAsync(cancellationToken);

        var pagedResult = new PagedResult<FactureDto>(items, totalCount, page, pageSize);
        return Result.Success(pagedResult);
    }
}
