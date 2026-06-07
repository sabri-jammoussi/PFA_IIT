using System.Threading;
using System.Threading.Tasks;
using Dentiste.Core.Infrastructure.Security;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;

namespace Dentiste.Core.Features.Auth.Commands.Logout;

public class LogoutCommandHandler : ICommandHandler<LogoutCommand>
{
    private readonly ISessionService _sessionService;

    public LogoutCommandHandler(ISessionService sessionService)
    {
        _sessionService = sessionService;
    }

    public async Task<Result> Handle(LogoutCommand request, CancellationToken cancellationToken)
    {
        await _sessionService.RevokeSessionAsync(request.Jti);
        return Result.Success();
    }
}
