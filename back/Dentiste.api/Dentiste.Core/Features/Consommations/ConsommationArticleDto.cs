using System;

namespace Dentiste.Core.Features.Consommations;

public class ConsommationArticleDto
{
    public int Id { get; set; }
    public int Quantite { get; set; }
    public DateTime DateConsommation { get; set; }
    public int ConsultationId { get; set; }
    public int ArticleId { get; set; }
    public string? ArticleNom { get; set; }
    public string? ArticleUnite { get; set; }
}
