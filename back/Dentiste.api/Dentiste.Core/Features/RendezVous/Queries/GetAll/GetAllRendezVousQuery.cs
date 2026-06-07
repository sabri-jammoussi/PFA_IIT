using System;
using Dentiste.Core.Messaging;
using Dentiste.Core.Features.Shared;

namespace Dentiste.Core.Features.RendezVous.Queries.GetAll;

public record GetAllRendezVousQuery : IQuery<PagedResult<RendezVousDto>>
{
    public int Page { get; init; } = 1;
    public int PageSize { get; init; } = 10;
    public DateTime? StartDate { get; init; }
    public DateTime? EndDate { get; init; }
    public int? PatientId { get; init; }
    public int? DentisteId { get; init; }
    public string? Statut { get; init; }
}
