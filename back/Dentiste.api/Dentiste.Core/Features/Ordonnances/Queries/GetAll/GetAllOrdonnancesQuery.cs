using Dentiste.Core.Messaging;
using Dentiste.Core.Features.Shared;

namespace Dentiste.Core.Features.Ordonnances.Queries.GetAll;

public record GetAllOrdonnancesQuery : IQuery<PagedResult<OrdonnanceDto>>
{
    public int Page { get; init; } = 1;
    public int PageSize { get; init; } = 10;
    public int? ConsultationId { get; init; }
    public string? SearchTerm { get; init; }
}
