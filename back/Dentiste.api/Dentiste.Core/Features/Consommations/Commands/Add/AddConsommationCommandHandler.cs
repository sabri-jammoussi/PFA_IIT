using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;
using Dentiste.Data.Models;

namespace Dentiste.Core.Features.Consommations.Commands.Add;

public class AddConsommationCommandHandler : ICommandHandler<AddConsommationCommand, int>
{
    private readonly DentisteContext _context;

    public AddConsommationCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<int>> Handle(AddConsommationCommand request, CancellationToken cancellationToken)
    {
        if (request.Quantite <= 0)
        {
            return Result.Failure<int>(Errors.InvalidQuantity);
        }

        var consultationExists = await _context.Consultations
            .AnyAsync(c => c.Id == request.ConsultationId, cancellationToken);
        if (!consultationExists)
        {
            return Result.Failure<int>(Errors.ConsultationNotFound);
        }

        var article = await _context.Articles
            .FirstOrDefaultAsync(a => a.Id == request.ArticleId, cancellationToken);
        if (article == null)
        {
            return Result.Failure<int>(Errors.ArticleNotFound);
        }

        var consommation = new ConsommationArticleDao
        {
            ConsultationId = request.ConsultationId,
            ArticleId = request.ArticleId,
            Quantite = request.Quantite
        };
        _context.ConsommationsArticles.Add(consommation);

        // Decrement stock. Allowed to go negative so the dentist is never blocked
        // mid-procedure; the low-stock alert flags it for the secretary to reorder.
        article.QuantiteEnStock -= request.Quantite;

        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success(consommation.Id);
    }
}
