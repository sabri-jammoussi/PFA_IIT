using Dentiste.Core.Messaging;
using Dentiste.Core.Features.Shared;

namespace Dentiste.Core.Features.SoinsEffectues.Queries.GetAll;

public record GetAllSoinsEffectuesQuery : IQuery<PagedResult<SoinEffectueDto>>
{
    public int Page { get; init; } = 1;
    public int PageSize { get; init; } = 10;
    public int? ConsultationId { get; init; }
    public int? ActeMedicalId { get; init; }
}
