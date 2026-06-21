using Dentiste.Core.Shared;
using MediatR;

namespace Dentiste.Notification.Features.Auth.Commands.ForgetPassword;

public class ForgetPasswordNotificationCommand : IRequest<Result>
{
    public string Email { get; set; } = string.Empty;
    public string NewPassword { get; set; } = string.Empty;
    public string Host { get; set; } = string.Empty;
    public string NomPrenom { get; set; } = string.Empty;
}
