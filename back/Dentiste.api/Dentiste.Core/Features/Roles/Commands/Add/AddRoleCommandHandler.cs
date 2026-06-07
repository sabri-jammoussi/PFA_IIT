using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;
using Dentiste.Data.Models;

namespace Dentiste.Core.Features.Roles.Commands.Add;

public class AddRoleCommandHandler : ICommandHandler<AddRoleCommand, int>
{
    private readonly DentisteContext _context;

    public AddRoleCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<int>> Handle(AddRoleCommand request, CancellationToken cancellationToken)
    {
        var exists = await _context.Roles.AnyAsync(r => r.Name == request.Name, cancellationToken);
        if (exists)
        {
            return Result.Failure<int>(Errors.NameAlreadyExists);
        }

        var role = new RoleDao
        {
            Name = request.Name,
            Description = request.Description
        };

        _context.Roles.Add(role);
        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success(role.Id);
    }
}
