using System;

namespace Dentiste.Core.Features.Factures;

public class FactureDto
{
    public int Id { get; set; }
    public string NumeroFacture { get; set; } = string.Empty;
    public DateTime DateEmission { get; set; }
    public decimal MontantTotal { get; set; }
    public decimal MontantPaye { get; set; }
    public string StatutPaiement { get; set; } = string.Empty;
    public int PatientId { get; set; }
    public string? PatientNomComplet { get; set; }
}
