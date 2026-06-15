using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Articles.Commands.Delete;

public record DeleteArticleCommand : ICommand
{
    public required int Id { get; init; }
}
