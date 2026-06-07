using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.SoinsEffectues.Commands.Update;

public class UpdateSoinEffectueCommandHandler : ICommandHandler<UpdateSoinEffectueCommand>
{
    private readonly DentisteContext _context;

    public UpdateSoinEffectueCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result> Handle(UpdateSoinEffectueCommand request, CancellationToken cancellationToken)
    {
        var soin = await _context.SoinsEffectues.FirstOrDefaultAsync(s => s.Id == request.Id, cancellationToken);
        if (soin == null)
        {
            return Result.Failure(Errors.SoinEffectueNotFound);
        }

        var consultationExists = await _context.Consultations.AnyAsync(c => c.Id == request.ConsultationId, cancellationToken);
        if (!consultationExists)
        {
            return Result.Failure(Errors.ConsultationNotFound);
        }

        var acteMedicalExists = await _context.ActesMedicaux.AnyAsync(a => a.Id == request.ActeMedicalId, cancellationToken);
        if (!acteMedicalExists)
        {
            return Result.Failure(Errors.ActeMedicalNotFound);
        }

        soin.NumeroDent = request.NumeroDent;
        soin.FaceDentaire = request.FaceDentaire;
        soin.PrixApplique = request.PrixApplique;
        soin.Notes = request.Notes;
        soin.ConsultationId = request.ConsultationId;
        soin.ActeMedicalId = request.ActeMedicalId;

        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success();
    }
}
