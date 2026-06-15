# 👥 Module Portail Patient & Système d'Invitation Hybride

## 📌 Présentation Générale
Pour maintenir un niveau de sécurité maximal et éviter les inscriptions frauduleuses ou anonymes sur la plateforme, le système adopte un modèle d'accès **sur invitation uniquement**. 
Le compte d'un patient n'est créé et activé que lorsqu'une **Secrétaire** ou un **Dentiste** valide son intégration depuis l'interface Web et lui envoie ses accès initiaux. Le patient télécharge ensuite l'application mobile **Flutter** pour suivre ses visites et soumettre des demandes de rendez-vous.

---

## 🔄 Workflow d'Invitation et d'Accès

```text
[ Secrétaire/Dentiste ] ──(Saisit Email/Tél)──> [ API ASP.NET Core ]
                                                      │
                                           (Génère User + Rôle Patient)
                                                      │
                                                      ▼
[ Application Mobile Flutter ] <──(Reçoit Email/SMS)── [ Envoi Code/Lien d'Accès ]
  └─► Connexion Sécurisée JWT
  └─► Consultation de l'historique & Demandes de RDV
```

1. **Création du profil & Invitation (Secrétaire)** : Lors de l'accueil ou d'un appel, la secrétaire crée la fiche du patient dans l'onglet Patient Intake (Vue.js). En saisissant l'adresse email, le système génère automatiquement un compte utilisateur lié au rôle Patient avec un mot de passe temporaire ou un jeton d'activation.
2. **Notification d'accès** : Le service d'arrière-plan (`NotificationWorker`) intercepte l'action et envoie un email ou SMS de bienvenue contenant les identifiants de connexion.
3. **Première Connexion (Patient)** : Le patient se connecte sur l'application mobile Flutter, modifie son mot de passe initial, et accède à son espace personnel haut de gamme.

---

## 🛠️ Spécifications Techniques Backend (Dentiste.Core & api)

### 1. Ajustement des Rôles et États
- **Rôle Utilisateur** : Ajout de la valeur `Patient` dans la table `ROLE` (ou enum correspondante).
- **Statut de Rendez-vous** : Ajout de l'état `EnAttenteValidation` dans la table `RENDEZ_VOUS` (ou enum `RendezVousStatus`) pour les requêtes initiées par le patient.

### 2. Endpoints API Dédiés (PatientsController.cs ou AppointmentsController.cs)

| Méthode | Endpoint | Rôle Autorisé | Description |
| :--- | :--- | :--- | :--- |
| **POST** | `/api/patients/invite` | Secrétaire, Dentiste | Crée le patient, son compte User associé, et déclenche l'invitation. |
| **GET** | `/api/my/appointments` | Patient | Récupère l'historique complet des visites du patient connecté (Trié par date décroissante). |
| **POST** | `/api/my/appointments/request` | Patient | Soumet une demande de rendez-vous (`EnAttenteValidation`). |
| **GET** | `/api/appointments/pending` | Secrétaire | Liste toutes les demandes des patients en attente de validation pour la grille de l'agenda. |

### 3. Logique de Sécurité (Claims Binding)
Pour empêcher un patient de consulter le dossier d'un autre utilisateur, le Handler CQRS `GetMyAppointmentsQueryHandler` extrait l'ID unique de l'utilisateur directement depuis le Token JWT injecté dans le contexte HTTP (`User.Identity.Name` ou le claim `NameIdentifier`), garantissant une étanchéité parfaite des données médicales.

---

## 📱 Architecture Mobile Flutter (Interface Patient)

Lorsque le jeton JWT décodé au login contient le rôle Patient, l'application Flutter redirige l'utilisateur vers une interface épurée et minimaliste (Thème Premium Deep Navy & Soft Gray).

### Structure des Écrans Mobile
- **Écran 1 : Tableau de Bord & Historique (HistoryTimelineWidget)**
  - Affichage de la date du prochain rendez-vous confirmé (si existant) sous forme de carte moderne en relief (`shadow-sm`).
  - Une frise chronologique (Timeline) listant les anciennes visites :
    - *Champs visibles* : Date, Heure, Nom du Praticien, Titre global de l'acte (ex: Détartrage, Consultation de contrôle).
    - *Champs masqués (Confidentialité)* : Notes cliniques privées du docteur, détails du schéma dentaire.
  - *Section Facturation* : Possibilité de télécharger le reçu ou de voir le statut de paiement (Payé / En attente).
- **Écran 2 : Formulaire de Demande de Rendez-vous (AppointmentRequestForm)**
  - *Sélecteur de Date* : Calendrier fluide pour choisir le jour souhaité.
  - *Plage Horaire* : Choix simplifié (Matinée : 8h-12h / Après-midi : 14h-18h).
  - *Menu Déroulant des Motifs* : Liste fixe (Contrôle de routine, Douleur aiguë, Détartrage/Nettoyage, Suivi de traitement).
  - *Bouton d'Action* : Soumettre la demande. Affiche un état animé "En attente de confirmation par le secrétariat".

---

## 💻 Interface Secrétariat Vue.js (Validation des Demandes)

Dans le tableau de bord de la secrétaire (`SecretaireDashboard.vue`), un sous-onglet ou un badge de notification dynamique signale les demandes entrantes.

- **Composant `PendingRequestsTable.vue`** :
  - Affiche la liste des requêtes : Nom du patient, date souhaitée, plage horaire, motif.
  - **Bouton [Accepter]** : Ouvre une modale rapide liée à l'agenda pour fixer l'heure exacte (ex: 15:30). Dès la validation, le statut passe à "Planifie", s'insère dans la grille principale et envoie une notification push/email de confirmation automatique au patient.
  - **Bouton [Proposer un autre créneau]** : Permet de rejeter la demande actuelle tout en envoyant une alternative horaire au patient.

---

## 🎯 Plan de Vérification des Fonctionnalités
- **Test d'invitation** : Se connecter en tant que Secrétaire -> Créer un patient avec un email test -> Vérifier l'insertion en base avec le rôle Patient.
- **Test d'étanchéité** : Tenter d'accéder à `/api/my/appointments` avec un token de Patient A pour lire les données du Patient B -> Vérifier le retour d'une erreur 403 Forbidden ou un filtrage strict par ID.
- **Test du flux complet (State Machine)** : Soumettre une demande sur le mobile (Statut `EnAttenteValidation`) -> Apparaît sur le Web Secrétaire -> Acceptation -> Vérifier la mise à jour instantanée du statut en `Planifie` sur l'application mobile du patient.
