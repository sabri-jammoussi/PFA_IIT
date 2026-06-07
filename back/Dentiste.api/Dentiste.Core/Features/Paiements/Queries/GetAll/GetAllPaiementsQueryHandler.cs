using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Core.Features.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Paiements.Queries.GetAll;

public class GetAllPaiementsQueryHandler : IQueryHandler<GetAllPaiementsQuery, PagedResult<PaiementDto>>
{
    private readonly DentisteContext _context;

    public GetAllPaiementsQueryHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<PagedResult<PaiementDto>>> Handle(GetAllPaiementsQuery request, CancellationToken cancellationToken)
    {
        var query = _context.Paiements.AsNoTracking();

        if (request.FactureId.HasValue)
        {
            query = query.Where(p => p.FactureId == request.FactureId.Value);
        }

        if (!string.IsNullOrWhiteSpace(request.ModePaiement))
        {
            query = query.Where(p => p.ModePaiement == request.ModePaiement.Trim());
        }

        var totalCount = await query.CountAsync(cancellationToken);
        
        var page = request.Page <= 0 ? 1 : request.Page;
        var pageSize = request.PageSize <= 0 ? 10 : request.PageSize;

        var items = await query
            .OrderByDescending(p => p.DatePaiement)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(p => new PaiementDto
            {
                Id = p.Id,
                DatePaiement = p.DatePaiement,
                Montant = p.Montant,
                ModePaiement = p.ModePaiement,
                FactureId = p.FactureId,
                FactureNumero = p.Facture.NumeroFacture
            })
            .ToListAsync(cancellationToken);

        var pagedResult = new PagedResult<PaiementDto>(items, totalCount, page, pageSize);
        return Result.Success(pagedResult);
    }
}
