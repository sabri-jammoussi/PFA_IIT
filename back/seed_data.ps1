$ErrorActionPreference = "Stop"

$baseUrl = "http://localhost:5094/api"

# Helper function to invoke HTTP request and catch output
function Invoke-ApiRequest {
    param (
        [string]$Uri,
        [string]$Method,
        [object]$Body = $null
    )
    
    $headers = @{
        "Content-Type" = "application/json"
        "Accept" = "application/json"
    }
    
    $bodyJson = $null
    if ($Body -ne $null) {
        $bodyJson = $Body | ConvertTo-Json -Depth 10 -Compress
    }
    
    $result = @{
        Success = $false
        StatusCode = 0
        Content = ""
        Error = ""
    }
    
    try {
        if ($bodyJson) {
            $webResponse = Invoke-WebRequest -Uri $Uri -Method $Method -Headers $headers -Body $bodyJson -UseBasicParsing
        } else {
            $webResponse = Invoke-WebRequest -Uri $Uri -Method $Method -Headers $headers -UseBasicParsing
        }
        
        $result.Success = $true
        $result.StatusCode = [int]$webResponse.StatusCode
        $result.Content = $webResponse.Content
    } catch {
        $result.Success = $false
        if ($_.Exception -and $_.Exception.Response) {
            $result.StatusCode = [int]$_.Exception.Response.StatusCode
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $result.Error = $reader.ReadToEnd()
            $reader.Close()
        } else {
            $result.StatusCode = 500
            $result.Error = $_.Exception.Message
        }
    }
    
    return $result
}

Write-Host "Starting database seeding with mock data through Gateway ($baseUrl)..." -ForegroundColor Cyan

# 1. Seed Roles
Write-Host "`nSeeding Roles..." -ForegroundColor Yellow
$rolesToCreate = @(
    @{ Name = "Admin"; Description = "Gestion totale du cabinet dentaire" }
    @{ Name = "Dentiste"; Description = "Praticien effectuant les soins" }
    @{ Name = "Secretaire"; Description = "Accueil, facturation et planification des rendez-vous" }
)

$roleIds = @()
foreach ($role in $rolesToCreate) {
    # Check if role already exists in lists first to prevent duplicate errors if constraint exists
    $res = Invoke-ApiRequest -Uri "$baseUrl/roles" -Method "POST" -Body $role
    if ($res.Success) {
        $id = [int]($res.Content.Trim())
        $roleIds += @{ Name = $role.Name; Id = $id }
        Write-Host "Created Role '$($role.Name)' with ID: $id" -ForegroundColor Green
    } else {
        Write-Host "Could not create Role '$($role.Name)': $($res.Error)" -ForegroundColor Red
    }
}

# Fallback: if roles already existed, get them
if ($roleIds.Count -eq 0) {
    $res = Invoke-ApiRequest -Uri "$baseUrl/roles" -Method "GET"
    if ($res.Success) {
        $existing = $res.Content | ConvertFrom-Json
        $items = if ($existing.items) { $existing.items } else { $existing }
        foreach ($item in $items) {
            $roleIds += @{ Name = $item.Name; Id = $item.Id }
        }
    }
}

# 2. Seed Users (Dentists, Assistants, Admins)
Write-Host "`nSeeding Users..." -ForegroundColor Yellow
$adminRoleId = ($roleIds | Where-Object { $_.Name -eq "Admin" } | Select-Object -First 1).Id
$dentistRoleId = ($roleIds | Where-Object { $_.Name -eq "Dentiste" } | Select-Object -First 1).Id
$secretaireRoleId = ($roleIds | Where-Object { $_.Name -eq "Secretaire" } | Select-Object -First 1).Id

# In case roles are missing or default
if ($null -eq $adminRoleId) { $adminRoleId = $roleIds[0].Id }
if ($null -eq $dentistRoleId) { $dentistRoleId = $roleIds[0].Id }
if ($null -eq $secretaireRoleId) { $secretaireRoleId = $roleIds[0].Id }

$usersToCreate = @(
    @{ Username = "dr_dupont"; Email = "dupont.dentiste@cabinet.com"; Password = "SecurePassword123!"; Nom = "Dupont"; Prenom = "Jean"; RoleId = $dentistRoleId }
    @{ Username = "dr_leclerc"; Email = "leclerc.dentiste@cabinet.com"; Password = "SecurePassword123!"; Nom = "Leclerc"; Prenom = "Sophie"; RoleId = $dentistRoleId }
    @{ Username = "assist_valerie"; Email = "valerie.assist@cabinet.com"; Password = "SecurePassword123!"; Nom = "Martin"; Prenom = "Valerie"; RoleId = $secretaireRoleId }
    @{ Username = "admin_med"; Email = "admin.med@cabinet.com"; Password = "SecurePassword123!"; Nom = "Jammoussi"; Prenom = "Sabri"; RoleId = $adminRoleId }
)

$userIds = @()
$dentistIds = @()
foreach ($user in $usersToCreate) {
    $res = Invoke-ApiRequest -Uri "$baseUrl/users" -Method "POST" -Body $user
    if ($res.Success) {
        $id = [int]($res.Content.Trim())
        $userIds += $id
        if ($user.RoleId -eq $dentistRoleId) {
            $dentistIds += $id
        }
        Write-Host "Created User '$($user.Username)' with ID: $id" -ForegroundColor Green
    } else {
        Write-Host "Could not create User '$($user.Username)': $($res.Error)" -ForegroundColor Red
    }
}

# Fallback: if users already existed, fetch them
if ($userIds.Count -eq 0) {
    $res = Invoke-ApiRequest -Uri "$baseUrl/users" -Method "GET"
    if ($res.Success) {
        $existing = $res.Content | ConvertFrom-Json
        $items = if ($existing.items) { $existing.items } else { $existing }
        foreach ($item in $items) {
            $userIds += $item.Id
            # We assume users with roleId = dentistRoleId are dentists
            if ($item.RoleId -eq $dentistRoleId) {
                $dentistIds += $item.Id
            }
        }
    }
}

if ($dentistIds.Count -eq 0 -and $userIds.Count -gt 0) {
    $dentistIds += $userIds[0]
}

# 3. Seed Patients
Write-Host "`nSeeding Patients..." -ForegroundColor Yellow
$patientsToCreate = @(
    @{ Nom = "Ben Ali"; Prenom = "Mohamed"; DateNaissance = "1985-04-12T00:00:00Z"; Telephone = "0611223344"; Email = "m.benali@gmail.com"; Adresse = "Tunis, Centre Ville"; AntecedentsMedicaux = "Hypertension"; GroupSanguin = "A+" }
    @{ Nom = "Trabelsi"; Prenom = "Fatma"; DateNaissance = "1990-11-23T00:00:00Z"; Telephone = "0655667788"; Email = "fatma.trabelsi@yahoo.fr"; Adresse = "Ariana, Ennasr"; AntecedentsMedicaux = "Allergie Penicilline"; GroupSanguin = "O+" }
    @{ Nom = "Gharbi"; Prenom = "Ali"; DateNaissance = "1978-08-05T00:00:00Z"; Telephone = "0699001122"; Email = "ali.gharbi@outlook.com"; Adresse = "La Marsa"; AntecedentsMedicaux = "Diabete"; GroupSanguin = "B-" }
    @{ Nom = "Chaabane"; Prenom = "Youssef"; DateNaissance = "2002-02-14T00:00:00Z"; Telephone = "0644332211"; Email = "youssef.chaabane@gmail.com"; Adresse = "Sfax, Route de Teniour"; AntecedentsMedicaux = "Aucun"; GroupSanguin = "AB+" }
    @{ Nom = "Mahmoudi"; Prenom = "Salma"; DateNaissance = "1997-06-30T00:00:00Z"; Telephone = "0688776655"; Email = "salma.mahmoudi@live.com"; Adresse = "Sousse, Khezama"; AntecedentsMedicaux = "Asthme"; GroupSanguin = "O-" }
)

$patientIds = @()
foreach ($patient in $patientsToCreate) {
    $res = Invoke-ApiRequest -Uri "$baseUrl/patients" -Method "POST" -Body $patient
    if ($res.Success) {
        $id = [int]($res.Content.Trim())
        $patientIds += $id
        Write-Host "Created Patient '$($patient.Prenom) $($patient.Nom)' with ID: $id" -ForegroundColor Green
    } else {
        Write-Host "Could not create Patient '$($patient.Nom)': $($res.Error)" -ForegroundColor Red
    }
}

if ($patientIds.Count -eq 0) {
    $res = Invoke-ApiRequest -Uri "$baseUrl/patients" -Method "GET"
    if ($res.Success) {
        $existing = $res.Content | ConvertFrom-Json
        $items = if ($existing.items) { $existing.items } else { $existing }
        foreach ($item in $items) {
            $patientIds += $item.Id
        }
    }
}

# 4. Seed Actes Médicaux
Write-Host "`nSeeding Actes Medicaux..." -ForegroundColor Yellow
$actesToCreate = @(
    @{ Libelle = "Consultation Standard"; TarifDeBase = [decimal]40.00; CodeNomenclature = "CS" }
    @{ Libelle = "Detartrage Complet"; TarifDeBase = [decimal]70.00; CodeNomenclature = "DT" }
    @{ Libelle = "Extraction Simple"; TarifDeBase = [decimal]90.00; CodeNomenclature = "EX" }
    @{ Libelle = "Composite 3 Faces"; TarifDeBase = [decimal]80.00; CodeNomenclature = "CO" }
    @{ Libelle = "Couronne Ceramique"; TarifDeBase = [decimal]450.00; CodeNomenclature = "CC" }
)

$acteIds = @()
foreach ($acte in $actesToCreate) {
    $res = Invoke-ApiRequest -Uri "$baseUrl/actes-medicaux" -Method "POST" -Body $acte
    if ($res.Success) {
        $id = [int]($res.Content.Trim())
        $acteIds += $id
        Write-Host "Created Acte Medical '$($acte.Libelle)' with ID: $id" -ForegroundColor Green
    } else {
        Write-Host "Could not create Acte Medical '$($acte.Libelle)': $($res.Error)" -ForegroundColor Red
    }
}

if ($acteIds.Count -eq 0) {
    $res = Invoke-ApiRequest -Uri "$baseUrl/actes-medicaux" -Method "GET"
    if ($res.Success) {
        $existing = $res.Content | ConvertFrom-Json
        $items = if ($existing.items) { $existing.items } else { $existing }
        foreach ($item in $items) {
            $acteIds += $item.Id
        }
    }
}

# 5. Seed Rendez-Vous
Write-Host "`nSeeding Rendez-Vous..." -ForegroundColor Yellow
if ($patientIds.Count -gt 0 -and $dentistIds.Count -gt 0) {
    $rdvsToCreate = @(
        @{ DateHeure = "2026-06-08T09:00:00Z"; DureeEstimee = "00:30:00"; Statut = "Confirme"; Motif = "Detartrage annuel"; Note = "Patient ponctuel"; PatientId = $patientIds[0]; DentisteId = $dentistIds[0] }
        @{ DateHeure = "2026-06-08T10:00:00Z"; DureeEstimee = "00:45:00"; Statut = "Planifie"; Motif = "Douleur molaire gauche"; Note = "Urgences possibles"; PatientId = $patientIds[1]; DentisteId = $dentistIds[0] }
        @{ DateHeure = "2026-06-09T14:30:00Z"; DureeEstimee = "01:00:00"; Statut = "Planifie"; Motif = "Pose de couronne"; Note = "Devis deja signe"; PatientId = $patientIds[2]; DentisteId = if ($dentistIds.Count -gt 1) { $dentistIds[1] } else { $dentistIds[0] } }
        @{ DateHeure = "2026-06-10T11:00:00Z"; DureeEstimee = "00:30:00"; Statut = "Confirme"; Motif = "Visite de contrôle"; Note = "Suite extraction"; PatientId = $patientIds[3]; DentisteId = $dentistIds[0] }
    )

    foreach ($rdv in $rdvsToCreate) {
        $res = Invoke-ApiRequest -Uri "$baseUrl/rendezvous" -Method "POST" -Body $rdv
        if ($res.Success) {
            $id = [int]($res.Content.Trim())
            Write-Host "Created Rendez-Vous on $($rdv.DateHeure) with ID: $id" -ForegroundColor Green
        } else {
            Write-Host "Could not create Rendez-Vous: $($res.Error)" -ForegroundColor Red
        }
    }
}

# 6. Seed Consultations & dependent Soins / Ordonnances
Write-Host "`nSeeding Consultations, Soins and Ordonnances..." -ForegroundColor Yellow
if ($patientIds.Count -gt 0 -and $dentistIds.Count -gt 0 -and $acteIds.Count -gt 0) {
    # Consultation 1 for Patient 0
    $cons1 = @{
        DateConsultation = "2026-06-07T09:30:00Z"
        NotesObservations = "Patient venu pour detartrage standard. Tres bon etat général."
        PatientId = $patientIds[0]
        DentisteId = $dentistIds[0]
    }
    $res1 = Invoke-ApiRequest -Uri "$baseUrl/consultations" -Method "POST" -Body $cons1
    if ($res1.Success) {
        $c1Id = [int]($res1.Content.Trim())
        Write-Host "Created Consultation 1 with ID: $c1Id" -ForegroundColor Green
        
        # Add Soin Effectue (Detartrage)
        $soin1 = @{
            NumeroDent = $null
            FaceDentaire = $null
            PrixApplique = [decimal]70.00
            Notes = "Detartrage complet haut et bas"
            ConsultationId = $c1Id
            ActeMedicalId = $acteIds[1] # Detartrage
        }
        $resS = Invoke-ApiRequest -Uri "$baseUrl/soins-effectues" -Method "POST" -Body $soin1
        if ($resS.Success) { Write-Host "  -> Added Soin (Detartrage) ID: $($resS.Content.Trim())" -ForegroundColor Green }
        
        # Add Ordonnance
        $ord1 = @{
            DateEmission = "2026-06-07T00:00:00Z"
            Traitement = "Bain de bouche antiseptique - 2 fois par jour pendant 5 jours"
            ConsultationId = $c1Id
        }
        $resO = Invoke-ApiRequest -Uri "$baseUrl/ordonnances" -Method "POST" -Body $ord1
        if ($resO.Success) { Write-Host "  -> Added Ordonnance ID: $($resO.Content.Trim())" -ForegroundColor Green }
    }
    
    # Consultation 2 for Patient 1
    $cons2 = @{
        DateConsultation = "2026-06-07T11:00:00Z"
        NotesObservations = "Grave carie sur la molaire 16. Extraction simple recommandee."
        PatientId = $patientIds[1]
        DentisteId = $dentistIds[0]
    }
    $res2 = Invoke-ApiRequest -Uri "$baseUrl/consultations" -Method "POST" -Body $cons2
    if ($res2.Success) {
        $c2Id = [int]($res2.Content.Trim())
        Write-Host "Created Consultation 2 with ID: $c2Id" -ForegroundColor Green
        
        # Add Soin Effectue (Extraction)
        $soin2 = @{
            NumeroDent = 16
            FaceDentaire = "O"
            PrixApplique = [decimal]90.00
            Notes = "Extraction de la molaire 16 infectee"
            ConsultationId = $c2Id
            ActeMedicalId = $acteIds[2] # Extraction
        }
        $resS = Invoke-ApiRequest -Uri "$baseUrl/soins-effectues" -Method "POST" -Body $soin2
        if ($resS.Success) { Write-Host "  -> Added Soin (Extraction) ID: $($resS.Content.Trim())" -ForegroundColor Green }
        
        # Add Ordonnance
        $ord2 = @{
            DateEmission = "2026-06-07T00:00:00Z"
            Traitement = "Amoxicilline 1g (2x/jour pendant 6 jours) + Paracetamol 1g en cas de douleurs"
            ConsultationId = $c2Id
        }
        $resO = Invoke-ApiRequest -Uri "$baseUrl/ordonnances" -Method "POST" -Body $ord2
        if ($resO.Success) { Write-Host "  -> Added Ordonnance ID: $($resO.Content.Trim())" -ForegroundColor Green }
    }
}

# 7. Seed Factures & Paiements
Write-Host "`nSeeding Factures and Paiements..." -ForegroundColor Yellow
if ($patientIds.Count -gt 0) {
    # Facture 1 for Patient 0
    $fac1 = @{
        NumeroFacture = "F-" + (Get-Date -Format "yyMMdd") + "-01"
        DateEmission = "2026-06-07T00:00:00Z"
        MontantTotal = [decimal]70.00
        MontantPaye = [decimal]0.00
        StatutPaiement = "NonPaye"
        PatientId = $patientIds[0]
    }
    $resF1 = Invoke-ApiRequest -Uri "$baseUrl/factures" -Method "POST" -Body $fac1
    if ($resF1.Success) {
        $f1Id = [int]($resF1.Content.Trim())
        Write-Host "Created Facture 1 (ID: $f1Id) of 70.00 DT" -ForegroundColor Green
        
        # Add Payment of 70.00 DT (Full payment)
        $pay1 = @{
            DatePaiement = "2026-06-07T12:00:00Z"
            Montant = [decimal]70.00
            ModePaiement = "CarteBancaire"
            FactureId = $f1Id
        }
        $resP1 = Invoke-ApiRequest -Uri "$baseUrl/paiements" -Method "POST" -Body $pay1
        if ($resP1.Success) {
            Write-Host "  -> Added Full Payment (ID: $($resP1.Content.Trim())) of 70.00 DT" -ForegroundColor Green
        }
    }
    
    # Facture 2 for Patient 1
    $fac2 = @{
        NumeroFacture = "F-" + (Get-Date -Format "yyMMdd") + "-02"
        DateEmission = "2026-06-07T00:00:00Z"
        MontantTotal = [decimal]150.00
        MontantPaye = [decimal]0.00
        StatutPaiement = "NonPaye"
        PatientId = $patientIds[1]
    }
    $resF2 = Invoke-ApiRequest -Uri "$baseUrl/factures" -Method "POST" -Body $fac2
    if ($resF2.Success) {
        $f2Id = [int]($resF2.Content.Trim())
        Write-Host "Created Facture 2 (ID: $f2Id) of 150.00 DT" -ForegroundColor Green
        
        # Add Payment of 50.00 DT (Partial payment)
        $pay2 = @{
            DatePaiement = "2026-06-07T13:00:00Z"
            Montant = [decimal]50.00
            ModePaiement = "Especes"
            FactureId = $f2Id
        }
        $resP2 = Invoke-ApiRequest -Uri "$baseUrl/paiements" -Method "POST" -Body $pay2
        if ($resP2.Success) {
            Write-Host "  -> Added Partial Payment (ID: $($resP2.Content.Trim())) of 50.00 DT" -ForegroundColor Green
        }
    }
}

Write-Host "`n==============================================================================" -ForegroundColor Cyan
Write-Host "DATABASE MOCK DATA SEEDING COMPLETE!" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
