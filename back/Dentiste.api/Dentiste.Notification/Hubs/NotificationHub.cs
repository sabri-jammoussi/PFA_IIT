using System;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Notification.Hubs
{
    [Authorize]
    public class NotificationHub : Hub<INotificationHubClient>
    {
        private const string GROUP_ADMIN = "Admin";
        private const string GROUP_SECRETAIRE = "Secretaire";
        private const string GROUP_DENTISTE = "Dentiste";
        private const string GROUP_OTHERS = "Others";

        public static readonly string GroupAdmin = GROUP_ADMIN;
        public static readonly string GroupSecretaire = GROUP_SECRETAIRE;
        public static readonly string GroupDentiste = GROUP_DENTISTE;

        private readonly DentisteContext _dbContext;

        public NotificationHub(DentisteContext dbContext)
        {
            _dbContext = dbContext;
        }

        public override async Task OnConnectedAsync()
        {
            try
            {
                var userIdentifier = Context.UserIdentifier;
                if (!string.IsNullOrEmpty(userIdentifier))
                {
                    var groupName = await GetGroupName(userIdentifier);
                    if (groupName != null)
                    {
                        await Groups.AddToGroupAsync(Context.ConnectionId, groupName);
                    }
                }
                await base.OnConnectedAsync();
            }
            catch
            {
                // Silence or log connection error
            }
        }

        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            try
            {
                var userIdentifier = Context.UserIdentifier;
                if (!string.IsNullOrEmpty(userIdentifier))
                {
                    var groupName = await GetGroupName(userIdentifier);
                    if (groupName != null)
                    {
                        await Groups.RemoveFromGroupAsync(Context.ConnectionId, groupName);
                    }
                }
                await base.OnDisconnectedAsync(exception);
            }
            catch
            {
                // Silence or log disconnection error
            }
        }

        private async Task<string?> GetGroupName(string userIdentifier)
        {
            if (!int.TryParse(userIdentifier, out var userId))
            {
                return null;
            }

            var user = await _dbContext.Users
                .IgnoreQueryFilters()
                .Include(u => u.Role)
                .AsNoTracking()
                .SingleOrDefaultAsync(x => x.Id == userId);

            if (user == null)
            {
                return null;
            }

            var roleName = user.Role?.Name ?? "";
            
            if (roleName.Equals("Administrateur", StringComparison.OrdinalIgnoreCase) || roleName.Equals("Admin", StringComparison.OrdinalIgnoreCase))
            {
                return GROUP_ADMIN;
            }
            if (roleName.Equals("Assistant", StringComparison.OrdinalIgnoreCase) || roleName.Equals("Secretaire", StringComparison.OrdinalIgnoreCase))
            {
                return GROUP_SECRETAIRE;
            }
            if (roleName.Equals("Dentiste", StringComparison.OrdinalIgnoreCase))
            {
                return GROUP_DENTISTE;
            }

            return GROUP_OTHERS;
        }
    }
}
