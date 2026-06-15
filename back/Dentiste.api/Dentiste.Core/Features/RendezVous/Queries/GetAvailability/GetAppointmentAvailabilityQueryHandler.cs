using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;
using MediatR;

namespace Dentiste.Core.Features.RendezVous.Queries.GetAvailability;

public class GetAppointmentAvailabilityQueryHandler : IRequestHandler<GetAppointmentAvailabilityQuery, Result<List<AppointmentSlotDto>>>
{
    private readonly DentisteContext _context;

    public GetAppointmentAvailabilityQueryHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<List<AppointmentSlotDto>>> Handle(GetAppointmentAvailabilityQuery request, CancellationToken cancellationToken)
    {
        var dateOnly = request.Date.Date;
        var nextDay = dateOnly.AddDays(1);

        // Fetch existing active appointments for this dentist on the selected day
        var existingAppointments = await _context.RendezVous
            .AsNoTracking()
            .Where(rv => rv.DentisteId == request.DentistId 
                         && rv.DateHeure >= dateOnly 
                         && rv.DateHeure < nextDay
                         && rv.Statut != "Annule" 
                         && rv.Statut != "Annulé")
            .ToListAsync(cancellationToken);

        // Standard 30-minute slots definition
        var standardTimes = new List<string>
        {
            "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00",
            "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30"
        };

        var slots = new List<AppointmentSlotDto>();
        var now = DateTime.Now; // local system time

        foreach (var timeStr in standardTimes)
        {
            var timeParts = timeStr.Split(':');
            var hours = int.Parse(timeParts[0]);
            var minutes = int.Parse(timeParts[1]);

            var slotStart = dateOnly.AddHours(hours).AddMinutes(minutes);
            var slotEnd = slotStart.AddMinutes(30);

            // A slot is available if it starts in the future and does not overlap with any existing appointment
            bool isPast = slotStart <= now;
            bool hasOverlap = existingAppointments.Any(app => 
                slotStart < app.DateHeure.Add(app.DureeEstimee) && app.DateHeure < slotEnd);

            slots.Add(new AppointmentSlotDto
            {
                Time = timeStr,
                DateTime = slotStart,
                IsAvailable = !isPast && !hasOverlap
            });
        }

        return Result.Success(slots);
    }
}
