using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Users.Commands.Delete;

public class DeleteUserCommandHandler : ICommandHandler<DeleteUserCommand>
{
    private readonly DentisteContext _context;

    public DeleteUserCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result> Handle(DeleteUserCommand request, CancellationToken cancellationToken)
    {
        var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == request.Id, cancellationToken);
        if (user == null)
        {
            return Result.Failure(Errors.UserNotFound);
        }

        // Remove notifications associated with the user to prevent FK constraint errors
        var notifications = await _context.Notifications
            .IgnoreQueryFilters()
            .Where(n => n.CreatedBy == request.Id || n.CreatedTo == request.Id)
            .ToListAsync(cancellationToken);
        if (notifications.Any())
        {
            _context.Notifications.RemoveRange(notifications);
        }

        _context.Users.Remove(user);
        await _context.SaveChangesAsync(cancellationToken);

        return Result.Success();
    }
}
