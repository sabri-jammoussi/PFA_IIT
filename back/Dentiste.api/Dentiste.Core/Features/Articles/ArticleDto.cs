namespace Dentiste.Core.Features.Articles;

public class ArticleDto
{
    public int Id { get; set; }
    public string Nom { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int QuantiteEnStock { get; set; }
    public int SeuilAlerte { get; set; }
    public string Unite { get; set; } = "Unité";
    public bool IsLowStock => QuantiteEnStock <= SeuilAlerte;
}
