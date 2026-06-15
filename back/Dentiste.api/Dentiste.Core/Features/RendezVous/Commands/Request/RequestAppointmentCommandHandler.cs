using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Infrastructure.Security;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;
using Dentiste.Data.Models;

namespace Dentiste.Core.Features.RendezVous.Commands.Request;

public class RequestAppointmentCommandHandler : ICommandHandler<RequestAppointmentCommand, int>
{
    private readonly DentisteContext _context;
    private readonly ICurrentUserProvider _currentUserProvider;

    public RequestAppointmentCommandHandler(DentisteContext context, ICurrentUserProvider currentUserProvider)
    {
        _context = context;
        _currentUserProvider = currentUserProvider;
    }

    public async Task<Result<int>> Handle(RequestAppointmentCommand request, CancellationToken cancellationToken)
    {
        var userId = _currentUserProvider.GetUserId();
        if (!userId.HasValue)
        {
            return Result.Failure<int>("Utilisateur non authentifié.");
        }

        // Get user account to find email
        var user = await _context.Users
            .AsNoTracking()
            .FirstOrDefaultAsync(u => u.Id == userId.Value, cancellationToken);
        if (user == null)
        {
            return Result.Failure<int>("Utilisateur non trouvé.");
        }

        // Get patient matching the email
        var patient = await _context.Patients
            .AsNoTracking()
            .FirstOrDefaultAsync(p => p.Email == user.Email, cancellationToken);
        if (patient == null)
        {
            return Result.Failure<int>("Dossier patient introuvable.");
        }

        // Check if dentist exists and is actually a dentist (role 2)
        var dentistExists = await _context.Users
            .AnyAsync(u => u.Id == request.DentisteId && u.RoleId == 2, cancellationToken);
        if (!dentistExists)
        {
            return Result.Failure<int>("Dentiste sélectionné introuvable.");
        }

        // Create the pending appointment
        var rdv = new RendezVousDao
        {
            DateHeure = request.DateHeure,
            DureeEstimee = TimeSpan.FromMinutes(30), // Default slot length
            Statut = "EnAttenteValidation",
            Motif = request.Motif,
            PatientId = patient.Id,
            DentisteId = request.DentisteId,
            Note = "Soumis par le patient via le portail mobile"
        };

        _context.RendezVous.Add(rdv);
        await _context.SaveChangesAsync(cancellationToken);

        request.EventPayload = new
        {
            RendezVousId = rdv.Id,
            DentisteId = request.DentisteId,
            PatientId = patient.Id,
            CreatedBy = userId.Value
        };

        return Result.Success(rdv.Id);
    }
}
