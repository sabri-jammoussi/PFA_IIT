using System;
using Dentiste.Core.Messaging;
using Dentiste.Notification.Core;

namespace Dentiste.Core.Features.Patients.Commands.Invite;

public record InvitePatientCommand : ICommand<int>, IEventCommand
{
    public required string Nom { get; init; }
    public required string Prenom { get; init; }
    public required DateTime DateNaissance { get; init; }
    public required string Telephone { get; init; }
    public required string Email { get; init; }
    public string? Adresse { get; init; }
    public string? AntecedentsMedicaux { get; init; }
    public string? GroupSanguin { get; init; }

    // MediatR pipeline event mapping properties
    public string EventName => "invite-patient";
    public object EventPayload => new 
    { 
        PatientId = PatientId, 
        Nom = Nom, 
        Prenom = Prenom, 
        Email = Email, 
        TemporaryPassword = TemporaryPassword 
    };

    // Populated inside the Handler during execution so they are mapped to the event payload
    public int PatientId { get; set; }
    public string TemporaryPassword { get; set; } = string.Empty;
}
