using System;

namespace Dentiste.Core.Features.RendezVous;

public class RendezVousDto
{
    public int Id { get; set; }
    public DateTime DateHeure { get; set; }
    public TimeSpan DureeEstimee { get; set; }
    public string Statut { get; set; } = string.Empty;
    public string? Motif { get; set; }
    public string? Note { get; set; }
    public int PatientId { get; set; }
    public string? PatientNomComplet { get; set; }
    public int DentisteId { get; set; }
    public string? DentisteNomComplet { get; set; }
}
