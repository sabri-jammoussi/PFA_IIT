using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Consultations.Commands.Delete;

public class DeleteConsultationCommandHandler : ICommandHandler<DeleteConsultationCommand>
{
    private readonly DentisteContext _context;

    public DeleteConsultationCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result> Handle(DeleteConsultationCommand request, CancellationToken cancellationToken)
    {
        var consultation = await _context.Consultations.FirstOrDefaultAsync(c => c.Id == request.Id, cancellationToken);
        if (consultation == null)
        {
            return Result.Failure(Errors.ConsultationNotFound);
        }

        _context.Consultations.Remove(consultation);
        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success();
    }
}
