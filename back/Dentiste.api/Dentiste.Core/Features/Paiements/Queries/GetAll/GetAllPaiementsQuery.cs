using Dentiste.Core.Messaging;
using Dentiste.Core.Features.Shared;

namespace Dentiste.Core.Features.Paiements.Queries.GetAll;

public record GetAllPaiementsQuery : IQuery<PagedResult<PaiementDto>>
{
    public int Page { get; init; } = 1;
    public int PageSize { get; init; } = 10;
    public int? FactureId { get; init; }
    public string? ModePaiement { get; init; }
}
