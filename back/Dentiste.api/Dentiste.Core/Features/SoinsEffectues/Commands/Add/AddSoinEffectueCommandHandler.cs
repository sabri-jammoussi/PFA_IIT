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

        // NOTE: Recording a treatment no longer creates an invoice or deducts stock on its own.
        // - Invoicing is now done once per visit when the dentist finalizes the consultation
        //   (see FinalizeConsultationCommand): one Facture = sum of the consultation's treatments.
        // - Stock is consumed manually by the dentist via ConsommationArticle (RecetteActe only
        //   serves as an editable suggestion on the client), so no blind auto-deduction here.
        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success(soin.Id);
    }
}
