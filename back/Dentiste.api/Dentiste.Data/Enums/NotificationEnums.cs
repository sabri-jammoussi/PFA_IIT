namespace Dentiste.Data.Enums;

public enum NotificationNature : int
{
    Evenement = 0
}

public enum NotificationDomaine : int
{
    RendezVous = 0,
    Facture = 1,
    Patient = 2,
    Aucun = 9999
}

public enum NotificationType : int
{
    Creation = 1,
    MiseAJour = 2,
    Information = 3
}
