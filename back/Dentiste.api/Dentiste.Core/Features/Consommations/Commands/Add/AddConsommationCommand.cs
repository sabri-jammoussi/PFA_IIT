using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Consommations.Commands.Add;

public record AddConsommationCommand : ICommand<int>
{
    public required int ConsultationId { get; init; }
    public required int ArticleId { get; init; }
    public required int Quantite { get; init; }
}
