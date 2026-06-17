using FluentValidation;

namespace Dentiste.Core.Features.Users.Commands.Update;

public class UpdateUserCommandValidator : AbstractValidator<UpdateUserCommand>
{
    public UpdateUserCommandValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0);

        RuleFor(x => x.Username)
            .NotEmpty().WithMessage("Le nom d'utilisateur est obligatoire.")
            .MaximumLength(50);

        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("L'email est obligatoire.")
            .EmailAddress().WithMessage("Format d'email invalide.")
            .MaximumLength(100);

        RuleFor(x => x.Nom).NotEmpty().MaximumLength(100);
        RuleFor(x => x.Prenom).NotEmpty().MaximumLength(100);
        RuleFor(x => x.RoleId).GreaterThan(0).WithMessage("Le rôle est obligatoire.");

        // Password is optional on update, but when supplied it must meet the policy.
        When(x => !string.IsNullOrWhiteSpace(x.Password), () =>
        {
            RuleFor(x => x.Password!)
                .MinimumLength(8).WithMessage("Le mot de passe doit comporter au moins 8 caractères.")
                .MaximumLength(128);
        });
    }
}
