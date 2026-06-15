using System.Collections.Generic;
using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.RecettesActes.Queries.GetByActe;

public record GetRecettesByActeQuery : IQuery<List<RecetteActeDto>>
{
    public required int ActeMedicalId { get; init; }
}
