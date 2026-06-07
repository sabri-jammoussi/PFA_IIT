using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Dentiste.Data.Models;

[Table("RENDEZ_VOUS")]
public class RendezVousDao
{
    [Key]
    [Column("RDV_ID")]
    public int Id { get; set; }

    [Required]
    [Column("RDV_DATE_HEURE")]
    public DateTime DateHeure { get; set; }

    [Required]
    [Column("RDV_DUREE_ESTIMEE")]
    public TimeSpan DureeEstimee { get; set; } // ex: 00:30:00

    [Required, MaxLength(30)]
    [Column("RDV_STATUT")]
    public string Statut { get; set; } = "Planifie"; // "Planifie", "Confirme", "Annule", "Complete"

    [Column("RDV_MOTIF")]
    public string? Motif { get; set; }

    [Column("RDV_NOTE")]
    public string? Note { get; set; }

    // Relations
    [Required]
    [Column("RDV_PATIENT_ID")]
    public int PatientId { get; set; }
    public PatientDao Patient { get; set; } = null!;

    [Required]
    [Column("RDV_DENTISTE_ID")]
    public int DentisteId { get; set; }
    public UserDao Dentiste { get; set; } = null!; // L'utilisateur ayant le rôle Dentiste
}
