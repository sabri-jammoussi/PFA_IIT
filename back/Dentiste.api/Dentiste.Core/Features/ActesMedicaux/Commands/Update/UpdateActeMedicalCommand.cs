using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.ActesMedicaux.Commands.Update;

public record UpdateActeMedicalCommand : ICommand
{
    public required int Id { get; init; }
    public required string Libelle { get; init; }
    public required decimal TarifDeBase { get; init; }
    public string? CodeNomenclature { get; init; }
}
