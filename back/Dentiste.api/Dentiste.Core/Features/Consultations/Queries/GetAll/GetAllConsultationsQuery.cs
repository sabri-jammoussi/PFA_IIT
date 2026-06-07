using System;
using Dentiste.Core.Messaging;
using Dentiste.Core.Features.Shared;

namespace Dentiste.Core.Features.Consultations.Queries.GetAll;

public record GetAllConsultationsQuery : IQuery<PagedResult<ConsultationDto>>
{
    public int Page { get; init; } = 1;
    public int PageSize { get; init; } = 10;
    public int? PatientId { get; init; }
    public int? DentisteId { get; init; }
    public DateTime? StartDate { get; init; }
    public DateTime? EndDate { get; init; }
}
