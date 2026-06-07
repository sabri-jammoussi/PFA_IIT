using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Dentiste.Data.Models;

[Table("ROLE")]
public class RoleDao
{
    [Key]
    [Column("ROL_ID")]
    public int Id { get; set; }

    [Required, MaxLength(30)]
    [Column("ROL_NAME")]
    public string Name { get; set; } = string.Empty; // "Admin", "Dentiste", "Secretaire"

    [Column("ROL_DESCRIPTION")]
    public string? Description { get; set; }

    public ICollection<UserDao> Users { get; set; } = new List<UserDao>();
}
