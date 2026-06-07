using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Patients.Commands.Delete;

public record DeletePatientCommand : ICommand
{
    public required int Id { get; init; }
}
