using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Patients.Commands.Delete;

public class DeletePatientCommandHandler : ICommandHandler<DeletePatientCommand>
{
    private readonly DentisteContext _context;

    public DeletePatientCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result> Handle(DeletePatientCommand request, CancellationToken cancellationToken)
    {
        var patient = await _context.Patients
            .FirstOrDefaultAsync(p => p.Id == request.Id, cancellationToken);

        if (patient == null)
        {
            return Result.Failure(Errors.PatientNotFound);
        }

        _context.Patients.Remove(patient);
        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success();
    }
}
