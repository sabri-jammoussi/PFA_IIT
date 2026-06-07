using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.ActesMedicaux.Commands.Update;

public class UpdateActeMedicalCommandHandler : ICommandHandler<UpdateActeMedicalCommand>
{
    private readonly DentisteContext _context;

    public UpdateActeMedicalCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result> Handle(UpdateActeMedicalCommand request, CancellationToken cancellationToken)
    {
        var acte = await _context.ActesMedicaux
            .FirstOrDefaultAsync(a => a.Id == request.Id, cancellationToken);

        if (acte == null)
        {
            return Result.Failure(Errors.ActeMedicalNotFound);
        }

        if (acte.Libelle != request.Libelle)
        {
            var exists = await _context.ActesMedicaux
                .AnyAsync(a => a.Libelle == request.Libelle && a.Id != request.Id, cancellationToken);

            if (exists)
            {
                return Result.Failure(Errors.LibelleAlreadyExists);
            }
        }

        acte.Libelle = request.Libelle;
        acte.TarifDeBase = request.TarifDeBase;
        acte.CodeNomenclature = request.CodeNomenclature;

        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success();
    }
}
