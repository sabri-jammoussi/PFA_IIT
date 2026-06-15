using MediatR;
using Dentiste.Notification.Core;
using Dentiste.Notification.Features.Users.Commands.Add;

namespace Dentiste.Notification.Features.Notifications.Mappers
{
    public class AddUserMapper : IEventCommandMapper
    {
        public IBaseRequest? Convert(dynamic payload)
        {
            return new AddUserNotificationCommand
            {
                Id = payload.Id,
                Username = payload.Username,
                Email = payload.Email,
                Password = payload.Password,
                Nom = payload.Nom,
                Prenom = payload.Prenom,
                RoleId = payload.RoleId,
                CabinetId = payload.CabinetId
            };
        }
    }
}
