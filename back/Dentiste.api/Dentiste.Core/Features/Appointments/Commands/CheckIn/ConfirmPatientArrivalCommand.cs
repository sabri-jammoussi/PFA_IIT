using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Appointments.Commands.CheckIn;

public class ConfirmPatientArrivalCommand : ICommand<AppointmentArrivalDto>
{
    public int AppointmentId { get; set; }
}
