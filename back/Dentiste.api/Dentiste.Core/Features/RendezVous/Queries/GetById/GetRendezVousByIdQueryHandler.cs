using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.RendezVous.Queries.GetById;

public class GetRendezVousByIdQueryHandler : IQueryHandler<GetRendezVousByIdQuery, RendezVousDto>
{
    private readonly DentisteContext _context;

    public GetRendezVousByIdQueryHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<RendezVousDto>> Handle(GetRendezVousByIdQuery request, CancellationToken cancellationToken)
    {
        var rdv = await _context.RendezVous
            .AsNoTracking()
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
            .FirstOrDefaultAsync(r => r.Id == request.Id, cancellationToken);

        if (rdv == null)
        {
            return Result.Failure<RendezVousDto>(Errors.RendezVousNotFound);
        }

        return Result.Success(rdv);
    }
}
