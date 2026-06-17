using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Dentiste.Data.Models;

[Table("IMAGE_VERSION")]
public class ImageVersionDao
{
    [Key]
    [Column("IV_ID")]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int Id { get; set; }

    [Required, MaxLength(255)]
    [Column("IV_IM_ID")]
    public string ImageId { get; set; } = string.Empty;

    [Required]
    [Column("IV_VERSION")]
    public long Version { get; set; }
}
