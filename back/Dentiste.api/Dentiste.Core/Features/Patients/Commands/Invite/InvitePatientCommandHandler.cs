using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Infrastructure.Security;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;
using Dentiste.Data.Models;

namespace Dentiste.Core.Features.Patients.Commands.Invite;

public class InvitePatientCommandHandler : ICommandHandler<InvitePatientCommand, int>
{
    private readonly DentisteContext _context;
    private readonly IPasswordHasher _passwordHasher;

    public InvitePatientCommandHandler(DentisteContext context, IPasswordHasher passwordHasher)
    {
        _context = context;
        _passwordHasher = passwordHasher;
    }

    public async Task<Result<int>> Handle(InvitePatientCommand request, CancellationToken cancellationToken)
    {
        // 1. Verify patient email doesn't already exist in Patient records
        var emailExistsInPatients = await _context.Patients
            .AnyAsync(p => p.Email == request.Email, cancellationToken);
        if (emailExistsInPatients)
        {
            return Result.Failure<int>(Errors.EmailAlreadyExists);
        }

        // 2. Verify email/username doesn't already exist in User accounts
        var emailExistsInUsers = await _context.Users
            .AnyAsync(u => u.Email == request.Email || u.Username == request.Email, cancellationToken);
        if (emailExistsInUsers)
        {
            return Result.Failure<int>(Errors.EmailAlreadyExists);
        }

        // 3. Generate a temporary random password
        var tempPassword = Guid.NewGuid().ToString("N")[..8];
        var salt = Guid.NewGuid().ToString("N");
        var passwordHash = _passwordHasher.Hash(tempPassword, salt);

        // 4. Create the PatientDao record
        var patient = new PatientDao
        {
            Nom = request.Nom,
            Prenom = request.Prenom,
            DateNaissance = request.DateNaissance,
            Telephone = request.Telephone,
            Email = request.Email,
            Adresse = request.Adresse,
            AntecedentsMedicaux = request.AntecedentsMedicaux,
            GroupSanguin = request.GroupSanguin,
            CreatedAt = DateTime.UtcNow
        };

        _context.Patients.Add(patient);

        // 5. Create the associated UserDao account for the patient (Role ID = 4)
        var user = new UserDao
        {
            Username = request.Email, // We use Email as Username for simplicity
            Email = request.Email,
            PasswordHash = passwordHash,
            PasswordSalt = salt,
            Nom = request.Nom,
            Prenom = request.Prenom,
            IsActive = true,
            RoleId = 4, // Role Patient
            CreatedAt = DateTime.UtcNow
        };

        _context.Users.Add(user);

        // 6. Save changes
        await _context.SaveChangesAsync(cancellationToken);

        // 7. Populate the command properties so the MediatR notification behavior enqueues it with the actual values
        request.PatientId = patient.Id;
        request.TemporaryPassword = tempPassword;

        return Result.Success(patient.Id);
    }
}
