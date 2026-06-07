using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Core.Features.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.SoinsEffectues.Queries.GetAll;

public class GetAllSoinsEffectuesQueryHandler : IQueryHandler<GetAllSoinsEffectuesQuery, PagedResult<SoinEffectueDto>>
{
    private readonly DentisteContext _context;

    public GetAllSoinsEffectuesQueryHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<PagedResult<SoinEffectueDto>>> Handle(GetAllSoinsEffectuesQuery request, CancellationToken cancellationToken)
    {
        var query = _context.SoinsEffectues.AsNoTracking();

        if (request.ConsultationId.HasValue)
        {
            query = query.Where(s => s.ConsultationId == request.ConsultationId.Value);
        }

        if (request.ActeMedicalId.HasValue)
        {
            query = query.Where(s => s.ActeMedicalId == request.ActeMedicalId.Value);
        }

        var totalCount = await query.CountAsync(cancellationToken);
        
        var page = request.Page <= 0 ? 1 : request.Page;
        var pageSize = request.PageSize <= 0 ? 10 : request.PageSize;

        var items = await query
            .OrderByDescending(s => s.Id)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(s => new SoinEffectueDto
            {
                Id = s.Id,
                NumeroDent = s.NumeroDent,
                FaceDentaire = s.FaceDentaire,
                PrixApplique = s.PrixApplique,
                Notes = s.Notes,
                ConsultationId = s.ConsultationId,
                ConsultationDate = s.Consultation.DateConsultation,
                ActeMedicalId = s.ActeMedicalId,
                ActeMedicalLibelle = s.ActeMedical.Libelle
            })
            .ToListAsync(cancellationToken);

        var pagedResult = new PagedResult<SoinEffectueDto>(items, totalCount, page, pageSize);
        return Result.Success(pagedResult);
    }
}
