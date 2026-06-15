using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.RecettesActes.Commands.Delete;

public class DeleteRecetteActeCommandHandler : ICommandHandler<DeleteRecetteActeCommand>
{
    private readonly DentisteContext _context;

    public DeleteRecetteActeCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result> Handle(DeleteRecetteActeCommand request, CancellationToken cancellationToken)
    {
        var recette = await _context.RecettesActes
            .FirstOrDefaultAsync(r => r.Id == request.Id, cancellationToken);

        if (recette == null)
        {
            return Result.Failure(Errors.RecetteActeNotFound);
        }

        _context.RecettesActes.Remove(recette);
        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success();
    }
}
