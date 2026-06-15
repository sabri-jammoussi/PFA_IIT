using System;
using System.Threading.Tasks;
using Hangfire;
using MediatR;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace Dentiste.Notification.Core
{
    public class CommandEventNotify
    {
        private readonly ILogger<CommandEventNotify> _logger;
        private readonly ISender _sender;
        private readonly IServiceProvider _serviceProvider;

        public CommandEventNotify(
            ILogger<CommandEventNotify> logger,
            ISender sender,
            IServiceProvider serviceProvider)
        {
            _logger = logger;
            _sender = sender;
            _serviceProvider = serviceProvider;
        }

        [AutomaticRetry(Attempts = 2)]
        [Queue("010_notif")]
        public async Task Notify(string name, dynamic payload)
        {
            _logger.LogInformation("Processing notification event: {Name}", name);

            var mapper = _serviceProvider.GetKeyedService<IEventCommandMapper>(name);
            if (mapper == null)
            {
                _logger.LogWarning("Event command mapper not found for event: {Name}", name);
                return;
            }

            IBaseRequest? command = mapper.Convert(payload);
            if (command == null)
            {
                _logger.LogWarning("Cannot convert payload to command for event: {Name}", name);
                return;
            }

            await _sender.Send(command);
        }
    }
}
