using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Factures.Queries.GetById;

public class GetFactureByIdQueryHandler : IQueryHandler<GetFactureByIdQuery, FactureDto>
{
    private readonly DentisteContext _context;

    public GetFactureByIdQueryHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<FactureDto>> Handle(GetFactureByIdQuery request, CancellationToken cancellationToken)
    {
        var facture = await _context.Factures
            .AsNoTracking()
            .Select(f => new FactureDto
            {
                Id = f.Id,
                NumeroFacture = f.NumeroFacture,
                DateEmission = f.DateEmission,
                MontantTotal = f.MontantTotal,
                MontantPaye = f.MontantPaye,
                StatutPaiement = f.StatutPaiement,
                PatientId = f.PatientId,
                PatientNomComplet = f.Patient.Nom + " " + f.Patient.Prenom
            })
            .FirstOrDefaultAsync(f => f.Id == request.Id, cancellationToken);

        if (facture == null)
        {
            return Result.Failure<FactureDto>(Errors.FactureNotFound);
        }

        return Result.Success(facture);
    }
}
