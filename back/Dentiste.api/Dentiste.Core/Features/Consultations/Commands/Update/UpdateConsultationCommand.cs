using System;
using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Consultations.Commands.Update;

public record UpdateConsultationCommand : ICommand
{
    public required int Id { get; init; }
    public required DateTime DateConsultation { get; init; }
    public string? NotesObservations { get; init; }
    public required int PatientId { get; init; }
    public required int DentisteId { get; init; }
}
