using FluentValidation;

namespace Dentiste.Core.Features.Appointments.Commands.CheckIn;

public class ConfirmPatientArrivalCommandValidator : AbstractValidator<ConfirmPatientArrivalCommand>
{
    public ConfirmPatientArrivalCommandValidator()
    {
        RuleFor(x => x.AppointmentId).GreaterThan(0).WithMessage("AppointmentId is required.");
    }
}
