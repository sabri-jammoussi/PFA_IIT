using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;
using Dentiste.Data.Models;

namespace Dentiste.Core.Features.RendezVous.Commands.Add;

public class AddRendezVousCommandHandler : ICommandHandler<AddRendezVousCommand, int>
{
    private readonly DentisteContext _context;
    private readonly Dentiste.Core.Infrastructure.Security.ICurrentUserProvider _currentUserProvider;

    public AddRendezVousCommandHandler(DentisteContext context, Dentiste.Core.Infrastructure.Security.ICurrentUserProvider currentUserProvider)
    {
        _context = context;
        _currentUserProvider = currentUserProvider;
    }

    public async Task<Result<int>> Handle(AddRendezVousCommand request, CancellationToken cancellationToken)
    {
        var patientExists = await _context.Patients.AnyAsync(p => p.Id == request.PatientId, cancellationToken);
        if (!patientExists)
        {
            return Result.Failure<int>(Errors.PatientNotFound);
        }

        var dentisteExists = await _context.Users.AnyAsync(u => u.Id == request.DentisteId, cancellationToken);
        if (!dentisteExists)
        {
            return Result.Failure<int>(Errors.DentisteNotFound);
        }

        var rdv = new RendezVousDao
        {
            DateHeure = request.DateHeure,
            DureeEstimee = request.DureeEstimee,
            Statut = request.Statut,
            Motif = request.Motif,
            Note = request.Note,
            PatientId = request.PatientId,
            DentisteId = request.DentisteId
        };

        _context.RendezVous.Add(rdv);
        await _context.SaveChangesAsync(cancellationToken);

        var currentUserId = _currentUserProvider.GetUserId() ?? 1;
        request.EventPayload = new
        {
            RendezVousId = rdv.Id,
            DentisteId = request.DentisteId,
            PatientId = request.PatientId,
            CreatedBy = currentUserId
        };

        return Result.Success(rdv.Id);
    }
}
