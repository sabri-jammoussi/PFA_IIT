namespace Dentiste.Notification.Core
{
    public class NotificationEventCommand
    {
        private const string ADD_RENDEZVOUS = "add-rendezvous";
        private const string ADD_PAIEMENT = "add-paiement";
        private const string UPDATE_PATIENT = "update-patient";
        private const string INVITE_PATIENT = "invite-patient";

        public static readonly string AddRendezVous = ADD_RENDEZVOUS;
        public static readonly string AddPaiement = ADD_PAIEMENT;
        public static readonly string UpdatePatient = UPDATE_PATIENT;
        public static readonly string InvitePatient = INVITE_PATIENT;
    }
}
