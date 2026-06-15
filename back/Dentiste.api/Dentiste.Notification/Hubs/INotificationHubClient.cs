using System.Threading.Tasks;

namespace Dentiste.Notification.Hubs
{
    public interface INotificationHubClient
    {
        Task ReceiveMessage<T>(T data);
    }
}
