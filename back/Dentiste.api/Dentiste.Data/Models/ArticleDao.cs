using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Dentiste.Data.Models;

[Table("ARTICLE")]
public class ArticleDao
{
    [Key]
    [Column("ART_ID")]
    public int Id { get; set; }

    [Required, MaxLength(100)]
    [Column("ART_NOM")]
    public string Nom { get; set; } = string.Empty; // "Anesthésique Septodont", "Composite 3M"

    [Column("ART_DESCRIPTION")]
    public string? Description { get; set; }

    [Required]
    [Column("ART_QUANTITE_EN_STOCK")]
    public int QuantiteEnStock { get; set; }

    [Required]
    [Column("ART_SEUIL_ALERTE")]
    public int SeuilAlerte { get; set; } // Trigger low-stock alert when stock <= this value

    [MaxLength(50)]
    [Column("ART_UNITE")]
    public string Unite { get; set; } = "Unité"; // "Boîte", "Flacon", "Seringue", "Paire"

    // Multi-tenant Foreign Key
    [Required]
    [Column("ART_CABINET_ID")]
    public int CabinetId { get; set; }
    public CabinetDao Cabinet { get; set; } = null!;
}
