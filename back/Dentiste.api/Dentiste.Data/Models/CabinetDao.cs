using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Dentiste.Data.Models;

[Table("CABINET")]
public class CabinetDao
{
    [Key]
    [Column("CAB_ID")]
    public int Id { get; set; }

    [Required, MaxLength(100)]
    [Column("CAB_NOM")]
    public string NomCabinet { get; set; } = string.Empty;

    [Column("CAB_ADRESSE")]
    public string? Adresse { get; set; }

    [Column("CAB_TELEPHONE")]
    public string? TelephoneCorporate { get; set; }

    [Column("CAB_CREATED_AT")]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    [Column("CAB_IS_ACTIVE")]
    public bool IsSubscriptionActive { get; set; } = true;

    public ICollection<UserDao> Users { get; set; } = new List<UserDao>();
}
