using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;
using Dentiste.Data.Models;

namespace Dentiste.Core.Features.Articles.Commands.Add;

public class AddArticleCommandHandler : ICommandHandler<AddArticleCommand, int>
{
    private readonly DentisteContext _context;

    public AddArticleCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<int>> Handle(AddArticleCommand request, CancellationToken cancellationToken)
    {
        var exists = await _context.Articles
            .AnyAsync(a => a.Nom == request.Nom, cancellationToken);

        if (exists)
        {
            return Result.Failure<int>(Errors.NomAlreadyExists);
        }

        var article = new ArticleDao
        {
            Nom = request.Nom,
            Description = request.Description,
            QuantiteEnStock = request.QuantiteEnStock,
            SeuilAlerte = request.SeuilAlerte,
            Unite = request.Unite
        };

        _context.Articles.Add(article);
        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success(article.Id);
    }
}
