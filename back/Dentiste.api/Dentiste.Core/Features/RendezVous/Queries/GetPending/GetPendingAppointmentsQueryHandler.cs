using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.RendezVous.Queries.GetPending;

public class GetPendingAppointmentsQueryHandler : MediatR.IRequestHandler<GetPendingAppointmentsQuery, Result<List<PendingAppointmentDto>>>
{
    private readonly DentisteContext _context;

    public GetPendingAppointmentsQueryHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<List<PendingAppointmentDto>>> Handle(GetPendingAppointmentsQuery request, CancellationToken cancellationToken)
    {
        var pending = await _context.RendezVous
            .AsNoTracking()
            .Include(rv => rv.Patient)
            .Include(rv => rv.Dentiste)
            .Where(rv => rv.Statut == "EnAttenteValidation")
            .OrderBy(rv => rv.DateHeure)
            .Select(rv => new PendingAppointmentDto
            {
                Id = rv.Id,
                DateHeure = rv.DateHeure,
                Motif = rv.Motif,
                PatientId = rv.PatientId,
                PatientNomComplet = rv.Patient != null ? $"{rv.Patient.Prenom} {rv.Patient.Nom}" : "Inconnu",
                DentisteId = rv.DentisteId,
                DentisteNomComplet = rv.Dentiste != null ? $"{rv.Dentiste.Prenom} {rv.Dentiste.Nom}" : "Inconnu"
            })
            .ToListAsync(cancellationToken);

        return Result.Success(pending);
    }
}
