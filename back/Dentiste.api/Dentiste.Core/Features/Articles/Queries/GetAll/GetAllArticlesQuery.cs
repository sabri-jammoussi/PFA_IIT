using Dentiste.Core.Messaging;
using Dentiste.Core.Features.Shared;

namespace Dentiste.Core.Features.Articles.Queries.GetAll;

public record GetAllArticlesQuery : IQuery<PagedResult<ArticleDto>>
{
    public int Page { get; init; } = 1;
    public int PageSize { get; init; } = 50;
    public string? SearchTerm { get; init; }
    public bool? LowStockOnly { get; init; }
}
