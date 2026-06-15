using MediatR;
using Dentiste.Notification.Core;
using Dentiste.Notification.Features.SaaS.Commands.RegisterClinic;

namespace Dentiste.Notification.Features.Notifications.Mappers
{
    public class RegisterClinicMapper : IEventCommandMapper
    {
        public IBaseRequest? Convert(dynamic payload)
        {
            return new RegisterClinicNotificationCommand
            {
                CabinetId = payload.CabinetId,
                NomCabinet = payload.NomCabinet,
                DoctorEmail = payload.DoctorEmail,
                DoctorNom = payload.DoctorNom,
                DoctorPrenom = payload.DoctorPrenom
            };
        }
    }
}
