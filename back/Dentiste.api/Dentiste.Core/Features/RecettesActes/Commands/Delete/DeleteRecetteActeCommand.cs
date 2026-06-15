using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.RecettesActes.Commands.Delete;

public record DeleteRecetteActeCommand : ICommand
{
    public required int Id { get; init; }
}
