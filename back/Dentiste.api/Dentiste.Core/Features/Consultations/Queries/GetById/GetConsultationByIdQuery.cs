using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Consultations.Queries.GetById;

public record GetConsultationByIdQuery : IQuery<ConsultationDto>
{
    public required int Id { get; init; }
}
