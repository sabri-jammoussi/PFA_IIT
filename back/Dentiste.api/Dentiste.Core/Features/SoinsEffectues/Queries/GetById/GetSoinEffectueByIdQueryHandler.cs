using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.SoinsEffectues.Queries.GetById;

public class GetSoinEffectueByIdQueryHandler : IQueryHandler<GetSoinEffectueByIdQuery, SoinEffectueDto>
{
    private readonly DentisteContext _context;

    public GetSoinEffectueByIdQueryHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<SoinEffectueDto>> Handle(GetSoinEffectueByIdQuery request, CancellationToken cancellationToken)
    {
        var soin = await _context.SoinsEffectues
            .AsNoTracking()
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
            .FirstOrDefaultAsync(s => s.Id == request.Id, cancellationToken);

        if (soin == null)
        {
            return Result.Failure<SoinEffectueDto>(Errors.SoinEffectueNotFound);
        }

        return Result.Success(soin);
    }
}
