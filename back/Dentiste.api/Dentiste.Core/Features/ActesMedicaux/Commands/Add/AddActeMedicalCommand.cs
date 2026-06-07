using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.ActesMedicaux.Commands.Add;

public record AddActeMedicalCommand : ICommand<int>
{
    public required string Libelle { get; init; }
    public required decimal TarifDeBase { get; init; }
    public string? CodeNomenclature { get; init; }
}
