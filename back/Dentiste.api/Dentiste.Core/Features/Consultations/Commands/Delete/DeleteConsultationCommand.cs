using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Consultations.Commands.Delete;

public record DeleteConsultationCommand : ICommand
{
    public required int Id { get; init; }
}
