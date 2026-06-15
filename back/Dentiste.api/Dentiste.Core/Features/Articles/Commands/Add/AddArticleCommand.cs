using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Articles.Commands.Add;

public record AddArticleCommand : ICommand<int>
{
    public required string Nom { get; init; }
    public string? Description { get; init; }
    public required int QuantiteEnStock { get; init; }
    public required int SeuilAlerte { get; init; }
    public string Unite { get; init; } = "Unité";
}
