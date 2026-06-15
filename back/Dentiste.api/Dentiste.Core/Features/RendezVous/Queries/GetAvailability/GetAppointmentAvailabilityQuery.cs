using System;
using System.Collections.Generic;
using Dentiste.Core.Shared;
using MediatR;

namespace Dentiste.Core.Features.RendezVous.Queries.GetAvailability;

public record GetAppointmentAvailabilityQuery : IRequest<Result<List<AppointmentSlotDto>>>
{
    public required DateTime Date { get; init; }
    public required int DentistId { get; init; }
}

public class AppointmentSlotDto
{
    public string Time { get; set; } = string.Empty;
    public DateTime DateTime { get; set; }
    public bool IsAvailable { get; set; }
}
