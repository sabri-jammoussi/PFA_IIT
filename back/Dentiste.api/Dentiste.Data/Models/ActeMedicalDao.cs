using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Dentiste.Data.Models;

[Table("ACTE_MEDICAL")]
public class ActeMedicalDao
{
    [Key]
    [Column("ACT_ID")]
    public int Id { get; set; }

    [Required, MaxLength(100)]
    [Column("ACT_LIBELLE")]
    public string Libelle { get; set; } = string.Empty; // "Détartrage", "Extraction", "Composite"

    [Required]
    [Column("ACT_TARIF_DE_BASE", TypeName = "decimal(18,2)")]
    public decimal TarifDeBase { get; set; }

    [Column("ACT_CODE_NOMENCLATURE")]
    public string? CodeNomenclature { get; set; } // Pour la CNAM / Assurances
}
