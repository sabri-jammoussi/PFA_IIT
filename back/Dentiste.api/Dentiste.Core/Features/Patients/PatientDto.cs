using System;

namespace Dentiste.Core.Features.Patients;

public class PatientDto
{
    public int Id { get; set; }
    public string Nom { get; set; } = string.Empty;
    public string Prenom { get; set; } = string.Empty;
    public DateTime DateNaissance { get; set; }
    public string Telephone { get; set; } = string.Empty;
    public string? Email { get; set; }
    public string? Adresse { get; set; }
    public string? AntecedentsMedicaux { get; set; }
    public string? GroupSanguin { get; set; }
    public DateTime CreatedAt { get; set; }
}
