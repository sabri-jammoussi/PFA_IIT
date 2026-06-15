using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Dentiste.Data.Models;

[Table("FACTURE")]
public class FactureDao
{
    [Key]
    [Column("FAC_ID")]
    public int Id { get; set; }

    [Required, MaxLength(20)]
    [Column("FAC_NUMERO_FACTURE")]
    public string NumeroFacture { get; set; } = string.Empty; // Format unique type FACT-2026-0001

    [Required]
    [Column("FAC_DATE_EMISSION")]
    public DateTime DateEmission { get; set; } = DateTime.UtcNow;

    [Required]
    [Column("FAC_MONTANT_TOTAL", TypeName = "decimal(18,2)")]
    public decimal MontantTotal { get; set; }

    [Required]
    [Column("FAC_MONTANT_PAYE", TypeName = "decimal(18,2)")]
    public decimal MontantPaye { get; set; } = 0;

    [Required, MaxLength(30)]
    [Column("FAC_STATUT_PAIEMENT")]
    public string StatutPaiement { get; set; } = "NonPaye"; // "NonPaye", "Partiel", "Paye"

    // Relations
    [Required]
    [Column("FAC_PATIENT_ID")]
    public int PatientId { get; set; }
    public PatientDao Patient { get; set; } = null!;

    public ICollection<PaiementDao> Paiements { get; set; } = new List<PaiementDao>();

    // Multi-tenant Foreign Key
    [Required]
    [Column("FAC_CABINET_ID")]
    public int CabinetId { get; set; }
    public CabinetDao Cabinet { get; set; } = null!;
}
