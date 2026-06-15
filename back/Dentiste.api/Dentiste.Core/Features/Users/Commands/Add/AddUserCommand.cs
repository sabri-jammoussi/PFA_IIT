using Dentiste.Core.Messaging;
using Dentiste.Notification.Core;

namespace Dentiste.Core.Features.Users.Commands.Add;

public record AddUserCommand : ICommand<int>, IEventCommand
{
    public required string Username { get; init; }
    public required string Email { get; init; }
    public required string Password { get; init; }
    public required string Nom { get; init; }
    public required string Prenom { get; init; }
    public required int RoleId { get; init; }
    public int? CabinetId { get; set; }

    // MediatR pipeline event mapping properties
    public string EventName => "add-user";
    public object EventPayload => new 
    { 
        Id = Id, 
        Username = Username, 
        Email = Email, 
        Password = Password, 
        Nom = Nom, 
        Prenom = Prenom, 
        RoleId = RoleId, 
        CabinetId = CabinetId 
    };

    // Populated inside the Handler during execution so they are mapped to the event payload
    public int Id { get; set; }
}
