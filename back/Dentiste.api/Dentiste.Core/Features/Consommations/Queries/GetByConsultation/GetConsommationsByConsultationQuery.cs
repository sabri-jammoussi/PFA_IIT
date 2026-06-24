using System.Collections.Generic;
using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Consommations.Queries.GetByConsultation;

public record GetConsommationsByConsultationQuery : IQuery<List<ConsommationArticleDto>>
{
    public required int ConsultationId { get; init; }
}
