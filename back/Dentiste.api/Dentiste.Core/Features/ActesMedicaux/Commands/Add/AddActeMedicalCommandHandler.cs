using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;
using Dentiste.Data.Models;

namespace Dentiste.Core.Features.ActesMedicaux.Commands.Add;

public class AddActeMedicalCommandHandler : ICommandHandler<AddActeMedicalCommand, int>
{
    private readonly DentisteContext _context;

    public AddActeMedicalCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<int>> Handle(AddActeMedicalCommand request, CancellationToken cancellationToken)
    {
        var exists = await _context.ActesMedicaux
            .AnyAsync(a => a.Libelle == request.Libelle, cancellationToken);

        if (exists)
        {
            return Result.Failure<int>(Errors.LibelleAlreadyExists);
        }

        var acte = new ActeMedicalDao
        {
            Libelle = request.Libelle,
            TarifDeBase = request.TarifDeBase,
            CodeNomenclature = request.CodeNomenclature
        };

        _context.ActesMedicaux.Add(acte);
        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success(acte.Id);
    }
}
