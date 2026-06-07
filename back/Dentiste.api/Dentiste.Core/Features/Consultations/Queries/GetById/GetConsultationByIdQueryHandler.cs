using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Consultations.Queries.GetById;

public class GetConsultationByIdQueryHandler : IQueryHandler<GetConsultationByIdQuery, ConsultationDto>
{
    private readonly DentisteContext _context;

    public GetConsultationByIdQueryHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<ConsultationDto>> Handle(GetConsultationByIdQuery request, CancellationToken cancellationToken)
    {
        var consultation = await _context.Consultations
            .AsNoTracking()
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
            .FirstOrDefaultAsync(c => c.Id == request.Id, cancellationToken);

        if (consultation == null)
        {
            return Result.Failure<ConsultationDto>(Errors.ConsultationNotFound);
        }

        return Result.Success(consultation);
    }
}
