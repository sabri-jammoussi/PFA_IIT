using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Consultations.Commands.Update;

public class UpdateConsultationCommandHandler : ICommandHandler<UpdateConsultationCommand>
{
    private readonly DentisteContext _context;

    public UpdateConsultationCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result> Handle(UpdateConsultationCommand request, CancellationToken cancellationToken)
    {
        var consultation = await _context.Consultations.FirstOrDefaultAsync(c => c.Id == request.Id, cancellationToken);
        if (consultation == null)
        {
            return Result.Failure(Errors.ConsultationNotFound);
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

        consultation.DateConsultation = request.DateConsultation;
        consultation.NotesObservations = request.NotesObservations;
        consultation.PatientId = request.PatientId;
        consultation.DentisteId = request.DentisteId;

        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success();
    }
}
