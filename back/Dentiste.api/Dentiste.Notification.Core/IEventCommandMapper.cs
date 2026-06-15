using MediatR;

namespace Dentiste.Notification.Core
{
    public interface IEventCommandMapper
    {
        IBaseRequest? Convert(dynamic eventPayload);
    }
}
