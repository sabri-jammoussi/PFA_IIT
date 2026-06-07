using System;
using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Consultations.Commands.Add;

public record AddConsultationCommand : ICommand<int>
{
    public required DateTime DateConsultation { get; init; }
    public string? NotesObservations { get; init; }
    public required int PatientId { get; init; }
    public required int DentisteId { get; init; }
}
