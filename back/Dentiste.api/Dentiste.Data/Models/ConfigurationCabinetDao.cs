using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Dentiste.Data.Models;

[Table("CONFIGURATION_CABINET")]
public class ConfigurationCabinetDao
{
    [Key]
    [Column("CFG_ID")]
    public int Id { get; set; }

    [Required]
    [Column("CFG_CABINET_ID")]
    public int CabinetId { get; set; }
    
    public CabinetDao Cabinet { get; set; } = null!;

    [MaxLength(256)]
    [Column("CFG_SMTP_HOST")]
    public string? SmtpHost { get; set; }

    [Column("CFG_SMTP_PORT")]
    public int? SmtpPort { get; set; }

    [MaxLength(256)]
    [Column("CFG_SMTP_USERNAME")]
    public string? SmtpUsername { get; set; }

    [MaxLength(256)]
    [Column("CFG_SMTP_PASSWORD")]
    public string? SmtpPassword { get; set; }

    [Column("CFG_SMTP_SSL")]
    public bool? SmtpEnableSsl { get; set; }

    [MaxLength(256)]
    [Column("CFG_SENDER_NAME")]
    public string? SenderName { get; set; }
}
