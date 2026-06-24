using System;

namespace Dentiste.Core.Features.Appointments.Queries.GetWaitingRoom;

public class WaitingRoomEntryDto
{
    public int AppointmentId { get; set; }
    public int PatientId { get; set; }
    public string PatientNomComplet { get; set; } = string.Empty;
    public string? Motif { get; set; }
    public int DentisteId { get; set; }
    public DateTime? ArrivalTime { get; set; }

    // Small history of the patient's previous visit, shown when the doctor opens the file.
    public DateTime? LastVisitDate { get; set; }
    public string? LastVisitNotes { get; set; }
    public string? AntecedentsMedicaux { get; set; }
}
