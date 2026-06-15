using System;
using Dentiste.Core.Messaging;
using Dentiste.Notification.Core;

namespace Dentiste.Core.Features.Patients.Commands.Update;

public record UpdatePatientCommand : ICommand, IEventCommand
{
    public required int Id { get; init; }
    public required string Nom { get; init; }
    public required string Prenom { get; init; }
    public required DateTime DateNaissance { get; init; }
    public required string Telephone { get; init; }
    public string? Email { get; init; }
    public string? Adresse { get; init; }
    public string? AntecedentsMedicaux { get; init; }
    public string? GroupSanguin { get; init; }

    public string EventName => "update-patient";
    public object EventPayload { get; set; } = new { };
}
