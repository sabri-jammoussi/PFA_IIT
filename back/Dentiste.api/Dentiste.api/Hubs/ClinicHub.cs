using Dentiste.Core.Infrastructure.Security;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace Dentiste.api.Hubs;

[Authorize]
public class ClinicHub : Hub
{
    private readonly ILogger<ClinicHub> _logger;

    public ClinicHub(ILogger<ClinicHub> logger)
    {
        _logger = logger;
    }

    public override async Task OnConnectedAsync()
    {
        var cabinetIdStr = Context.User?.Claims.FirstOrDefault(c => c.Type == "CabinetId")?.Value;
        
        if (int.TryParse(cabinetIdStr, out var cabinetId))
        {
            var groupName = $"cabinet_{cabinetId}";
            await Groups.AddToGroupAsync(Context.ConnectionId, groupName);
            _logger.LogInformation("User {UserId} connected to ClinicHub and added to group {GroupName}", Context.UserIdentifier, groupName);
        }
        else
        {
            _logger.LogWarning("User {UserId} connected to ClinicHub but no valid CabinetId was found in claims.", Context.UserIdentifier);
        }

        await base.OnConnectedAsync();
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        var cabinetIdStr = Context.User?.Claims.FirstOrDefault(c => c.Type == "CabinetId")?.Value;
        
        if (int.TryParse(cabinetIdStr, out var cabinetId))
        {
            var groupName = $"cabinet_{cabinetId}";
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, groupName);
            _logger.LogInformation("User {UserId} disconnected from ClinicHub and removed from group {GroupName}", Context.UserIdentifier, groupName);
        }

        await base.OnDisconnectedAsync(exception);
    }
}
