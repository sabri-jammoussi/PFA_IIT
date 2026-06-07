using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Paiements.Commands.Update;

public class UpdatePaiementCommandHandler : ICommandHandler<UpdatePaiementCommand>
{
    private readonly DentisteContext _context;

    public UpdatePaiementCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result> Handle(UpdatePaiementCommand request, CancellationToken cancellationToken)
    {
        var paiement = await _context.Paiements
            .FirstOrDefaultAsync(p => p.Id == request.Id, cancellationToken);

        if (paiement == null)
        {
            return Result.Failure(Errors.PaiementNotFound);
        }

        var oldFactureId = paiement.FactureId;
        var newFactureId = request.FactureId;

        var newFactureExists = await _context.Factures.AnyAsync(f => f.Id == newFactureId, cancellationToken);
        if (!newFactureExists)
        {
            return Result.Failure(Errors.FactureNotFound);
        }

        paiement.DatePaiement = request.DatePaiement;
        paiement.Montant = request.Montant;
        paiement.ModePaiement = request.ModePaiement;
        paiement.FactureId = newFactureId;

        await _context.SaveChangesAsync(cancellationToken);

        // Recalculate old facture if different
        if (oldFactureId != newFactureId)
        {
            await RecalculateFacturePayments(oldFactureId, cancellationToken);
        }
        await RecalculateFacturePayments(newFactureId, cancellationToken);

        return Result.Success();
    }

    private async Task RecalculateFacturePayments(int factureId, CancellationToken cancellationToken)
    {
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
    }
}
