using System;

namespace Dentiste.Core.Features.Paiements;

public class PaiementDto
{
    public int Id { get; set; }
    public DateTime DatePaiement { get; set; }
    public decimal Montant { get; set; }
    public string ModePaiement { get; set; } = string.Empty;
    public int FactureId { get; set; }
    public string? FactureNumero { get; set; }
}
