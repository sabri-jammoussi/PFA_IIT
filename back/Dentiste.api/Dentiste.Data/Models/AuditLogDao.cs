using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Dentiste.Data.Models;

[Table("AUDIT_LOG")]
public class AuditLogDao
{
    [Key]
    [Column("AUD_ID")]
    public int Id { get; set; }

    [Required, MaxLength(50)]
    [Column("AUD_ACTION")]
    public string Action { get; set; } = string.Empty; // "INSERT", "UPDATE", "DELETE"

    [Required, MaxLength(100)]
    [Column("AUD_TABLE_NAME")]
    public string TableName { get; set; } = string.Empty; // "Patient", "SoinEffectue"

    [Required]
    [Column("AUD_TIMESTAMP")]
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;

    [Required]
    [Column("AUD_USER_ID")]
    public string UserId { get; set; } = string.Empty; // Identifiant de l'auteur de l'action

    [Column("AUD_KEY_VALUES")]
    public string? KeyValues { get; set; } // L'ID de la ligne modifiée au format JSON

    [Column("AUD_OLD_VALUES")]
    public string? OldValues { get; set; } // Les anciennes valeurs avant modification (JSON)

    [Column("AUD_NEW_VALUES")]
    public string? NewValues { get; set; } // Les nouvelles valeurs (JSON)

    // Multi-tenant Foreign Key
    [Column("AUD_CABINET_ID")]
    public int? CabinetId { get; set; }
    public CabinetDao? Cabinet { get; set; }
}
