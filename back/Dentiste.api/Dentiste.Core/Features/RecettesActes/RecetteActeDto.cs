namespace Dentiste.Core.Features.RecettesActes;

public class RecetteActeDto
{
    public int Id { get; set; }
    public int QuantiteRequise { get; set; }
    public int ActeMedicalId { get; set; }
    public string ActeMedicalLibelle { get; set; } = string.Empty;
    public int ArticleId { get; set; }
    public string ArticleNom { get; set; } = string.Empty;
    public string ArticleUnite { get; set; } = string.Empty;
}
