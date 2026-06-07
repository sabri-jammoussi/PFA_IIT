using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.RendezVous.Queries.GetById;

public record GetRendezVousByIdQuery : IQuery<RendezVousDto>
{
    public required int Id { get; init; }
}
