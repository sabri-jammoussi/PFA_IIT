using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using MediatR;
using Dentiste.Core.Shared;
using Dentiste.Core.Infrastructure.Security;
using Dentiste.Data.Infrastructure.EF;
using Dentiste.Data.Enums;

namespace Dentiste.Notification.Features.Notifications.Queries
{
    public class NotificationDto
    {
        public int Id { get; set; }
        public NotificationNature Nature { get; set; }
        public int EntityId { get; set; }
        public string EntityCode { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public NotificationDomaine Domaine { get; set; }
        public int CreatedBy { get; set; }
        public int CreatedTo { get; set; }
        public DateTime DateRappel { get; set; }
        public bool IsSeen { get; set; }
        public int DemandeId { get; set; }
        public NotificationType Type { get; set; }
    }

    public record GetNotificationsQuery : IRequest<Result<IList<NotificationDto>>> { }

    public class GetNotificationsQueryHandler : IRequestHandler<GetNotificationsQuery, Result<IList<NotificationDto>>>
    {
        private readonly DentisteContext _dbContext;
        private readonly ICurrentUserProvider _currentUserProvider;

        public GetNotificationsQueryHandler(DentisteContext dbContext, ICurrentUserProvider currentUserProvider)
        {
            _dbContext = dbContext;
            _currentUserProvider = currentUserProvider;
        }

        public async Task<Result<IList<NotificationDto>>> Handle(GetNotificationsQuery request, CancellationToken cancellationToken)
        {
            var userId = _currentUserProvider.GetUserId();
            if (userId == null)
                return Result.Failure<IList<NotificationDto>>("Utilisateur non connecté.");

            var date = DateTime.UtcNow;

            var result = await _dbContext.Notifications
                .Where(x => x.CreatedTo == userId.Value && x.DateRappel <= date)
                .AsNoTracking()
                .OrderByDescending(x => x.DateRappel)
                .Select(x => new NotificationDto
                {
                    Id = x.Id,
                    Nature = x.Nature,
                    EntityId = x.EntityId,
                    EntityCode = x.EntityCode,
                    Title = x.Title,
                    Description = x.Description,
                    Domaine = x.Domaine,
                    CreatedBy = x.CreatedBy,
                    CreatedTo = x.CreatedTo,
                    DateRappel = x.DateRappel,
                    IsSeen = x.IsSeen,
                    DemandeId = x.DemandeId,
                    Type = x.Type
                })
                .Take(20)
                .ToListAsync(cancellationToken);

            return Result.Success<IList<NotificationDto>>(result);
        }
    }
}
