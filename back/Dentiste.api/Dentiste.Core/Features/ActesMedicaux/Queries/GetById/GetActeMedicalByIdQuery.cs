using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.ActesMedicaux.Queries.GetById;

public record GetActeMedicalByIdQuery : IQuery<ActeMedicalDto>
{
    public required int Id { get; init; }
}
