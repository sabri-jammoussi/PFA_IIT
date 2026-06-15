using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Dentiste.Data.Models;

[Table("OPTION")]
public class OptionDao
{
    [Key]
    [Column("OPT_ID")]
    public int Id { get; set; }

    [Required, MaxLength(256)]
    [Column("OPT_NAME")]
    public string Name { get; set; } = string.Empty;

    [Required, MaxLength(1024)]
    [Column("OPT_VALUE")]
    public string Value { get; set; } = string.Empty;

    [Required]
    [Column("OPT_REQUIRED")]
    public bool Required { get; set; } = false;

    [MaxLength(512)]
    [Column("OPT_DESCRIPTION")]
    public string Description { get; set; } = string.Empty;

    [MaxLength(256)]
    [Column("OPT_LABEL")]
    public string Label { get; set; } = string.Empty;

    [Required, MaxLength(100)]
    [Column("OPT_GROUP")]
    public string Group { get; set; } = string.Empty;
}
