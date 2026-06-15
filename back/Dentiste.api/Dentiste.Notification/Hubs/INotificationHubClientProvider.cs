using System.Collections.Generic;
using System.Threading.Tasks;

namespace Dentiste.Notification.Hubs
{
    public interface INotificationHubClientProvider
    {
        INotificationHubClient Get(int userId);
        Task SendToGroup<T>(string groupName, T message);
        Task Broadcast<T>(List<string> groupNames, T message);
        Task Broadcast<T>(List<int> userIds, T message);
    }
}
