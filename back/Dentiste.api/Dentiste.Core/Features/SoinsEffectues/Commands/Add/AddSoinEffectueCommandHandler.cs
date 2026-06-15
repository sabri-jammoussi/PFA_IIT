using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;
using Dentiste.Data.Models;

namespace Dentiste.Core.Features.SoinsEffectues.Commands.Add;

public class AddSoinEffectueCommandHandler : ICommandHandler<AddSoinEffectueCommand, int>
{
    private readonly DentisteContext _context;

    public AddSoinEffectueCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<int>> Handle(AddSoinEffectueCommand request, CancellationToken cancellationToken)
    {
        var consultation = await _context.Consultations
            .FirstOrDefaultAsync(c => c.Id == request.ConsultationId, cancellationToken);
        if (consultation == null)
        {
            return Result.Failure<int>(Errors.ConsultationNotFound);
        }

        var acteMedicalExists = await _context.ActesMedicaux.AnyAsync(a => a.Id == request.ActeMedicalId, cancellationToken);
        if (!acteMedicalExists)
        {
            return Result.Failure<int>(Errors.ActeMedicalNotFound);
        }

        var soin = new SoinEffectueDao
        {
            NumeroDent = request.NumeroDent,
            FaceDentaire = request.FaceDentaire,
            PrixApplique = request.PrixApplique,
            Notes = request.Notes,
            ConsultationId = request.ConsultationId,
            ActeMedicalId = request.ActeMedicalId
        };

        _context.SoinsEffectues.Add(soin);

        // ── Automatic Invoice Generation ──
        var year = DateTime.UtcNow.Year;
        var prefix = $"FAC-{year}-";
        var lastFacture = await _context.Factures
            .IgnoreQueryFilters()
            .Where(f => f.CabinetId == consultation.CabinetId && f.NumeroFacture.StartsWith(prefix))
            .OrderByDescending(f => f.NumeroFacture)
            .FirstOrDefaultAsync(cancellationToken);

        int nextSeq = 1;
        if (lastFacture != null)
        {
            var parts = lastFacture.NumeroFacture.Split('-');
            if (parts.Length == 3 && int.TryParse(parts[2], out int lastSeq))
            {
                nextSeq = lastSeq + 1;
            }
        }
        var numeroFacture = $"{prefix}{nextSeq:D4}";

        var facture = new FactureDao
        {
            NumeroFacture = numeroFacture,
            DateEmission = DateTime.UtcNow,
            MontantTotal = request.PrixApplique,
            MontantPaye = 0,
            StatutPaiement = "NonPaye",
            PatientId = consultation.PatientId,
            CabinetId = consultation.CabinetId
        };

        _context.Factures.Add(facture);

        // ── Automatic Inventory Deduction ──
        // Look up the "recipe" for this medical act and subtract required materials.
        // Stock is allowed to go negative so the doctor is never blocked;
        // the secretary will see the low-stock alert and order more supplies.
        var recettes = await _context.RecettesActes
            .Where(r => r.ActeMedicalId == request.ActeMedicalId)
            .ToListAsync(cancellationToken);

        foreach (var recette in recettes)
        {
            var article = await _context.Articles.FindAsync(new object[] { recette.ArticleId }, cancellationToken);
            if (article != null)
            {
                article.QuantiteEnStock -= recette.QuantiteRequise;
            }
        }

        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success(soin.Id);
    }
}
