using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Ordonnances.Commands.Delete;

public class DeleteOrdonnanceCommandHandler : ICommandHandler<DeleteOrdonnanceCommand>
{
    private readonly DentisteContext _context;

    public DeleteOrdonnanceCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result> Handle(DeleteOrdonnanceCommand request, CancellationToken cancellationToken)
    {
        var ordonnance = await _context.Ordonnances.FirstOrDefaultAsync(o => o.Id == request.Id, cancellationToken);
        if (ordonnance == null)
        {
            return Result.Failure(Errors.OrdonnanceNotFound);
        }

        _context.Ordonnances.Remove(ordonnance);
        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success();
    }
}
