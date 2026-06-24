using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Dentiste.Data.Models;

/// <summary>
/// A stock article manually consumed by the dentist during a consultation
/// (e.g. an anaesthetic cartridge, a composite syringe). Recording one
/// decrements the article's stock. These are tracked for inventory only and
/// do NOT add to the patient's invoice (the medical act price already covers
/// the consumables).
/// </summary>
[Table("CONSOMMATION_ARTICLE")]
public class ConsommationArticleDao
{
    [Key]
    [Column("CSM_ID")]
    public int Id { get; set; }

    [Required]
    [Column("CSM_QUANTITE")]
    public int Quantite { get; set; }

    [Column("CSM_DATE")]
    public DateTime DateConsommation { get; set; } = DateTime.UtcNow;

    // Relations
    [Required]
    [Column("CSM_CONSULTATION_ID")]
    public int ConsultationId { get; set; }
    public ConsultationDao Consultation { get; set; } = null!;

    [Required]
    [Column("CSM_ARTICLE_ID")]
    public int ArticleId { get; set; }
    public ArticleDao Article { get; set; } = null!;

    // Multi-tenant Foreign Key
    [Required]
    [Column("CSM_CABINET_ID")]
    public int CabinetId { get; set; }
    public CabinetDao Cabinet { get; set; } = null!;
}
