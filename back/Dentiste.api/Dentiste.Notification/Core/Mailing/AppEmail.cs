namespace Dentiste.Notification.Core.Mailing
{
    public class AppEmail
    {
        public string Message { get; set; } = "Hello World!";
        public int? CabinetId { get; set; }
        public string To { get; set; } = string.Empty;
        public string Subject { get; set; } = string.Empty;
        public string Template { get; set; } = string.Empty;
        public string Destinateur { get; set; } = string.Empty;
        public string Admin { get; set; } = string.Empty;
        public string Reference { get; set; } = string.Empty;
        public string Demande { get; set; } = string.Empty;
        public string NewPassword { get; set; } = string.Empty;
        public string Motif { get; set; } = string.Empty;
        public string BodyTemplate { get; set; } = string.Empty;
        public string EmailResetPassword { get; set; } = string.Empty;
        public string ConfirmationLink { get; set; } = string.Empty;
        public string ImageURL { get; set; } = string.Empty;
    }
}
