using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Patients.Queries.GetById;

public class GetPatientByIdQueryHandler : IQueryHandler<GetPatientByIdQuery, PatientDto>
{
    private readonly DentisteContext _context;

    public GetPatientByIdQueryHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<PatientDto>> Handle(GetPatientByIdQuery request, CancellationToken cancellationToken)
    {
        var patient = await _context.Patients
            .AsNoTracking()
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
            .FirstOrDefaultAsync(p => p.Id == request.Id, cancellationToken);

        if (patient == null)
        {
            return Result.Failure<PatientDto>(Errors.PatientNotFound);
        }

        return Result.Success(patient);
    }
}
