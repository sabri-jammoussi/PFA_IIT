using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Core.Features.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Patients.Queries.GetAll;

public class GetAllPatientsQueryHandler : IQueryHandler<GetAllPatientsQuery, PagedResult<PatientDto>>
{
    private readonly DentisteContext _context;

    public GetAllPatientsQueryHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<PagedResult<PatientDto>>> Handle(GetAllPatientsQuery request, CancellationToken cancellationToken)
    {
        var query = _context.Patients.AsNoTracking();

        if (!string.IsNullOrWhiteSpace(request.SearchTerm))
        {
            var search = request.SearchTerm.Trim().ToLower();
            query = query.Where(p => p.Nom.ToLower().Contains(search) || p.Prenom.ToLower().Contains(search) || (p.Email != null && p.Email.ToLower().Contains(search)));
        }

        var totalCount = await query.CountAsync(cancellationToken);
        
        var page = request.Page <= 0 ? 1 : request.Page;
        var pageSize = request.PageSize <= 0 ? 10 : request.PageSize;

        var items = await query
            .OrderByDescending(p => p.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(p => new PatientDto
            {
                Id = p.Id,
                Nom = p.Nom,
                Prenom = p.Prenom,
                DateNaissance = p.DateNaissance,
                Telephone = p.Telephone,
                Email = p.Email,
                Adresse = p.Adresse,
                AntecedentsMedicaux = p.AntecedentsMedicaux,
                GroupSanguin = p.GroupSanguin,
                CreatedAt = p.CreatedAt
            })
            .ToListAsync(cancellationToken);

        var pagedResult = new PagedResult<PatientDto>(items, totalCount, page, pageSize);
        return Result.Success(pagedResult);
    }
}
