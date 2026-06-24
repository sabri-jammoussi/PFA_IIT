using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Core.Infrastructure.Security;
using Dentiste.Data.Infrastructure.EF;
using Dentiste.Data.Models;

namespace Dentiste.Core.Features.Consultations.Commands.Finalize;

public class FinalizeConsultationCommandHandler
    : ICommandHandler<FinalizeConsultationCommand, FinalizeConsultationResult>
{
    private readonly DentisteContext _context;
    private readonly ICurrentUserProvider _currentUserProvider;

    public FinalizeConsultationCommandHandler(DentisteContext context, ICurrentUserProvider currentUserProvider)
    {
        _context = context;
        _currentUserProvider = currentUserProvider;
    }

    public async Task<Result<FinalizeConsultationResult>> Handle(
        FinalizeConsultationCommand request, CancellationToken cancellationToken)
    {
        var consultation = await _context.Consultations
            .Include(c => c.Patient)
            .FirstOrDefaultAsync(c => c.Id == request.ConsultationId, cancellationToken);
        if (consultation == null)
        {
            return Result.Failure<FinalizeConsultationResult>(Errors.ConsultationNotFound);
        }

        // Guard against double billing: one invoice per finalized consultation.
        var alreadyInvoiced = await _context.Factures
            .AnyAsync(f => f.ConsultationId == request.ConsultationId, cancellationToken);
        if (alreadyInvoiced)
        {
            return Result.Failure<FinalizeConsultationResult>(Errors.ConsultationAlreadyFinalized);
        }

        var soins = await _context.SoinsEffectues
            .Where(s => s.ConsultationId == request.ConsultationId)
            .ToListAsync(cancellationToken);
        if (soins.Count == 0)
        {
            return Result.Failure<FinalizeConsultationResult>(Errors.NoTreatmentsToInvoice);
        }

        var montantTotal = soins.Sum(s => s.PrixApplique);

        // ── Generate a sequential invoice number per cabinet: FAC-YYYY-NNNN ──
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
            MontantTotal = montantTotal,
            MontantPaye = 0,
            StatutPaiement = "NonPaye",
            PatientId = consultation.PatientId,
            ConsultationId = consultation.Id,
            CabinetId = consultation.CabinetId
        };
        _context.Factures.Add(facture);

        await _context.SaveChangesAsync(cancellationToken);

        var patientNomComplet = consultation.Patient != null
            ? $"{consultation.Patient.Prenom} {consultation.Patient.Nom}".Trim()
            : "Patient";

        // Payload consumed by the notification microservice (FinalizeConsultationMapper).
        var currentUserId = _currentUserProvider.GetUserId() ?? consultation.DentisteId;
        request.EventPayload = new
        {
            FactureId = facture.Id,
            ConsultationId = consultation.Id,
            Montant = montantTotal,
            PatientName = patientNomComplet,
            CreatedBy = currentUserId
        };

        return Result.Success(new FinalizeConsultationResult
        {
            FactureId = facture.Id,
            NumeroFacture = numeroFacture,
            MontantTotal = montantTotal,
            PatientId = consultation.PatientId,
            PatientNomComplet = patientNomComplet
        });
    }
}
