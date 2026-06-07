using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Roles.Commands.Update;

public class UpdateRoleCommandHandler : ICommandHandler<UpdateRoleCommand>
{
    private readonly DentisteContext _context;

    public UpdateRoleCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result> Handle(UpdateRoleCommand request, CancellationToken cancellationToken)
    {
        var role = await _context.Roles.FirstOrDefaultAsync(r => r.Id == request.Id, cancellationToken);
        if (role == null)
        {
            return Result.Failure(Errors.RoleNotFound);
        }

        if (role.Name != request.Name)
        {
            var exists = await _context.Roles.AnyAsync(r => r.Name == request.Name && r.Id != request.Id, cancellationToken);
            if (exists)
            {
                return Result.Failure(Errors.NameAlreadyExists);
            }
        }

        role.Name = request.Name;
        role.Description = request.Description;

        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success();
    }
}
