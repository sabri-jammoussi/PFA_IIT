using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Patients.Queries.GetById;

public record GetPatientByIdQuery : IQuery<PatientDto>
{
    public required int Id { get; init; }
}
