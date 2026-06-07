using Dentiste.Core.Messaging;
using Dentiste.Core.Features.Shared;

namespace Dentiste.Core.Features.ActesMedicaux.Queries.GetAll;

public record GetAllActesMedicauxQuery : IQuery<PagedResult<ActeMedicalDto>>
{
    public int Page { get; init; } = 1;
    public int PageSize { get; init; } = 10;
    public string? SearchTerm { get; init; }
}
