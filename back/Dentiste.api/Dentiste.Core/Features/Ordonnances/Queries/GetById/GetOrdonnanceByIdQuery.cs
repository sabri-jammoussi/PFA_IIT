using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Ordonnances.Queries.GetById;

public record GetOrdonnanceByIdQuery : IQuery<OrdonnanceDto>
{
    public required int Id { get; init; }
}
