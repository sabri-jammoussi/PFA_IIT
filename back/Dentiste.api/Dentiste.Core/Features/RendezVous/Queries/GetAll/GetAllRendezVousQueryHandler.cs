using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Core.Features.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.RendezVous.Queries.GetAll;

public class GetAllRendezVousQueryHandler : IQueryHandler<GetAllRendezVousQuery, PagedResult<RendezVousDto>>
{
    private readonly DentisteContext _context;

    public GetAllRendezVousQueryHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<PagedResult<RendezVousDto>>> Handle(GetAllRendezVousQuery request, CancellationToken cancellationToken)
    {
        var query = _context.RendezVous.AsNoTracking();

        if (request.StartDate.HasValue)
        {
            query = query.Where(r => r.DateHeure >= request.StartDate.Value);
        }

        if (request.EndDate.HasValue)
        {
            query = query.Where(r => r.DateHeure <= request.EndDate.Value);
        }

        if (request.PatientId.HasValue)
        {
            query = query.Where(r => r.PatientId == request.PatientId.Value);
        }

        if (request.DentisteId.HasValue)
        {
            query = query.Where(r => r.DentisteId == request.DentisteId.Value);
        }

        if (!string.IsNullOrWhiteSpace(request.Statut))
        {
            query = query.Where(r => r.Statut == request.Statut.Trim());
        }

        var totalCount = await query.CountAsync(cancellationToken);
        
        var page = request.Page <= 0 ? 1 : request.Page;
        var pageSize = request.PageSize <= 0 ? 10 : request.PageSize;

        var items = await query
            .OrderBy(r => r.DateHeure)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(r => new RendezVousDto
            {
                Id = r.Id,
                DateHeure = r.DateHeure,
                DureeEstimee = r.DureeEstimee,
                Statut = r.Statut,
                Motif = r.Motif,
                Note = r.Note,
                PatientId = r.PatientId,
                PatientNomComplet = r.Patient.Nom + " " + r.Patient.Prenom,
                DentisteId = r.DentisteId,
                DentisteNomComplet = r.Dentiste.Nom + " " + r.Dentiste.Prenom
            })
            .ToListAsync(cancellationToken);

        var pagedResult = new PagedResult<RendezVousDto>(items, totalCount, page, pageSize);
        return Result.Success(pagedResult);
    }
}
