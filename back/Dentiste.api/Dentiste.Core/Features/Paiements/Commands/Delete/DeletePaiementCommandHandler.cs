using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Paiements.Commands.Delete;

public class DeletePaiementCommandHandler : ICommandHandler<DeletePaiementCommand>
{
    private readonly DentisteContext _context;

    public DeletePaiementCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result> Handle(DeletePaiementCommand request, CancellationToken cancellationToken)
    {
        var paiement = await _context.Paiements
            .FirstOrDefaultAsync(p => p.Id == request.Id, cancellationToken);

        if (paiement == null)
        {
            return Result.Failure(Errors.PaiementNotFound);
        }

        var factureId = paiement.FactureId;

        _context.Paiements.Remove(paiement);
        await _context.SaveChangesAsync(cancellationToken);

        // Recalculate facture payment status
        var facture = await _context.Factures
            .Include(f => f.Paiements)
            .FirstOrDefaultAsync(f => f.Id == factureId, cancellationToken);

        if (facture != null)
        {
            var totalPaid = facture.Paiements.Sum(p => p.Montant);
            facture.MontantPaye = totalPaid;
            if (totalPaid >= facture.MontantTotal)
            {
                facture.StatutPaiement = "Paye";
            }
            else if (totalPaid > 0)
            {
                facture.StatutPaiement = "Partiel";
            }
            else
            {
                facture.StatutPaiement = "NonPaye";
            }
            await _context.SaveChangesAsync(cancellationToken);
        }

        return Result.Success();
    }
}
