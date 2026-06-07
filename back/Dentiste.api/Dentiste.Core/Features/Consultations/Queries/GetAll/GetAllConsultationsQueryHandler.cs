using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Core.Features.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Consultations.Queries.GetAll;

public class GetAllConsultationsQueryHandler : IQueryHandler<GetAllConsultationsQuery, PagedResult<ConsultationDto>>
{
    private readonly DentisteContext _context;

    public GetAllConsultationsQueryHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<PagedResult<ConsultationDto>>> Handle(GetAllConsultationsQuery request, CancellationToken cancellationToken)
    {
        var query = _context.Consultations.AsNoTracking();

        if (request.PatientId.HasValue)
        {
            query = query.Where(c => c.PatientId == request.PatientId.Value);
        }

        if (request.DentisteId.HasValue)
        {
            query = query.Where(c => c.DentisteId == request.DentisteId.Value);
        }

        if (request.StartDate.HasValue)
        {
            query = query.Where(c => c.DateConsultation >= request.StartDate.Value);
        }

        if (request.EndDate.HasValue)
        {
            query = query.Where(c => c.DateConsultation <= request.EndDate.Value);
        }

        var totalCount = await query.CountAsync(cancellationToken);
        
        var page = request.Page <= 0 ? 1 : request.Page;
        var pageSize = request.PageSize <= 0 ? 10 : request.PageSize;

        var items = await query
            .OrderByDescending(c => c.DateConsultation)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(c => new ConsultationDto
            {
                Id = c.Id,
                DateConsultation = c.DateConsultation,
                NotesObservations = c.NotesObservations,
                PatientId = c.PatientId,
                PatientNomComplet = c.Patient.Nom + " " + c.Patient.Prenom,
                DentisteId = c.DentisteId,
                DentisteNomComplet = c.Dentiste.Nom + " " + c.Dentiste.Prenom
            })
            .ToListAsync(cancellationToken);

        var pagedResult = new PagedResult<ConsultationDto>(items, totalCount, page, pageSize);
        return Result.Success(pagedResult);
    }
}
