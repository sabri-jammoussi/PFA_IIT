using System.Collections.Generic;
using MediatR;
using Dentiste.Core.Shared;

namespace Dentiste.Core.Features.RendezVous.Queries.GetPending;

public record GetPendingAppointmentsQuery() : IRequest<Result<List<PendingAppointmentDto>>>;

public class PendingAppointmentDto
{
    public int Id { get; set; }
    public DateTime DateHeure { get; set; }
    public string? Motif { get; set; }
    public int PatientId { get; set; }
    public string? PatientNomComplet { get; set; }
    public int DentisteId { get; set; }
    public string? DentisteNomComplet { get; set; }
}
