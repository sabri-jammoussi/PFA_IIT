namespace Dentiste.Core.Features.Appointments.Commands.CheckIn;

public class AppointmentArrivalDto
{
    public int AppointmentId { get; set; }
    public int PatientId { get; set; }
    public string PatientName { get; set; } = string.Empty;
    public int PatientAge { get; set; }
    public string? Motif { get; set; }
    public int DoctorId { get; set; }
    public DateTime ArrivalTime { get; set; }
}
