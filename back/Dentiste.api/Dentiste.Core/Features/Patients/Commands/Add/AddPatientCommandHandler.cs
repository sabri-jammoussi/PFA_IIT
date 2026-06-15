using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;
using Dentiste.Data.Models;
using Microsoft.EntityFrameworkCore;

namespace Dentiste.Core.Features.Patients.Commands.Add;

public class AddPatientCommandHandler : ICommandHandler<AddPatientCommand, int>
{
	private readonly DentisteContext _context;

	public AddPatientCommandHandler(DentisteContext context)
	{
		_context = context;
	}

	public async Task<Result<int>> Handle(AddPatientCommand request, CancellationToken cancellationToken)
	{
		if (!string.IsNullOrEmpty(request.Email))
		{
			var emailExists = await _context.Patients
				.AnyAsync(p => p.Email == request.Email, cancellationToken);

			if (emailExists)
			{
				return Result.Failure<int>(Errors.EmailAlreadyExists);
			}
		}

		var patient = new PatientDao
		{
			Nom = request.Nom,
			Prenom = request.Prenom,
			DateNaissance = request.DateNaissance,
			Telephone = request.Telephone,
			Email = request.Email,
			Adresse = request.Adresse,
			AntecedentsMedicaux = request.AntecedentsMedicaux,
			GroupSanguin = request.GroupSanguin,
			CreatedAt = DateTime.UtcNow
		};

		_context.Patients.Add(patient);
		await _context.SaveChangesAsync(cancellationToken);

		return Result.Success(patient.Id);
	}
}
