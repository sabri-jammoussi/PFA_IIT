using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Articles.Commands.Restock;

public record RestockArticleCommand : ICommand
{
    public required int Id { get; init; }
    public required int QuantiteAjoutee { get; init; } // Amount to add to current stock
}
