using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.SoinsEffectues.Queries.GetById;

public record GetSoinEffectueByIdQuery : IQuery<SoinEffectueDto>
{
    public required int Id { get; init; }
}
