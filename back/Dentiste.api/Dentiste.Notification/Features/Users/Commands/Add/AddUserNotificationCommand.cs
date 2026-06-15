using MediatR;
using Dentiste.Core.Shared;

namespace Dentiste.Notification.Features.Users.Commands.Add
{
    public record AddUserNotificationCommand : IRequest<Result>
    {
        public int Id { get; init; }
        public required string Username { get; init; }
        public required string Email { get; init; }
        public required string Password { get; init; }
        public required string Nom { get; init; }
        public required string Prenom { get; init; }
        public int RoleId { get; init; }
        public int? CabinetId { get; init; }
    }
}
