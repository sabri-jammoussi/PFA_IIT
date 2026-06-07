using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;
using Dentiste.Data.Models;

namespace Dentiste.Core.Features.Consultations.Commands.Add;

public class AddConsultationCommandHandler : ICommandHandler<AddConsultationCommand, int>
{
    private readonly DentisteContext _context;

    public AddConsultationCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<int>> Handle(AddConsultationCommand request, CancellationToken cancellationToken)
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

        var consultation = new ConsultationDao
        {
            DateConsultation = request.DateConsultation,
            NotesObservations = request.NotesObservations,
            PatientId = request.PatientId,
            DentisteId = request.DentisteId
        };

        _context.Consultations.Add(consultation);
        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success(consultation.Id);
    }
}
