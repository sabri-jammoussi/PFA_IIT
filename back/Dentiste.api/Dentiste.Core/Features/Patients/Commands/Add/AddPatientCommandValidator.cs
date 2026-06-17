using System;
using FluentValidation;

namespace Dentiste.Core.Features.Patients.Commands.Add;

public class AddPatientCommandValidator : AbstractValidator<AddPatientCommand>
{
    public AddPatientCommandValidator()
    {
        RuleFor(x => x.Nom).NotEmpty().MaximumLength(100);
        RuleFor(x => x.Prenom).NotEmpty().MaximumLength(100);

        RuleFor(x => x.DateNaissance)
            .NotEmpty()
            .LessThan(_ => DateTime.UtcNow).WithMessage("La date de naissance doit être dans le passé.")
            .GreaterThan(new DateTime(1900, 1, 1)).WithMessage("Date de naissance invalide.");

        RuleFor(x => x.Telephone)
            .NotEmpty().WithMessage("Le téléphone est obligatoire.")
            .MaximumLength(20)
            .Matches(@"^[0-9+\s()\-]{6,20}$").WithMessage("Format de téléphone invalide.");

        RuleFor(x => x.Email)
            .EmailAddress().WithMessage("Format d'email invalide.")
            .MaximumLength(100)
            .When(x => !string.IsNullOrWhiteSpace(x.Email));
    }
}
