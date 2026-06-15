using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Logging;

namespace Dentiste.Notification.Hubs
{
    public class NotificationHubClientProvider : INotificationHubClientProvider
    {
        private readonly IHubContext<NotificationHub, INotificationHubClient> _hubContext;
        private readonly ILogger<NotificationHubClientProvider> _logger;

        public NotificationHubClientProvider(
            IHubContext<NotificationHub, INotificationHubClient> hubContext,
            ILogger<NotificationHubClientProvider> logger)
        {
            _hubContext = hubContext;
            _logger = logger;
        }

        public INotificationHubClient Get(int userId)
        {
            return _hubContext.Clients.User($"{userId}");
        }

        public async Task SendToGroup<T>(string groupName, T message)
        {
            await Broadcast(new List<string> { groupName }, message);
        }

        public async Task Broadcast<T>(List<string> groupNames, T message)
        {
            try
            {
                var groupsJoined = string.Join(',', groupNames);
                _logger.LogInformation("Sending realtime notification to groups [{Groups}]", groupsJoined);

                var clients = _hubContext.Clients.Groups(groupNames);
                await clients.ReceiveMessage(message);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error while broadcasting realtime notification to groups [{Groups}]", string.Join(',', groupNames));
                throw;
            }
        }

        public async Task Broadcast<T>(List<int> userIds, T message)
        {
            try
            {
                var userStrings = userIds.Select(x => x.ToString()).ToList();
                var usersJoined = string.Join(',', userStrings);
                _logger.LogInformation("Sending realtime notification to users [{UserIds}]", usersJoined);

                var clients = _hubContext.Clients.Users(userStrings);
                await clients.ReceiveMessage(message);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error while broadcasting realtime notification to users [{UserIds}]", string.Join(',', userIds));
                throw;
            }
        }
    }
}
