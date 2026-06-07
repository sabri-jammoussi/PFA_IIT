using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.SoinsEffectues.Commands.Add;

public record AddSoinEffectueCommand : ICommand<int>
{
    public int? NumeroDent { get; init; }
    public string? FaceDentaire { get; init; }
    public required decimal PrixApplique { get; init; }
    public string? Notes { get; init; }
    public required int ConsultationId { get; init; }
    public required int ActeMedicalId { get; init; }
}
