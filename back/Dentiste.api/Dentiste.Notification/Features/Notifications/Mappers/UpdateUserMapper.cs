using MediatR;
using Dentiste.Notification.Core;
using Dentiste.Notification.Features.Users.Commands.Update;

namespace Dentiste.Notification.Features.Notifications.Mappers
{
    public class UpdateUserMapper : IEventCommandMapper
    {
        public IBaseRequest? Convert(dynamic payload)
        {
            return new UpdateUserNotificationCommand
            {
                Id = (int)payload.Id,
                Username = (string)payload.Username,
                Email = (string)payload.Email,
                PasswordChanged = (bool)payload.PasswordChanged,
                Nom = (string)payload.Nom,
                Prenom = (string)payload.Prenom,
                RoleId = (int)payload.RoleId,
                IsActive = (bool)payload.IsActive,
                CabinetId = (int?)payload.CabinetId
            };
        }
    }
}
