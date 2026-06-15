namespace Dentiste.Notification.Core
{
    public interface IEventCommand
    {
        string EventName { get; }
        object EventPayload { get; }
    }
}
