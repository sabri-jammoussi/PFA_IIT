using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Core.Features.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Ordonnances.Queries.GetAll;

public class GetAllOrdonnancesQueryHandler : IQueryHandler<GetAllOrdonnancesQuery, PagedResult<OrdonnanceDto>>
{
    private readonly DentisteContext _context;

    public GetAllOrdonnancesQueryHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<PagedResult<OrdonnanceDto>>> Handle(GetAllOrdonnancesQuery request, CancellationToken cancellationToken)
    {
        var query = _context.Ordonnances.AsNoTracking();

        if (request.ConsultationId.HasValue)
        {
            query = query.Where(o => o.ConsultationId == request.ConsultationId.Value);
        }

        if (!string.IsNullOrWhiteSpace(request.SearchTerm))
        {
            var search = request.SearchTerm.Trim().ToLower();
            query = query.Where(o => o.Traitement.ToLower().Contains(search) || o.Consultation.Patient.Nom.ToLower().Contains(search) || o.Consultation.Patient.Prenom.ToLower().Contains(search));
        }

        var totalCount = await query.CountAsync(cancellationToken);
        
        var page = request.Page <= 0 ? 1 : request.Page;
        var pageSize = request.PageSize <= 0 ? 10 : request.PageSize;

        var items = await query
            .OrderByDescending(o => o.DateEmission)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(o => new OrdonnanceDto
            {
                Id = o.Id,
                DateEmission = o.DateEmission,
                Traitement = o.Traitement,
                ConsultationId = o.ConsultationId,
                PatientNomComplet = o.Consultation.Patient.Nom + " " + o.Consultation.Patient.Prenom
            })
            .ToListAsync(cancellationToken);

        var pagedResult = new PagedResult<OrdonnanceDto>(items, totalCount, page, pageSize);
        return Result.Success(pagedResult);
    }
}
