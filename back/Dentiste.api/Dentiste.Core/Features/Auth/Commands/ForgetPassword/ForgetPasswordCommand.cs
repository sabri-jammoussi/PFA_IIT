using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Notification.Core;
using System.Text.Json.Serialization;

namespace Dentiste.Core.Features.Auth.Commands.ForgetPassword;

public class ForgetPasswordCommand : ICommand, IEventCommand
{
    public string MatriculeOrEmail { get; set; } = string.Empty;
    public string Host { get; set; } = string.Empty;

    // Set by the Handler to pass to the Notification service
    [JsonIgnore]
    public string ResolvedEmail { get; set; } = string.Empty;
    
    [JsonIgnore]
    public string NewPassword { get; set; } = string.Empty;
    
    [JsonIgnore]
    public string NomPrenom { get; set; } = string.Empty;

    [JsonIgnore]
    public string EventName => "forget-password";

    [JsonIgnore]
    public object EventPayload => new { Email = ResolvedEmail, NewPassword, Host, NomPrenom };
}
