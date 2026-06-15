using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;
using Dentiste.Data.Models;

namespace Dentiste.Core.Features.Paiements.Commands.Add;

public class AddPaiementCommandHandler : ICommandHandler<AddPaiementCommand, int>
{
    private readonly DentisteContext _context;
    private readonly Dentiste.Core.Infrastructure.Security.ICurrentUserProvider _currentUserProvider;

    public AddPaiementCommandHandler(DentisteContext context, Dentiste.Core.Infrastructure.Security.ICurrentUserProvider currentUserProvider)
    {
        _context = context;
        _currentUserProvider = currentUserProvider;
    }

    public async Task<Result<int>> Handle(AddPaiementCommand request, CancellationToken cancellationToken)
    {
        var facture = await _context.Factures
            .Include(f => f.Paiements)
            .FirstOrDefaultAsync(f => f.Id == request.FactureId, cancellationToken);

        if (facture == null)
        {
            return Result.Failure<int>(Errors.FactureNotFound);
        }

        // Recalculate Facture payment status (before adding the new payment to tracked collection to prevent double addition)
        var existingPaymentsSum = facture.Paiements.Sum(p => p.Montant);
        var totalPaid = existingPaymentsSum + request.Montant;
        
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

        var paiement = new PaiementDao
        {
            DatePaiement = request.DatePaiement,
            Montant = request.Montant,
            ModePaiement = request.ModePaiement,
            FactureId = request.FactureId
        };

        _context.Paiements.Add(paiement);

        await _context.SaveChangesAsync(cancellationToken);

        var currentUserId = _currentUserProvider.GetUserId() ?? 1;
        request.EventPayload = new
        {
            PaiementId = paiement.Id,
            FactureId = request.FactureId,
            Montant = request.Montant,
            CreatedBy = currentUserId
        };

        return Result.Success(paiement.Id);
    }
}
