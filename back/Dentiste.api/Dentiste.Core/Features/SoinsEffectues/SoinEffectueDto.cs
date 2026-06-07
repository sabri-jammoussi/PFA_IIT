using System;

namespace Dentiste.Core.Features.SoinsEffectues;

public class SoinEffectueDto
{
    public int Id { get; set; }
    public int? NumeroDent { get; set; }
    public string? FaceDentaire { get; set; }
    public decimal PrixApplique { get; set; }
    public string? Notes { get; set; }
    public int ConsultationId { get; set; }
    public DateTime ConsultationDate { get; set; }
    public int ActeMedicalId { get; set; }
    public string? ActeMedicalLibelle { get; set; }
}
