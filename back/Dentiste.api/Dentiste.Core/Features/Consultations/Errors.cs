namespace Dentiste.Core.Features.Consultations;

public static class Errors
{
    public const string ConsultationNotFound = "Consultation non trouvée.";
    public const string PatientNotFound = "Patient non trouvé.";
    public const string DentisteNotFound = "Dentiste non trouvé.";
    public const string ConsultationAlreadyFinalized = "Cette consultation a déjà été facturée.";
    public const string NoTreatmentsToInvoice = "Aucun soin enregistré : impossible de générer la facture.";
}
