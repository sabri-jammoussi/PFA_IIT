using Dentiste.Core.Messaging;
using Dentiste.Core.Features.Shared;

namespace Dentiste.Core.Features.Factures.Queries.GetAll;

public record GetAllFacturesQuery : IQuery<PagedResult<FactureDto>>
{
    public int Page { get; init; } = 1;
    public int PageSize { get; init; } = 10;
    public int? PatientId { get; init; }
    public string? StatutPaiement { get; init; }
    public string? SearchTerm { get; init; }
}
