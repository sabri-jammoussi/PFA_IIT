using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Factures.Commands.Delete;

public class DeleteFactureCommandHandler : ICommandHandler<DeleteFactureCommand>
{
    private readonly DentisteContext _context;

    public DeleteFactureCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result> Handle(DeleteFactureCommand request, CancellationToken cancellationToken)
    {
        var facture = await _context.Factures.FirstOrDefaultAsync(f => f.Id == request.Id, cancellationToken);
        if (facture == null)
        {
            return Result.Failure(Errors.FactureNotFound);
        }

        _context.Factures.Remove(facture);
        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success();
    }
}
