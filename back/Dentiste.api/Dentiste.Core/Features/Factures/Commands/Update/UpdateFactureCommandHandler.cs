using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Factures.Commands.Update;

public class UpdateFactureCommandHandler : ICommandHandler<UpdateFactureCommand>
{
    private readonly DentisteContext _context;

    public UpdateFactureCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result> Handle(UpdateFactureCommand request, CancellationToken cancellationToken)
    {
        var facture = await _context.Factures.FirstOrDefaultAsync(f => f.Id == request.Id, cancellationToken);
        if (facture == null)
        {
            return Result.Failure(Errors.FactureNotFound);
        }

        var patientExists = await _context.Patients.AnyAsync(p => p.Id == request.PatientId, cancellationToken);
        if (!patientExists)
        {
            return Result.Failure(Errors.PatientNotFound);
        }

        if (facture.NumeroFacture != request.NumeroFacture)
        {
            var numExists = await _context.Factures.AnyAsync(f => f.NumeroFacture == request.NumeroFacture && f.Id != request.Id, cancellationToken);
            if (numExists)
            {
                return Result.Failure(Errors.NumeroFactureAlreadyExists);
            }
        }

        facture.NumeroFacture = request.NumeroFacture;
        facture.DateEmission = request.DateEmission;
        facture.MontantTotal = request.MontantTotal;
        facture.MontantPaye = request.MontantPaye;
        facture.StatutPaiement = request.StatutPaiement;
        facture.PatientId = request.PatientId;

        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success();
    }
}
