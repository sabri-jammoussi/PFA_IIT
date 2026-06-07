using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Dentiste.Data.Models;

[Table("CONSULTATION")]
public class ConsultationDao
{
    [Key]
    [Column("CON_ID")]
    public int Id { get; set; }

    [Required]
    [Column("CON_DATE_CONSULTATION")]
    public DateTime DateConsultation { get; set; } = DateTime.UtcNow;

    [Column("CON_NOTES_OBSERVATIONS")]
    public string? NotesObservations { get; set; } // Description libre de la séance

    // Relations
    [Required]
    [Column("CON_PATIENT_ID")]
    public int PatientId { get; set; }
    public PatientDao Patient { get; set; } = null!;

    [Required]
    [Column("CON_DENTISTE_ID")]
    public int DentisteId { get; set; }
    public UserDao Dentiste { get; set; } = null!;

    // Les soins précis prodigués lors de cette séance
    public ICollection<SoinEffectueDao> SoinsEffectues { get; set; } = new List<SoinEffectueDao>();
    public OrdonnanceDao? Ordonnance { get; set; }
}
