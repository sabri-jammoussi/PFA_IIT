using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Articles.Commands.Update;

public class UpdateArticleCommandHandler : ICommandHandler<UpdateArticleCommand>
{
    private readonly DentisteContext _context;

    public UpdateArticleCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result> Handle(UpdateArticleCommand request, CancellationToken cancellationToken)
    {
        var article = await _context.Articles
            .FirstOrDefaultAsync(a => a.Id == request.Id, cancellationToken);

        if (article == null)
        {
            return Result.Failure(Errors.ArticleNotFound);
        }

        // Check for duplicate name (excluding self)
        var duplicate = await _context.Articles
            .AnyAsync(a => a.Nom == request.Nom && a.Id != request.Id, cancellationToken);

        if (duplicate)
        {
            return Result.Failure(Errors.NomAlreadyExists);
        }

        article.Nom = request.Nom;
        article.Description = request.Description;
        article.SeuilAlerte = request.SeuilAlerte;
        article.Unite = request.Unite;

        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success();
    }
}
