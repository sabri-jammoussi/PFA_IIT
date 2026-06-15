using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.RecettesActes.Commands.Add;

public record AddRecetteActeCommand : ICommand<int>
{
    public required int ActeMedicalId { get; init; }
    public required int ArticleId { get; init; }
    public required int QuantiteRequise { get; init; }
}
