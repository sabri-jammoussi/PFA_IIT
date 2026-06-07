using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.ActesMedicaux.Commands.Delete;

public class DeleteActeMedicalCommandHandler : ICommandHandler<DeleteActeMedicalCommand>
{
    private readonly DentisteContext _context;

    public DeleteActeMedicalCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result> Handle(DeleteActeMedicalCommand request, CancellationToken cancellationToken)
    {
        var acte = await _context.ActesMedicaux
            .FirstOrDefaultAsync(a => a.Id == request.Id, cancellationToken);

        if (acte == null)
        {
            return Result.Failure(Errors.ActeMedicalNotFound);
        }

        _context.ActesMedicaux.Remove(acte);
        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success();
    }
}
