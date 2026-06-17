using System;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Infrastructure.Security;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data;
using Dentiste.Data.Infrastructure.EF;
using Dentiste.Data.Models;

namespace Dentiste.Core.Features.SaaS.Commands.RegisterClinic
{
    public class RegisterClinicCommandHandler : ICommandHandler<RegisterClinicCommand, int>
    {
        private readonly DentisteContext _context;
        private readonly IPasswordHasher _passwordHasher;

        public RegisterClinicCommandHandler(DentisteContext context, IPasswordHasher passwordHasher)
        {
            _context = context;
            _passwordHasher = passwordHasher;
        }

        public async Task<Result<int>> Handle(RegisterClinicCommand request, CancellationToken cancellationToken)
        {
            // Validate unique constraints for the owner doctor email / username
            var emailExists = await _context.Users.AnyAsync(u => u.Email == request.DoctorEmail, cancellationToken);
            if (emailExists)
            {
                return Result.Failure<int>("Cette adresse email est déjà associée à un compte.");
            }

            var usernameExists = await _context.Users.AnyAsync(u => u.Username == request.DoctorEmail, cancellationToken);
            if (usernameExists)
            {
                return Result.Failure<int>("Ce nom d'utilisateur est déjà pris.");
            }

            // Find role Dentiste
            var dentistRole = await _context.Roles.FirstOrDefaultAsync(r => r.Name == AppRoles.Dentiste, cancellationToken);
            if (dentistRole == null)
            {
                return Result.Failure<int>("Le rôle Dentiste n'a pas été trouvé dans la base de données.");
            }

            // 1. Create a new CabinetDao instance (status: Active)
            var cabinet = new CabinetDao
            {
                NomCabinet = request.NomCabinet,
                Adresse = request.Adresse,
                CreatedAt = DateTime.UtcNow,
                IsSubscriptionActive = true
            };

            _context.Cabinets.Add(cabinet);
            
            // Save changes to generate CabinetId. Note: Since GetCabinetId() is null on public endpoint,
            // we bypass the global query filter for inserts (they don't need tenant ID since Cabinet isn't tenant-filtered).
            await _context.SaveChangesAsync(cancellationToken);

            // Generate stable unique Cloudinary folder based on registration name and generated Cabinet ID
            var sanitizedName = SanitizeFolderName(cabinet.NomCabinet);
            cabinet.CloudinaryFolder = $"cab_{cabinet.Id}_{sanitizedName}";
            await _context.SaveChangesAsync(cancellationToken);

            // 2. Create the owner Doctor user bound to that cabinet
            var salt = Guid.NewGuid().ToString("N");
            var passwordHash = _passwordHasher.Hash(request.DoctorPassword, salt);

            var user = new UserDao
            {
                Username = request.DoctorEmail,
                Email = request.DoctorEmail,
                PasswordHash = passwordHash,
                PasswordSalt = salt,
                Nom = request.DoctorNom,
                Prenom = request.DoctorPrenom,
                IsActive = true,
                RoleId = dentistRole.Id,
                CreatedAt = DateTime.UtcNow,
                CabinetId = cabinet.Id
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync(cancellationToken);

            // Populate CabinetId in request command so MediatR pipeline picks it up for the Hangfire payload
            request.CabinetId = cabinet.Id;

            return Result.Success(cabinet.Id);
        }

        private string SanitizeFolderName(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "unknown";
            var sanitized = name.Trim().ToLowerInvariant();
            sanitized = Regex.Replace(sanitized, @"\s+", "_"); // Replace spaces with underscores
            sanitized = Regex.Replace(sanitized, @"[^a-z0-9_-]", ""); // Keep only safe chars
            return sanitized;
        }
    }
}
