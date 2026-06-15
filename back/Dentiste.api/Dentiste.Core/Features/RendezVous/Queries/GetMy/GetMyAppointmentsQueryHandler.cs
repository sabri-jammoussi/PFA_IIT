using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Infrastructure.Security;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.RendezVous.Queries.GetMy;

public class GetMyAppointmentsQueryHandler : MediatR.IRequestHandler<GetMyAppointmentsQuery, Result<List<PatientAppointmentDto>>>
{
    private readonly DentisteContext _context;
    private readonly ICurrentUserProvider _currentUserProvider;

    public GetMyAppointmentsQueryHandler(DentisteContext context, ICurrentUserProvider currentUserProvider)
    {
        _context = context;
        _currentUserProvider = currentUserProvider;
    }

    public async Task<Result<List<PatientAppointmentDto>>> Handle(GetMyAppointmentsQuery request, CancellationToken cancellationToken)
    {
        var userId = _currentUserProvider.GetUserId();
        if (!userId.HasValue)
        {
            return Result.Failure<List<PatientAppointmentDto>>("Utilisateur non authentifié.");
        }

        // Get user account to find email
        var user = await _context.Users
            .AsNoTracking()
            .FirstOrDefaultAsync(u => u.Id == userId.Value, cancellationToken);
        if (user == null)
        {
            return Result.Failure<List<PatientAppointmentDto>>("Utilisateur non trouvé.");
        }

        // Get patient matching the email
        var patient = await _context.Patients
            .AsNoTracking()
            .FirstOrDefaultAsync(p => p.Email == user.Email, cancellationToken);
        if (patient == null)
        {
            return Result.Failure<List<PatientAppointmentDto>>("Dossier patient introuvable.");
        }

        // Query appointments for the patient
        var appointments = await _context.RendezVous
            .AsNoTracking()
            .Include(rv => rv.Dentiste)
            .Where(rv => rv.PatientId == patient.Id)
            .OrderByDescending(rv => rv.DateHeure)
            .Select(rv => new PatientAppointmentDto
            {
                Id = rv.Id,
                DateHeure = rv.DateHeure,
                Statut = rv.Statut,
                Motif = rv.Motif,
                DentisteNomComplet = rv.Dentiste != null ? $"{rv.Dentiste.Prenom} {rv.Dentiste.Nom}" : "Non assigné"
            })
            .ToListAsync(cancellationToken);

        return Result.Success(appointments);
    }
}
