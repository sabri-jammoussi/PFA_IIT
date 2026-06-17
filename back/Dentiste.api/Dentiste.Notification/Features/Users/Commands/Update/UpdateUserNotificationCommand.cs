using MediatR;
using Dentiste.Core.Shared;

namespace Dentiste.Notification.Features.Users.Commands.Update
{
    public record UpdateUserNotificationCommand : IRequest<Result>
    {
        public int Id { get; init; }
        public required string Username { get; init; }
        public required string Email { get; init; }
        public bool PasswordChanged { get; init; }
        public required string Nom { get; init; }
        public required string Prenom { get; init; }
        public int RoleId { get; init; }
        public bool IsActive { get; init; }
        public int? CabinetId { get; init; }
    }
}
