using System.Threading;
using System.Threading.Tasks;
using Hangfire;
using MediatR;
using Microsoft.Extensions.DependencyInjection;
using Dentiste.Core.Shared;

namespace Dentiste.Notification.Core
{
    public class CommandEventBehavior<TRequest, TResponse> : IPipelineBehavior<TRequest, TResponse>
        where TRequest : IEventCommand
        where TResponse : Result
    {
        private readonly IBackgroundJobClient _backgroundJobClient;

        public CommandEventBehavior([FromKeyedServices("notif")] IBackgroundJobClient backgroundJobClient)
        {
            _backgroundJobClient = backgroundJobClient;
        }

        public async Task<TResponse> Handle(TRequest request, RequestHandlerDelegate<TResponse> next, CancellationToken cancellationToken)
        {
            TResponse result = await next(cancellationToken);

            if (result.IsSuccess)
            {
                _backgroundJobClient.Enqueue<CommandEventNotify>(x => x.Notify(request.EventName, request.EventPayload));
            }

            return result;
        }
    }
}
