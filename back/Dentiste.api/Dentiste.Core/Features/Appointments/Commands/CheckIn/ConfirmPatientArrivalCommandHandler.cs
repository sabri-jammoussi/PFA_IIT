using Dentiste.Core.Infrastructure.Tenant;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure;
using Dentiste.Data.Infrastructure.EF;
using Microsoft.EntityFrameworkCore;

namespace Dentiste.Core.Features.Appointments.Commands.CheckIn;

public class ConfirmPatientArrivalCommandHandler : ICommandHandler<ConfirmPatientArrivalCommand, AppointmentArrivalDto>
{
    private readonly DentisteContext _context;
    private readonly ITenantProvider _tenantProvider;

    public ConfirmPatientArrivalCommandHandler(DentisteContext context, ITenantProvider tenantProvider)
    {
        _context = context;
        _tenantProvider = tenantProvider;
    }

    public async Task<Result<AppointmentArrivalDto>> Handle(ConfirmPatientArrivalCommand request, CancellationToken cancellationToken)
    {
        var cabinetId = _tenantProvider.GetCabinetId();

        var appointment = await _context.RendezVous
            .Include(r => r.Patient)
            .FirstOrDefaultAsync(r => r.Id == request.AppointmentId && r.CabinetId == cabinetId, cancellationToken);

        if (appointment == null)
        {
            return Result.Failure<AppointmentArrivalDto>("Rendez-vous introuvable.");
        }

        if (appointment.Statut != "Planifie" && appointment.Statut != "Confirme")
        {
            return Result.Failure<AppointmentArrivalDto>($"Le rendez-vous ne peut pas être passé en consultation car il est '{appointment.Statut}'.");
        }

        appointment.Statut = "EnConsultation";
        appointment.ActualArrivalAt = DateTime.UtcNow;

        await _context.SaveChangesAsync(cancellationToken);

        int age = 0;
        if (appointment.Patient.DateNaissance != default)
        {
            var today = DateTime.Today;
            age = today.Year - appointment.Patient.DateNaissance.Year;
            if (appointment.Patient.DateNaissance.Date > today.AddYears(-age)) age--;
        }

        var dto = new AppointmentArrivalDto
        {
            AppointmentId = appointment.Id,
            PatientId = appointment.PatientId,
            PatientName = $"{appointment.Patient.Prenom} {appointment.Patient.Nom}".Trim(),
            PatientAge = age,
            Motif = appointment.Motif,
            DoctorId = appointment.DentisteId,
            ArrivalTime = appointment.ActualArrivalAt.Value
        };

        return Result.Success(dto);
    }
}
