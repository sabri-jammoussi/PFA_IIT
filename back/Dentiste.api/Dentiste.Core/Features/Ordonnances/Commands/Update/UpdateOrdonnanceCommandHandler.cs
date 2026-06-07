using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Ordonnances.Commands.Update;

public class UpdateOrdonnanceCommandHandler : ICommandHandler<UpdateOrdonnanceCommand>
{
    private readonly DentisteContext _context;

    public UpdateOrdonnanceCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result> Handle(UpdateOrdonnanceCommand request, CancellationToken cancellationToken)
    {
        var ordonnance = await _context.Ordonnances.FirstOrDefaultAsync(o => o.Id == request.Id, cancellationToken);
        if (ordonnance == null)
        {
            return Result.Failure(Errors.OrdonnanceNotFound);
        }

        var consultationExists = await _context.Consultations.AnyAsync(c => c.Id == request.ConsultationId, cancellationToken);
        if (!consultationExists)
        {
            return Result.Failure(Errors.ConsultationNotFound);
        }

        if (ordonnance.ConsultationId != request.ConsultationId)
        {
            var ordonnanceExists = await _context.Ordonnances.AnyAsync(o => o.ConsultationId == request.ConsultationId && o.Id != request.Id, cancellationToken);
            if (ordonnanceExists)
            {
                return Result.Failure(Errors.ConsultationAlreadyHasOrdonnance);
            }
        }

        ordonnance.DateEmission = request.DateEmission;
        ordonnance.Traitement = request.Traitement;
        ordonnance.ConsultationId = request.ConsultationId;

        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success();
    }
}
