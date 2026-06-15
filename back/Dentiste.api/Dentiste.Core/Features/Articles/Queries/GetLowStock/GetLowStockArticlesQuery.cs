using System.Collections.Generic;
using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Articles.Queries.GetLowStock;

public record GetLowStockArticlesQuery : IQuery<List<ArticleDto>>
{
}
