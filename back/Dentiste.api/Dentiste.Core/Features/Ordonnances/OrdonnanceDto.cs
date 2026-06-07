using System;

namespace Dentiste.Core.Features.Ordonnances;

public class OrdonnanceDto
{
    public int Id { get; set; }
    public DateTime DateEmission { get; set; }
    public string Traitement { get; set; } = string.Empty;
    public int ConsultationId { get; set; }
    public string? PatientNomComplet { get; set; }
}
