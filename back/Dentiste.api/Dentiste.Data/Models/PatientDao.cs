using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Dentiste.Data.Models;

[Table("PATIENT")]
public class PatientDao
{
    [Key]
    [Column("PAT_ID")]
    public int Id { get; set; }

    [Required, MaxLength(100)]
    [Column("PAT_NOM")]
    public string Nom { get; set; } = string.Empty;

    [Required, MaxLength(100)]
    [Column("PAT_PRENOM")]
    public string Prenom { get; set; } = string.Empty;

    [Required]
    [Column("PAT_DATE_NAISSANCE")]
    public DateTime DateNaissance { get; set; }

    [Required, MaxLength(20)]
    [Column("PAT_TELEPHONE")]
    public string Telephone { get; set; } = string.Empty;

    [Column("PAT_EMAIL")]
    public string? Email { get; set; }

    [Column("PAT_ADRESSE")]
    public string? Adresse { get; set; }

    // Données médicales critiques (chiffrement recommandé au niveau de l'application)
    [Column("PAT_ANTECEDENTS_MEDICAUX")]
    public string? AntecedentsMedicaux { get; set; } // Allergies, maladies chroniques

    [Column("PAT_GROUP_SANGUIN")]
    public string? GroupSanguin { get; set; }

    [Column("PAT_CREATED_AT")]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Relations
    public ICollection<RendezVousDao> RendezVous { get; set; } = new List<RendezVousDao>();
    public ICollection<ConsultationDao> Consultations { get; set; } = new List<ConsultationDao>();
    public ICollection<FactureDao> Factures { get; set; } = new List<FactureDao>();

    // Multi-tenant Foreign Key
    [Required]
    [Column("PAT_CABINET_ID")]
    public int CabinetId { get; set; }
    public CabinetDao Cabinet { get; set; } = null!;
}
