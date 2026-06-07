using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Factures.Queries.GetById;

public record GetFactureByIdQuery : IQuery<FactureDto>
{
    public required int Id { get; init; }
}
