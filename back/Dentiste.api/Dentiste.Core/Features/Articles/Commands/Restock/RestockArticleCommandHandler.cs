using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Articles.Commands.Restock;

public class RestockArticleCommandHandler : ICommandHandler<RestockArticleCommand>
{
    private readonly DentisteContext _context;

    public RestockArticleCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result> Handle(RestockArticleCommand request, CancellationToken cancellationToken)
    {
        if (request.QuantiteAjoutee <= 0)
        {
            return Result.Failure(Errors.InvalidQuantity);
        }

        var article = await _context.Articles
            .FirstOrDefaultAsync(a => a.Id == request.Id, cancellationToken);

        if (article == null)
        {
            return Result.Failure(Errors.ArticleNotFound);
        }

        article.QuantiteEnStock += request.QuantiteAjoutee;
        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success();
    }
}
