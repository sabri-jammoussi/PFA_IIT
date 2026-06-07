using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.SoinsEffectues.Commands.Delete;

public record DeleteSoinEffectueCommand : ICommand
{
    public required int Id { get; init; }
}
