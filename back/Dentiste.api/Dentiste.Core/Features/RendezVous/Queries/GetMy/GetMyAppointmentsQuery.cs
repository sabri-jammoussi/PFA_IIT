using System.Collections.Generic;
using MediatR;
using Dentiste.Core.Shared;

namespace Dentiste.Core.Features.RendezVous.Queries.GetMy;

public record GetMyAppointmentsQuery() : IRequest<Result<List<PatientAppointmentDto>>>;

public class PatientAppointmentDto
{
    public int Id { get; set; }
    public DateTime DateHeure { get; set; }
    public string Statut { get; set; } = string.Empty;
    public string? Motif { get; set; }
    public string? DentisteNomComplet { get; set; }
}
