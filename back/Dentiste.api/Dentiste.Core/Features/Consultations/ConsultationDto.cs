using System;

namespace Dentiste.Core.Features.Consultations;

public class ConsultationDto
{
    public int Id { get; set; }
    public DateTime DateConsultation { get; set; }
    public string? NotesObservations { get; set; }
    public int PatientId { get; set; }
    public string? PatientNomComplet { get; set; }
    public int DentisteId { get; set; }
    public string? DentisteNomComplet { get; set; }
}
