using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Articles.Commands.Delete;

public class DeleteArticleCommandHandler : ICommandHandler<DeleteArticleCommand>
{
    private readonly DentisteContext _context;

    public DeleteArticleCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result> Handle(DeleteArticleCommand request, CancellationToken cancellationToken)
    {
        var article = await _context.Articles
            .FirstOrDefaultAsync(a => a.Id == request.Id, cancellationToken);

        if (article == null)
        {
            return Result.Failure(Errors.ArticleNotFound);
        }

        _context.Articles.Remove(article);
        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success();
    }
}
