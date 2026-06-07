using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.ActesMedicaux.Commands.Delete;

public record DeleteActeMedicalCommand : ICommand
{
    public required int Id { get; init; }
}
