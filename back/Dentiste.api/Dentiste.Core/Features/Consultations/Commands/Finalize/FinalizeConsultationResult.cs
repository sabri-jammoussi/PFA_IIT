namespace Dentiste.Core.Features.Consultations.Commands.Finalize;

public class FinalizeConsultationResult
{
    public int FactureId { get; set; }
    public string NumeroFacture { get; set; } = string.Empty;
    public decimal MontantTotal { get; set; }
    public int PatientId { get; set; }
    public string PatientNomComplet { get; set; } = string.Empty;
}
