using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Consommations.Commands.Delete;

public class DeleteConsommationCommandHandler : ICommandHandler<DeleteConsommationCommand>
{
    private readonly DentisteContext _context;

    public DeleteConsommationCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result> Handle(DeleteConsommationCommand request, CancellationToken cancellationToken)
    {
        var consommation = await _context.ConsommationsArticles
            .FirstOrDefaultAsync(c => c.Id == request.Id, cancellationToken);
        if (consommation == null)
        {
            return Result.Failure(Errors.ConsommationNotFound);
        }

        // Give the consumed quantity back to stock before removing the record.
        var article = await _context.Articles
            .FirstOrDefaultAsync(a => a.Id == consommation.ArticleId, cancellationToken);
        if (article != null)
        {
            article.QuantiteEnStock += consommation.Quantite;
        }

        _context.ConsommationsArticles.Remove(consommation);
        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success();
    }
}
