using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Paiements.Queries.GetById;

public record GetPaiementByIdQuery : IQuery<PaiementDto>
{
    public required int Id { get; init; }
}
