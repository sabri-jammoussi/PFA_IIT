using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Dentiste.Data.Models;

[Table("RECETTE_ACTE")]
public class RecetteActeDao
{
    [Key]
    [Column("REC_ID")]
    public int Id { get; set; }

    [Required]
    [Column("REC_QUANTITE_REQUISE")]
    public int QuantiteRequise { get; set; } // e.g., 1 dose, 2 paires

    // Relations
    [Required]
    [Column("REC_ACTE_MEDICAL_ID")]
    public int ActeMedicalId { get; set; }
    public ActeMedicalDao ActeMedical { get; set; } = null!;

    [Required]
    [Column("REC_ARTICLE_ID")]
    public int ArticleId { get; set; }
    public ArticleDao Article { get; set; } = null!;

    // Multi-tenant Foreign Key
    [Required]
    [Column("REC_CABINET_ID")]
    public int CabinetId { get; set; }
    public CabinetDao Cabinet { get; set; } = null!;
}
