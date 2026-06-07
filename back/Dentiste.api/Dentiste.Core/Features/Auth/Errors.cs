namespace Dentiste.Core.Features.Auth;

public static class Errors
{
    public const string InvalidCredentials = "Nom d'utilisateur ou mot de passe incorrect.";
    public const string AccountDisabled = "Ce compte est désactivé.";
    public const string InvalidToken = "Token invalide ou expiré.";
}
