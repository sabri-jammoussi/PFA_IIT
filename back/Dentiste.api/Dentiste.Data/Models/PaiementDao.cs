using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Dentiste.Data.Models;

[Table("PAIEMENT")]
public class PaiementDao
{
    [Key]
    [Column("PAI_ID")]
    public int Id { get; set; }

    [Required]
    [Column("PAI_DATE_PAIEMENT")]
    public DateTime DatePaiement { get; set; } = DateTime.UtcNow;

    [Required]
    [Column("PAI_MONTANT", TypeName = "decimal(18,2)")]
    public decimal Montant { get; set; }

    [Required, MaxLength(30)]
    [Column("PAI_MODE_PAIEMENT")]
    public string ModePaiement { get; set; } = "Especes"; // "Especes", "Cheque", "Carte"

    // Relations
    [Required]
    [Column("PAI_FACTURE_ID")]
    public int FactureId { get; set; }
    public FactureDao Facture { get; set; } = null!;
}
