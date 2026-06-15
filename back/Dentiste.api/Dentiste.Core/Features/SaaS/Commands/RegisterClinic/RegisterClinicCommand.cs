using Dentiste.Core.Messaging;
using Dentiste.Notification.Core;

namespace Dentiste.Core.Features.SaaS.Commands.RegisterClinic
{
    public record RegisterClinicCommand : ICommand<int>, IEventCommand
    {
        public required string NomCabinet { get; init; }
        public string? Adresse { get; init; }
        public required string DoctorEmail { get; init; }
        public required string DoctorPassword { get; init; }
        public required string DoctorNom { get; init; }
        public required string DoctorPrenom { get; init; }

        // MediatR pipeline event mapping properties
        public string EventName => "register-clinic";
        
        public object EventPayload => new
        {
            CabinetId = CabinetId,
            NomCabinet = NomCabinet,
            DoctorEmail = DoctorEmail,
            DoctorNom = DoctorNom,
            DoctorPrenom = DoctorPrenom
        };

        // Populated inside the Handler during execution so they are mapped to the event payload
        public int CabinetId { get; set; }
    }
}
