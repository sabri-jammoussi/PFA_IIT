using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;
using Dentiste.Data.Models;

namespace Dentiste.Core.Features.Ordonnances.Commands.Add;

public class AddOrdonnanceCommandHandler : ICommandHandler<AddOrdonnanceCommand, int>
{
    private readonly DentisteContext _context;

    public AddOrdonnanceCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<int>> Handle(AddOrdonnanceCommand request, CancellationToken cancellationToken)
    {
        var consultationExists = await _context.Consultations.AnyAsync(c => c.Id == request.ConsultationId, cancellationToken);
        if (!consultationExists)
        {
            return Result.Failure<int>(Errors.ConsultationNotFound);
        }

        var ordonnanceExists = await _context.Ordonnances.AnyAsync(o => o.ConsultationId == request.ConsultationId, cancellationToken);
        if (ordonnanceExists)
        {
            return Result.Failure<int>(Errors.ConsultationAlreadyHasOrdonnance);
        }

        var ordonnance = new OrdonnanceDao
        {
            DateEmission = request.DateEmission,
            Traitement = request.Traitement,
            ConsultationId = request.ConsultationId
        };

        _context.Ordonnances.Add(ordonnance);
        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success(ordonnance.Id);
    }
}
