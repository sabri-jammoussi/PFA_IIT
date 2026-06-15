using System;
using System.Collections.Generic;

namespace Dentiste.Core.Features.Patients.Queries.GetMy;

public class MyMedicalRecordDto
{
    public PatientProfileDto PatientInfo { get; set; } = null!;
    public List<PatientConsultationDto> Consultations { get; set; } = new();
    public List<PatientPrescriptionDto> Prescriptions { get; set; } = new();
    public List<PatientInvoiceDto> Invoices { get; set; } = new();
}

public class PatientProfileDto
{
    public int Id { get; set; }
    public string Nom { get; set; } = string.Empty;
    public string Prenom { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Telephone { get; set; } = string.Empty;
    public string Adresse { get; set; } = string.Empty;
    public DateTime? DateNaissance { get; set; }
    public string AntecedentsMedicaux { get; set; } = string.Empty;
    public string GroupSanguin { get; set; } = string.Empty;
}

public class PatientConsultationDto
{
    public int Id { get; set; }
    public DateTime DateConsultation { get; set; }
    public string NotesObservations { get; set; } = string.Empty;
    public string DentisteNomComplet { get; set; } = string.Empty;
    public List<PatientSoinDto> Soins { get; set; } = new();
}

public class PatientSoinDto
{
    public int Id { get; set; }
    public int NumeroDent { get; set; }
    public string FaceDentaire { get; set; } = string.Empty;
    public decimal PrixApplique { get; set; }
    public string ActeLibelle { get; set; } = string.Empty;
}

public class PatientPrescriptionDto
{
    public int Id { get; set; }
    public DateTime DateEmission { get; set; }
    public string Traitement { get; set; } = string.Empty;
    public string DentisteNomComplet { get; set; } = string.Empty;
}

public class PatientInvoiceDto
{
    public int Id { get; set; }
    public string NumeroFacture { get; set; } = string.Empty;
    public DateTime DateEmission { get; set; }
    public decimal MontantTotal { get; set; }
    public decimal MontantPaye { get; set; }
    public string StatutPaiement { get; set; } = string.Empty;
}
