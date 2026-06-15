using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Articles.Queries.GetById;

public record GetArticleByIdQuery : IQuery<ArticleDto>
{
    public required int Id { get; init; }
}
