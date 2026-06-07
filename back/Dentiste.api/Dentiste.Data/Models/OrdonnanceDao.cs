using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Dentiste.Data.Models;

[Table("ORDONNANCE")]
public class OrdonnanceDao
{
    [Key]
    [Column("ORD_ID")]
    public int Id { get; set; }

    [Required]
    [Column("ORD_DATE_EMISSION")]
    public DateTime DateEmission { get; set; } = DateTime.UtcNow;

    [Required]
    [Column("ORD_TRAITEMENT")]
    public string Traitement { get; set; } = string.Empty; // Contenu textuel structuré (Médicaments, posologie)

    // Relation un-à-un : Une ordonnance est liée à une unique consultation
    [Required]
    [Column("ORD_CONSULTATION_ID")]
    public int ConsultationId { get; set; }
    public ConsultationDao Consultation { get; set; } = null!;
}
