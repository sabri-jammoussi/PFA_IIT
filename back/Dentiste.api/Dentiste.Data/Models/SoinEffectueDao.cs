using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Dentiste.Data.Models;

[Table("SOIN_EFFECTUE")]
public class SoinEffectueDao
{
    [Key]
    [Column("SOI_ID")]
    public int Id { get; set; }

    // Numéro de la dent selon le système ISO/FDI (Ex: 11, 23, 36, 48). 
    // Peut être NULL si le soin concerne toute la bouche (ex: Détartrage).
    [Column("SOI_NUMERO_DENT")]
    public int? NumeroDent { get; set; }

    [MaxLength(50)]
    [Column("SOI_FACE_DENTAIRE")]
    public string? FaceDentaire { get; set; } // Mésiale, Distale, Occlusale, Vestibulaire, Linguale

    [Required]
    [Column("SOI_PRIX_APPLIQUE", TypeName = "decimal(18,2)")]
    public decimal PrixApplique { get; set; } // Permet d'appliquer une remise par rapport au tarif de base

    [Column("SOI_NOTES")]
    public string? Notes { get; set; }

    // Relations
    [Required]
    [Column("SOI_CONSULTATION_ID")]
    public int ConsultationId { get; set; }
    public ConsultationDao Consultation { get; set; } = null!;

    [Required]
    [Column("SOI_ACTE_MEDICAL_ID")]
    public int ActeMedicalId { get; set; }
    public ActeMedicalDao ActeMedical { get; set; } = null!;

    // Multi-tenant Foreign Key
    [Required]
    [Column("SOI_CABINET_ID")]
    public int CabinetId { get; set; }
    public CabinetDao Cabinet { get; set; } = null!;
}
