using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Dentiste.Data.Enums;

namespace Dentiste.Data.Models
{
    [Table("NOTIFICATION")]
    public class NotificationDao
    {
        [Key]
        [Column("NTF_ID")]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }

        [Required]
        [Column("NTF_NATURE")]
        public NotificationNature Nature { get; set; }

        [Required]
        [Column("NTF_ENTITY_ID")]
        public int EntityId { get; set; }

        [Required]
        [Column("NTF_ENTITY_CODE")]
        public string EntityCode { get; set; } = string.Empty;

        [Required]
        [Column("NTF_TITLE")]
        public string Title { get; set; } = string.Empty;

        [Required]
        [Column("NTF_NOTE")]
        public string Description { get; set; } = string.Empty;

        [Required]
        [Column("NO_DOMAINE")]
        public NotificationDomaine Domaine { get; set; }

        [Required]
        [Column("USR_ID_CREATED_BY")]
        public int CreatedBy { get; set; }

        [Required]
        [Column("USR_ID_CREATED_TO")]
        public int CreatedTo { get; set; }

        [Column("NTF_DATE")]
        public DateTime DateRappel { get; set; }

        [Column("NTF_SEEN")]
        public bool IsSeen { get; set; }

        [Column("NTF_TYPE")]
        public NotificationType Type { get; set; }

        [Required]
        [Column("NTF_DEMANDE_ID")]
        public int DemandeId { get; set; }

        [ForeignKey(nameof(CreatedBy))]
        public virtual UserDao CreatedByUser { get; set; } = null!;

        [ForeignKey(nameof(CreatedTo))]
        public virtual UserDao CreatedToUser { get; set; } = null!;

        // Multi-tenant Foreign Key
        [Required]
        [Column("NTF_CABINET_ID")]
        public int CabinetId { get; set; }
        public virtual CabinetDao Cabinet { get; set; } = null!;
    }
}
