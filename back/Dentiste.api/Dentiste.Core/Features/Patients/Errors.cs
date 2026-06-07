namespace Dentiste.Core.Features.Patients;

public static class Errors
{
    public const string PatientNotFound = "Patient non trouvé.";
    public const string EmailAlreadyExists = "Un patient avec cet email existe déjà.";
    public const string DatabaseError = "Une erreur est survenue lors de l'accès à la base de données.";
}
