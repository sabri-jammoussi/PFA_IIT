using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.RendezVous.Commands.Update;

public class UpdateRendezVousCommandHandler : ICommandHandler<UpdateRendezVousCommand>
{
    private readonly DentisteContext _context;

    public UpdateRendezVousCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result> Handle(UpdateRendezVousCommand request, CancellationToken cancellationToken)
    {
        var rdv = await _context.RendezVous.FirstOrDefaultAsync(r => r.Id == request.Id, cancellationToken);
        if (rdv == null)
        {
            return Result.Failure(Errors.RendezVousNotFound);
        }

        var patientExists = await _context.Patients.AnyAsync(p => p.Id == request.PatientId, cancellationToken);
        if (!patientExists)
        {
            return Result.Failure(Errors.PatientNotFound);
        }

        var dentisteExists = await _context.Users.AnyAsync(u => u.Id == request.DentisteId, cancellationToken);
        if (!dentisteExists)
        {
            return Result.Failure(Errors.DentisteNotFound);
        }

        rdv.DateHeure = request.DateHeure;
        rdv.DureeEstimee = request.DureeEstimee;
        rdv.Statut = request.Statut;
        rdv.Motif = request.Motif;
        rdv.Note = request.Note;
        rdv.PatientId = request.PatientId;
        rdv.DentisteId = request.DentisteId;

        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success();
    }
}
