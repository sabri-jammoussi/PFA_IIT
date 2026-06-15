using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using MediatR;
using Dentiste.Core.Shared;
using Dentiste.Core.Infrastructure.Security;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Notification.Features.Notifications.Commands.MarkAsSeenById
{
    public class MarkAsSeenByIdCommandHandler : IRequestHandler<MarkAsSeenByIdCommand, Result>
    {
        private readonly DentisteContext _dbContext;
        private readonly ICurrentUserProvider _currentUserProvider;

        public MarkAsSeenByIdCommandHandler(DentisteContext dbContext, ICurrentUserProvider currentUserProvider)
        {
            _dbContext = dbContext;
            _currentUserProvider = currentUserProvider;
        }

        public async Task<Result> Handle(MarkAsSeenByIdCommand request, CancellationToken cancellationToken)
        {
            var userId = _currentUserProvider.GetUserId();
            if (userId == null)
                return Result.Failure("Utilisateur non connecté.");

            var notification = await _dbContext.Notifications.SingleOrDefaultAsync(x => x.Id == request.Id, cancellationToken);
            if (notification == null)
                return Result.Failure("Notification non trouvée.");

            if (notification.CreatedTo != userId.Value)
                return Result.Failure("Non autorisé.");

            if (notification.IsSeen)
                return Result.Success();

            notification.IsSeen = true;
            await _dbContext.SaveChangesAsync(cancellationToken);

            return Result.Success();
        }
    }
}
