using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Infrastructure.Security;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Patients.Queries.GetMy;

public class GetMyMedicalRecordQueryHandler : MediatR.IRequestHandler<GetMyMedicalRecordQuery, Result<MyMedicalRecordDto>>
{
    private readonly DentisteContext _context;
    private readonly ICurrentUserProvider _currentUserProvider;

    public GetMyMedicalRecordQueryHandler(DentisteContext context, ICurrentUserProvider currentUserProvider)
    {
        _context = context;
        _currentUserProvider = currentUserProvider;
    }

    public async Task<Result<MyMedicalRecordDto>> Handle(GetMyMedicalRecordQuery request, CancellationToken cancellationToken)
    {
        var userId = _currentUserProvider.GetUserId();
        if (!userId.HasValue)
        {
            return Result.Failure<MyMedicalRecordDto>("Utilisateur non authentifié.");
        }

        // 1. Get user account to find email
        var user = await _context.Users
            .AsNoTracking()
            .FirstOrDefaultAsync(u => u.Id == userId.Value, cancellationToken);
        if (user == null)
        {
            return Result.Failure<MyMedicalRecordDto>("Utilisateur non trouvé.");
        }

        // 2. Get patient matching the email
        var patient = await _context.Patients
            .AsNoTracking()
            .FirstOrDefaultAsync(p => p.Email == user.Email, cancellationToken);
        if (patient == null)
        {
            return Result.Failure<MyMedicalRecordDto>("Dossier patient introuvable.");
        }

        var dto = new MyMedicalRecordDto
        {
            PatientInfo = new PatientProfileDto
            {
                Id = patient.Id,
                Nom = patient.Nom,
                Prenom = patient.Prenom,
                Email = patient.Email,
                Telephone = patient.Telephone,
                Adresse = patient.Adresse,
                DateNaissance = patient.DateNaissance,
                AntecedentsMedicaux = patient.AntecedentsMedicaux ?? "Aucun",
                GroupSanguin = patient.GroupSanguin ?? "Inconnu"
            }
        };

        // 3. Query consultations for the patient
        dto.Consultations = await _context.Consultations
            .AsNoTracking()
            .Include(c => c.Dentiste)
            .Include(c => c.SoinsEffectues)
                .ThenInclude(s => s.ActeMedical)
            .Where(c => c.PatientId == patient.Id)
            .OrderByDescending(c => c.DateConsultation)
            .Select(c => new PatientConsultationDto
            {
                Id = c.Id,
                DateConsultation = c.DateConsultation,
                NotesObservations = c.NotesObservations ?? string.Empty,
                DentisteNomComplet = c.Dentiste != null ? $"{c.Dentiste.Prenom} {c.Dentiste.Nom}" : "Non assigné",
                Soins = c.SoinsEffectues.Select(s => new PatientSoinDto
                {
                    Id = s.Id,
                    NumeroDent = s.NumeroDent ?? 0,
                    FaceDentaire = s.FaceDentaire ?? string.Empty,
                    PrixApplique = s.PrixApplique,
                    ActeLibelle = s.ActeMedical != null ? s.ActeMedical.Libelle : "Acte inconnu"
                }).ToList()
            })
            .ToListAsync(cancellationToken);

        // 4. Query prescriptions (ordonnances)
        dto.Prescriptions = await _context.Ordonnances
            .AsNoTracking()
            .Include(o => o.Consultation)
                .ThenInclude(c => c.Dentiste)
            .Where(o => o.Consultation.PatientId == patient.Id)
            .OrderByDescending(o => o.DateEmission)
            .Select(o => new PatientPrescriptionDto
            {
                Id = o.Id,
                DateEmission = o.DateEmission,
                Traitement = o.Traitement,
                DentisteNomComplet = o.Consultation.Dentiste != null ? $"{o.Consultation.Dentiste.Prenom} {o.Consultation.Dentiste.Nom}" : "Non assigné"
            })
            .ToListAsync(cancellationToken);

        // 5. Query invoices (factures)
        dto.Invoices = await _context.Factures
            .AsNoTracking()
            .Where(f => f.PatientId == patient.Id)
            .OrderByDescending(f => f.DateEmission)
            .Select(f => new PatientInvoiceDto
            {
                Id = f.Id,
                NumeroFacture = f.NumeroFacture,
                DateEmission = f.DateEmission,
                MontantTotal = f.MontantTotal,
                MontantPaye = f.MontantPaye,
                StatutPaiement = f.StatutPaiement
            })
            .ToListAsync(cancellationToken);

        return Result.Success(dto);
    }
}
