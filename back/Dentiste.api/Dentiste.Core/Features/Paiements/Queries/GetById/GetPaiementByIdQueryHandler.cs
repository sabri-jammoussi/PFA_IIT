using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Paiements.Queries.GetById;

public class GetPaiementByIdQueryHandler : IQueryHandler<GetPaiementByIdQuery, PaiementDto>
{
    private readonly DentisteContext _context;

    public GetPaiementByIdQueryHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<PaiementDto>> Handle(GetPaiementByIdQuery request, CancellationToken cancellationToken)
    {
        var paiement = await _context.Paiements
            .AsNoTracking()
            .Select(p => new PaiementDto
            {
                Id = p.Id,
                DatePaiement = p.DatePaiement,
                Montant = p.Montant,
                ModePaiement = p.ModePaiement,
                FactureId = p.FactureId,
                FactureNumero = p.Facture.NumeroFacture
            })
            .FirstOrDefaultAsync(p => p.Id == request.Id, cancellationToken);

        if (paiement == null)
        {
            return Result.Failure<PaiementDto>(Errors.PaiementNotFound);
        }

        return Result.Success(paiement);
    }
}
