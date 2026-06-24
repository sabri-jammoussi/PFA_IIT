using System.Collections.Generic;
using Dentiste.Core.Messaging;

namespace Dentiste.Core.Features.Appointments.Queries.GetWaitingRoom;

public record GetWaitingRoomQuery : IQuery<List<WaitingRoomEntryDto>>
{
    // When set, restricts the queue to a single practitioner (the doctor's own chair).
    public int? DentisteId { get; init; }
}
