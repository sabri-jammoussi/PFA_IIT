using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Dentiste.Data.Models;

[Table("USER")]
public class UserDao
{
    [Key]
    [Column("USR_ID")]
    public int Id { get; set; }

    [Required, MaxLength(50)]
    [Column("USR_USERNAME")]
    public string Username { get; set; } = string.Empty;

    [Required, MaxLength(100)]
    [Column("USR_EMAIL")]
    public string Email { get; set; } = string.Empty;

    [Required, MaxLength(255)]
    [Column("USR_PASSWORD_HASH")] 
    public string PasswordHash { get; set; } = string.Empty;

    [Required, MaxLength(255)]
    [Column("USR_PASSWORD_SALT")]
    public string PasswordSalt { get; set; } = string.Empty;

    [Required, MaxLength(100)]
    [Column("USR_NOM")]
    public string Nom { get; set; } = string.Empty;

    [Required, MaxLength(100)]
    [Column("USR_PRENOM")]
    public string Prenom { get; set; } = string.Empty;

    [Column("USR_IS_ACTIVE")]
    public bool IsActive { get; set; } = true;

    [Column("USR_CREATED_AT")]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Clé Étrangère vers le Rôle
    [Required]
    [Column("USR_ROLE_ID")]
    public int RoleId { get; set; }
    public RoleDao Role { get; set; } = null!;
}
