using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Ordonnances.Queries.GetById;

public class GetOrdonnanceByIdQueryHandler : IQueryHandler<GetOrdonnanceByIdQuery, OrdonnanceDto>
{
    private readonly DentisteContext _context;

    public GetOrdonnanceByIdQueryHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<OrdonnanceDto>> Handle(GetOrdonnanceByIdQuery request, CancellationToken cancellationToken)
    {
        var ordonnance = await _context.Ordonnances
            .AsNoTracking()
            .Select(o => new OrdonnanceDto
            {
                Id = o.Id,
                DateEmission = o.DateEmission,
                Traitement = o.Traitement,
                ConsultationId = o.ConsultationId,
                PatientNomComplet = o.Consultation.Patient.Nom + " " + o.Consultation.Patient.Prenom
            })
            .FirstOrDefaultAsync(o => o.Id == request.Id, cancellationToken);

        if (ordonnance == null)
        {
            return Result.Failure<OrdonnanceDto>(Errors.OrdonnanceNotFound);
        }

        return Result.Success(ordonnance);
    }
}
