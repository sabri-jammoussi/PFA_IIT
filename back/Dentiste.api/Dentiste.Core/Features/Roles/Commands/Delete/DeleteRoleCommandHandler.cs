using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Roles.Commands.Delete;

public class DeleteRoleCommandHandler : ICommandHandler<DeleteRoleCommand>
{
    private readonly DentisteContext _context;

    public DeleteRoleCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result> Handle(DeleteRoleCommand request, CancellationToken cancellationToken)
    {
        var role = await _context.Roles.FirstOrDefaultAsync(r => r.Id == request.Id, cancellationToken);
        if (role == null)
        {
            return Result.Failure(Errors.RoleNotFound);
        }

        _context.Roles.Remove(role);
        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success();
    }
}
