using Dentiste.Core.Shared;
using FluentValidation;

namespace Dentiste.Core.Features.Auth.Commands.ForgetPassword;

public class ForgetPasswordCommandValidator : AbstractValidator<ForgetPasswordCommand>
{
    public ForgetPasswordCommandValidator()
    {
        RuleFor(x => x.MatriculeOrEmail)
            .NotEmpty()
            .WithMessage("L'adresse email ou matricule est requise.");
    }
}
