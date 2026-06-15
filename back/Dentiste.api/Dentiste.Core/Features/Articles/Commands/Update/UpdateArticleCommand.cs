using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Articles.Commands.Update;

public record UpdateArticleCommand : ICommand
{
    public required int Id { get; init; }
    public required string Nom { get; init; }
    public string? Description { get; init; }
    public required int SeuilAlerte { get; init; }
    public string Unite { get; init; } = "Unité";
}
