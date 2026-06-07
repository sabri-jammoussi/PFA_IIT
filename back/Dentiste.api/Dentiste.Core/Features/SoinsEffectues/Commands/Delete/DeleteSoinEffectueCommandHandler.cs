using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.SoinsEffectues.Commands.Delete;

public class DeleteSoinEffectueCommandHandler : ICommandHandler<DeleteSoinEffectueCommand>
{
    private readonly DentisteContext _context;

    public DeleteSoinEffectueCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result> Handle(DeleteSoinEffectueCommand request, CancellationToken cancellationToken)
    {
        var soin = await _context.SoinsEffectues.FirstOrDefaultAsync(s => s.Id == request.Id, cancellationToken);
        if (soin == null)
        {
            return Result.Failure(Errors.SoinEffectueNotFound);
        }

        _context.SoinsEffectues.Remove(soin);
        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success();
    }
}
