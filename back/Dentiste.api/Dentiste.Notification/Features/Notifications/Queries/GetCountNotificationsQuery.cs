using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using MediatR;
using Dentiste.Core.Shared;
using Dentiste.Core.Infrastructure.Security;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Notification.Features.Notifications.Queries
{
    public record GetCountNotificationsQuery : IRequest<Result<int>> { }

    public class GetCountNotificationsQueryHandler : IRequestHandler<GetCountNotificationsQuery, Result<int>>
    {
        private readonly DentisteContext _dbContext;
        private readonly ICurrentUserProvider _currentUserProvider;

        public GetCountNotificationsQueryHandler(DentisteContext dbContext, ICurrentUserProvider currentUserProvider)
        {
            _dbContext = dbContext;
            _currentUserProvider = currentUserProvider;
        }

        public async Task<Result<int>> Handle(GetCountNotificationsQuery request, CancellationToken cancellationToken)
        {
            var userId = _currentUserProvider.GetUserId();
            if (userId == null)
                return Result.Failure<int>("Utilisateur non connecté.");

            var count = await _dbContext.Notifications
                .AsNoTracking()
                .CountAsync(x => x.CreatedTo == userId.Value && !x.IsSeen, cancellationToken);

            return Result.Success(count);
        }
    }
}
