using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Appointments.Queries.GetWaitingRoom;

public class GetWaitingRoomQueryHandler : IQueryHandler<GetWaitingRoomQuery, List<WaitingRoomEntryDto>>
{
    private readonly DentisteContext _context;

    public GetWaitingRoomQueryHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<List<WaitingRoomEntryDto>>> Handle(GetWaitingRoomQuery request, CancellationToken cancellationToken)
    {
        // Patients who have been checked in by the secretary and not yet completed.
        var query = _context.RendezVous
            .AsNoTracking()
            .Where(r => r.Statut == "EnConsultation");

        if (request.DentisteId.HasValue)
        {
            query = query.Where(r => r.DentisteId == request.DentisteId.Value);
        }

        var items = await query
            .OrderBy(r => r.ActualArrivalAt)
            .Select(r => new WaitingRoomEntryDto
            {
                AppointmentId = r.Id,
                PatientId = r.PatientId,
                PatientNomComplet = r.Patient.Nom + " " + r.Patient.Prenom,
                Motif = r.Motif,
                DentisteId = r.DentisteId,
                ArrivalTime = r.ActualArrivalAt,
                AntecedentsMedicaux = r.Patient.AntecedentsMedicaux,
                LastVisitDate = _context.Consultations
                    .Where(c => c.PatientId == r.PatientId)
                    .OrderByDescending(c => c.DateConsultation)
                    .Select(c => (System.DateTime?)c.DateConsultation)
                    .FirstOrDefault(),
                LastVisitNotes = _context.Consultations
                    .Where(c => c.PatientId == r.PatientId)
                    .OrderByDescending(c => c.DateConsultation)
                    .Select(c => c.NotesObservations)
                    .FirstOrDefault()
            })
            .ToListAsync(cancellationToken);

        return Result.Success(items);
    }
}
