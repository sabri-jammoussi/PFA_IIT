using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using MediatR;
using Microsoft.Extensions.Logging;
using Dentiste.Core.Shared;
using Dentiste.Core.Infrastructure.Security;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Notification.Features.Notifications.Commands.MarkAsSeen
{
    public class MarkAsSeenCommandHandler : IRequestHandler<MarkAsSeenCommand, Result>
    {
        private readonly ILogger<MarkAsSeenCommandHandler> _logger;
        private readonly DentisteContext _dbContext;
        private readonly ICurrentUserProvider _currentUserProvider;

        public MarkAsSeenCommandHandler(ILogger<MarkAsSeenCommandHandler> logger, DentisteContext dbContext, ICurrentUserProvider currentUserProvider)
        {
            _logger = logger;
            _dbContext = dbContext;
            _currentUserProvider = currentUserProvider;
        }

        public async Task<Result> Handle(MarkAsSeenCommand request, CancellationToken cancellationToken)
        {
            var userId = _currentUserProvider.GetUserId();
            if (userId == null)
                return Result.Failure("Utilisateur non connecté.");

            var count = await _dbContext.Notifications
                .Where(x => x.CreatedTo == userId.Value && !x.IsSeen && x.DateRappel <= DateTime.UtcNow)
                .ExecuteUpdateAsync(setter => setter.SetProperty(x => x.IsSeen, true), cancellationToken);

            _logger.LogTrace("mark-all-as-seen count: {Count}", count);
            return Result.Success();
        }
    }
}
