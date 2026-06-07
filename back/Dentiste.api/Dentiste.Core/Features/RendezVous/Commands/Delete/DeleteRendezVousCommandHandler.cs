using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.RendezVous.Commands.Delete;

public class DeleteRendezVousCommandHandler : ICommandHandler<DeleteRendezVousCommand>
{
    private readonly DentisteContext _context;

    public DeleteRendezVousCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result> Handle(DeleteRendezVousCommand request, CancellationToken cancellationToken)
    {
        var rdv = await _context.RendezVous.FirstOrDefaultAsync(r => r.Id == request.Id, cancellationToken);
        if (rdv == null)
        {
            return Result.Failure(Errors.RendezVousNotFound);
        }

        _context.RendezVous.Remove(rdv);
        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success();
    }
}
