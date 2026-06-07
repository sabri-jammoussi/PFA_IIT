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
        var consultationExists = await _context.Consultations.AnyAsync(c => c.Id == request.ConsultationId, cancellationToken);
        if (!consultationExists)
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
        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success(soin.Id);
    }
}
