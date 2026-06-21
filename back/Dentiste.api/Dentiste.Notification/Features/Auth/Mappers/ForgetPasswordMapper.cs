using MediatR;
using Dentiste.Notification.Core;
using Dentiste.Notification.Features.Auth.Commands.ForgetPassword;

namespace Dentiste.Notification.Features.Auth.Mappers;

public class ForgetPasswordMapper : IEventCommandMapper
{
    public IBaseRequest? Convert(dynamic payload)
    {
        return new ForgetPasswordNotificationCommand
        {
            Email = payload.Email,
            NewPassword = payload.NewPassword,
            Host = payload.Host,
            NomPrenom = payload.NomPrenom
        };
    }
}
