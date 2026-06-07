namespace Dentiste.Core.Features.Users;

public static class Errors
{
    public const string UserNotFound = "Utilisateur non trouvé.";
    public const string UsernameAlreadyExists = "Ce nom d'utilisateur est déjà pris.";
    public const string EmailAlreadyExists = "Cet email est déjà associé à un compte.";
    public const string RoleNotFound = "Le rôle spécifié n'existe pas.";
}
