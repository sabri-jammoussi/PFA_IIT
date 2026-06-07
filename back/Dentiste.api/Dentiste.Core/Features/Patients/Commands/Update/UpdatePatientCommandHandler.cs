using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Patients.Commands.Update;

public class UpdatePatientCommandHandler : ICommandHandler<UpdatePatientCommand>
{
    private readonly DentisteContext _context;

    public UpdatePatientCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result> Handle(UpdatePatientCommand request, CancellationToken cancellationToken)
    {
        var patient = await _context.Patients
            .FirstOrDefaultAsync(p => p.Id == request.Id, cancellationToken);

        if (patient == null)
        {
            return Result.Failure(Errors.PatientNotFound);
        }

        if (!string.IsNullOrEmpty(request.Email) && request.Email != patient.Email)
        {
            var emailExists = await _context.Patients
                .AnyAsync(p => p.Email == request.Email && p.Id != request.Id, cancellationToken);

            if (emailExists)
            {
                return Result.Failure(Errors.EmailAlreadyExists);
            }
        }

        patient.Nom = request.Nom;
        patient.Prenom = request.Prenom;
        patient.DateNaissance = request.DateNaissance;
        patient.Telephone = request.Telephone;
        patient.Email = request.Email;
        patient.Adresse = request.Adresse;
        patient.AntecedentsMedicaux = request.AntecedentsMedicaux;
        patient.GroupSanguin = request.GroupSanguin;

        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success();
    }
}
