using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;
using Dentiste.Data.Models;

namespace Dentiste.Core.Features.RecettesActes.Commands.Add;

public class AddRecetteActeCommandHandler : ICommandHandler<AddRecetteActeCommand, int>
{
    private readonly DentisteContext _context;

    public AddRecetteActeCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<int>> Handle(AddRecetteActeCommand request, CancellationToken cancellationToken)
    {
        var acteExists = await _context.ActesMedicaux.AnyAsync(a => a.Id == request.ActeMedicalId, cancellationToken);
        if (!acteExists)
        {
            return Result.Failure<int>(Errors.ActeMedicalNotFound);
        }

        var articleExists = await _context.Articles.AnyAsync(a => a.Id == request.ArticleId, cancellationToken);
        if (!articleExists)
        {
            return Result.Failure<int>(Errors.ArticleNotFound);
        }

        // Prevent duplicate act-article combinations
        var duplicate = await _context.RecettesActes
            .AnyAsync(r => r.ActeMedicalId == request.ActeMedicalId && r.ArticleId == request.ArticleId, cancellationToken);
        if (duplicate)
        {
            return Result.Failure<int>(Errors.RecetteAlreadyExists);
        }

        var recette = new RecetteActeDao
        {
            ActeMedicalId = request.ActeMedicalId,
            ArticleId = request.ArticleId,
            QuantiteRequise = request.QuantiteRequise
        };

        _context.RecettesActes.Add(recette);
        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success(recette.Id);
    }
}
