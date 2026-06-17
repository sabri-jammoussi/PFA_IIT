import 'package:get/get.dart';

class Languages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'fr_FR': _fr,
    'en_US': _en,
  };

  static const Map<String, String> _fr = {
    // Auth
    'login_title': 'Connexion',
    'login_username': 'Nom d\'utilisateur',
    'login_password': 'Mot de passe',
    'login_submit': 'Se connecter',
    'login_error': 'Identifiants incorrects',
    'logout': 'Déconnexion',
    'logout_confirm': 'Confirmer la déconnexion',
    'logout_confirm_msg': 'Voulez-vous vraiment vous déconnecter ?',
    'cancel': 'Annuler',
    'confirm': 'Confirmer',

    // Navigation
    'nav_dashboard': 'Tableau de bord',
    'nav_patients': 'Patients',
    'nav_consultation': 'Consultation',
    'nav_acts': 'Actes',
    'nav_agenda': 'Agenda',
    'nav_requests': 'Demandes',
    'nav_billing': 'Facturation',
    'nav_appointments': 'Rendez-vous',
    'nav_home': 'Accueil',
    'nav_book': 'Réserver',
    'nav_profile': 'Profil',
    'nav_notifications': 'Notifications',
    'nav_settings': 'Paramètres',
    'nav_stock': 'Stock',
    'nav_staff': 'Équipe',

    // Common actions
    'add': 'Ajouter',
    'edit': 'Modifier',
    'delete': 'Supprimer',
    'archive': 'Archiver',
    'save': 'Enregistrer',
    'close': 'Fermer',
    'search': 'Rechercher',
    'filter': 'Filtrer',
    'loading': 'Chargement...',
    'retry': 'Réessayer',
    'no_data': 'Aucune donnée',
    'error_generic': 'Une erreur est survenue',

    // Statuses
    'status_pending': 'EN ATTENTE',
    'status_confirmed': 'CONFIRMÉ',
    'status_cancelled': 'ANNULÉ',
    'status_completed': 'TERMINÉ',
    'status_paid': 'PAYÉ',
    'status_unpaid': 'IMPAYÉ',

    // Patient
    'patient_list': 'Patients',
    'patient_add': 'Nouveau patient',
    'patient_edit': 'Modifier le patient',
    'patient_nom': 'Nom',
    'patient_prenom': 'Prénom',
    'patient_email': 'Email',
    'patient_phone': 'Téléphone',
    'patient_dob': 'Date de naissance',
    'patient_address': 'Adresse',
    'patient_profile': 'Dossier patient',
    'patient_invite': 'Inviter par email',
    'patient_archive_confirm': 'Archiver ce patient ?',

    // Appointments
    'appointment_add': 'Nouveau rendez-vous',
    'appointment_patient': 'Patient',
    'appointment_dentist': 'Dentiste',
    'appointment_date': 'Date',
    'appointment_time': 'Heure',
    'appointment_reason': 'Motif',
    'appointment_cancel': 'Annuler le rendez-vous',
    'appointment_cancel_confirm': 'Confirmer l\'annulation ?',

    // Consultation
    'consultation_title': 'Consultation',
    'consultation_add': 'Nouvelle consultation',
    'consultation_notes': 'Notes',
    'consultation_diagnosis': 'Diagnostic',
    'consultation_tooth': 'Dent',
    'consultation_face': 'Face',
    'consultation_treatment': 'Traitement',
    'consultation_price': 'Prix appliqué',
    'prescription_add': 'Nouvelle ordonnance',
    'prescription_content': 'Contenu',

    // Billing
    'invoice_list': 'Factures',
    'payment_add': 'Enregistrer un paiement',
    'payment_amount': 'Montant',
    'payment_method': 'Mode de paiement',
    'payment_date': 'Date du paiement',
    'payment_cash': 'Espèces',
    'payment_check': 'Chèque',
    'payment_card': 'Carte',

    // Stock
    'stock_title': 'Stock',
    'stock_add': 'Nouvel article',
    'stock_label': 'Désignation',
    'stock_quantity': 'Quantité',
    'stock_price': 'Prix unitaire',
    'stock_supplier': 'Fournisseur',
    'stock_restock': 'Réapprovisionner',

    // Notifications
    'notifications_title': 'Notifications',
    'notifications_mark_all': 'Tout marquer comme lu',
    'notifications_empty': 'Aucune notification',

    // Profile
    'profile_title': 'Mon profil',
    'profile_username': 'Nom d\'utilisateur',
    'profile_email': 'Email',
    'profile_nom': 'Nom',
    'profile_prenom': 'Prénom',
    'profile_password': 'Mot de passe',
    'profile_new_password': 'Nouveau mot de passe',
    'profile_save': 'Mettre à jour le profil',

    // Settings
    'settings_title': 'Paramètres',
    'settings_theme': 'Thème sombre',
    'settings_language': 'Langue',
    'settings_lang_fr': 'Français',
    'settings_lang_en': 'English',

    // Drawer
    'drawer_welcome': 'Bienvenue,',
    'app_version': 'Version',

    // Patient portal
    'portal_appointments': 'Mes rendez-vous',
    'portal_medical_record': 'Mon dossier médical',
    'portal_book': 'Réserver un rendez-vous',
    'portal_availability': 'Disponibilités',
    'portal_request': 'Envoyer la demande',

    // Subscription
    'subscription_expired_title': 'Abonnement expiré',
    'subscription_expired_msg': 'Votre abonnement a expiré. Veuillez contacter l\'administrateur.',
    'subscription_reactivate': 'Réactiver l\'abonnement',

    // Admin
    'admin_web_only_title': 'Interface web requise',
    'admin_web_only_msg': 'L\'espace administrateur est accessible uniquement depuis le portail web.',
  };

  static const Map<String, String> _en = {
    // Auth
    'login_title': 'Sign In',
    'login_username': 'Username',
    'login_password': 'Password',
    'login_submit': 'Sign In',
    'login_error': 'Invalid credentials',
    'logout': 'Logout',
    'logout_confirm': 'Confirm logout',
    'logout_confirm_msg': 'Are you sure you want to log out?',
    'cancel': 'Cancel',
    'confirm': 'Confirm',

    // Navigation
    'nav_dashboard': 'Dashboard',
    'nav_patients': 'Patients',
    'nav_consultation': 'Consultation',
    'nav_acts': 'Acts',
    'nav_agenda': 'Agenda',
    'nav_requests': 'Requests',
    'nav_billing': 'Billing',
    'nav_appointments': 'Appointments',
    'nav_home': 'Home',
    'nav_book': 'Book',
    'nav_profile': 'Profile',
    'nav_notifications': 'Notifications',
    'nav_settings': 'Settings',
    'nav_stock': 'Stock',
    'nav_staff': 'Staff',

    // Common
    'add': 'Add',
    'edit': 'Edit',
    'delete': 'Delete',
    'archive': 'Archive',
    'save': 'Save',
    'close': 'Close',
    'search': 'Search',
    'filter': 'Filter',
    'loading': 'Loading...',
    'retry': 'Retry',
    'no_data': 'No data',
    'error_generic': 'An error occurred',

    // Statuses
    'status_pending': 'PENDING',
    'status_confirmed': 'CONFIRMED',
    'status_cancelled': 'CANCELLED',
    'status_completed': 'COMPLETED',
    'status_paid': 'PAID',
    'status_unpaid': 'UNPAID',

    // Patient
    'patient_list': 'Patients',
    'patient_add': 'New patient',
    'patient_edit': 'Edit patient',
    'patient_nom': 'Last name',
    'patient_prenom': 'First name',
    'patient_email': 'Email',
    'patient_phone': 'Phone',
    'patient_dob': 'Date of birth',
    'patient_address': 'Address',
    'patient_profile': 'Patient file',
    'patient_invite': 'Invite by email',
    'patient_archive_confirm': 'Archive this patient?',

    // Appointments
    'appointment_add': 'New appointment',
    'appointment_patient': 'Patient',
    'appointment_dentist': 'Dentist',
    'appointment_date': 'Date',
    'appointment_time': 'Time',
    'appointment_reason': 'Reason',
    'appointment_cancel': 'Cancel appointment',
    'appointment_cancel_confirm': 'Confirm cancellation?',

    // Consultation
    'consultation_title': 'Consultation',
    'consultation_add': 'New consultation',
    'consultation_notes': 'Notes',
    'consultation_diagnosis': 'Diagnosis',
    'consultation_tooth': 'Tooth',
    'consultation_face': 'Face',
    'consultation_treatment': 'Treatment',
    'consultation_price': 'Applied price',
    'prescription_add': 'New prescription',
    'prescription_content': 'Content',

    // Billing
    'invoice_list': 'Invoices',
    'payment_add': 'Record payment',
    'payment_amount': 'Amount',
    'payment_method': 'Payment method',
    'payment_date': 'Payment date',
    'payment_cash': 'Cash',
    'payment_check': 'Check',
    'payment_card': 'Card',

    // Stock
    'stock_title': 'Inventory',
    'stock_add': 'New item',
    'stock_label': 'Label',
    'stock_quantity': 'Quantity',
    'stock_price': 'Unit price',
    'stock_supplier': 'Supplier',
    'stock_restock': 'Restock',

    // Notifications
    'notifications_title': 'Notifications',
    'notifications_mark_all': 'Mark all as read',
    'notifications_empty': 'No notifications',

    // Profile
    'profile_title': 'My profile',
    'profile_username': 'Username',
    'profile_email': 'Email',
    'profile_nom': 'Last name',
    'profile_prenom': 'First name',
    'profile_password': 'Password',
    'profile_new_password': 'New password',
    'profile_save': 'Update profile',

    // Settings
    'settings_title': 'Settings',
    'settings_theme': 'Dark theme',
    'settings_language': 'Language',
    'settings_lang_fr': 'Français',
    'settings_lang_en': 'English',

    // Drawer
    'drawer_welcome': 'Welcome,',
    'app_version': 'Version',

    // Patient portal
    'portal_appointments': 'My appointments',
    'portal_medical_record': 'My medical record',
    'portal_book': 'Book an appointment',
    'portal_availability': 'Availability',
    'portal_request': 'Send request',

    // Subscription
    'subscription_expired_title': 'Subscription expired',
    'subscription_expired_msg': 'Your subscription has expired. Please contact the administrator.',
    'subscription_reactivate': 'Reactivate subscription',

    // Admin
    'admin_web_only_title': 'Web interface required',
    'admin_web_only_msg': 'The admin space is only accessible from the web portal.',
  };
}
