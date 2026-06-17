using FluentValidation;

namespace Dentiste.Core.Features.Users.Commands.Add;

public class AddUserCommandValidator : AbstractValidator<AddUserCommand>
{
    public AddUserCommandValidator()
    {
        RuleFor(x => x.Username)
            .NotEmpty().WithMessage("Le nom d'utilisateur est obligatoire.")
            .MaximumLength(50);

        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("L'email est obligatoire.")
            .EmailAddress().WithMessage("Format d'email invalide.")
            .MaximumLength(100);

        RuleFor(x => x.Password)
            .NotEmpty().WithMessage("Le mot de passe est obligatoire.")
            .MinimumLength(8).WithMessage("Le mot de passe doit comporter au moins 8 caractères.")
            .MaximumLength(128);

        RuleFor(x => x.Nom).NotEmpty().MaximumLength(100);
        RuleFor(x => x.Prenom).NotEmpty().MaximumLength(100);
        RuleFor(x => x.RoleId).GreaterThan(0).WithMessage("Le rôle est obligatoire.");
    }
}
