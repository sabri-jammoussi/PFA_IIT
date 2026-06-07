using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.SoinsEffectues.Commands.Update;

public record UpdateSoinEffectueCommand : ICommand
{
    public required int Id { get; init; }
    public int? NumeroDent { get; init; }
    public string? FaceDentaire { get; init; }
    public required decimal PrixApplique { get; init; }
    public string? Notes { get; init; }
    public required int ConsultationId { get; init; }
    public required int ActeMedicalId { get; init; }
}
