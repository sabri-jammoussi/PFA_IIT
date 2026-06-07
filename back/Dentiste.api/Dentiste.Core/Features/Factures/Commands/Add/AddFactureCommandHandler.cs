using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;
using Dentiste.Data.Models;

namespace Dentiste.Core.Features.Factures.Commands.Add;

public class AddFactureCommandHandler : ICommandHandler<AddFactureCommand, int>
{
    private readonly DentisteContext _context;

    public AddFactureCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<int>> Handle(AddFactureCommand request, CancellationToken cancellationToken)
    {
        var patientExists = await _context.Patients.AnyAsync(p => p.Id == request.PatientId, cancellationToken);
        if (!patientExists)
        {
            return Result.Failure<int>(Errors.PatientNotFound);
        }

        var numExists = await _context.Factures.AnyAsync(f => f.NumeroFacture == request.NumeroFacture, cancellationToken);
        if (numExists)
        {
            return Result.Failure<int>(Errors.NumeroFactureAlreadyExists);
        }

        var facture = new FactureDao
        {
            NumeroFacture = request.NumeroFacture,
            DateEmission = request.DateEmission,
            MontantTotal = request.MontantTotal,
            MontantPaye = request.MontantPaye,
            StatutPaiement = request.StatutPaiement,
            PatientId = request.PatientId
        };

        _context.Factures.Add(facture);
        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success(facture.Id);
    }
}
