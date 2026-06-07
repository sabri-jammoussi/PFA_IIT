namespace Dentiste.Core.Features.ActesMedicaux;

public class ActeMedicalDto
{
    public int Id { get; set; }
    public string Libelle { get; set; } = string.Empty;
    public decimal TarifDeBase { get; set; }
    public string? CodeNomenclature { get; set; }
}
