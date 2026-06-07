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

$testResults = [System.Collections.Generic.List[PSCustomObject]]::new()

function Log-Test {
    param (
        [string]$Controller,
        [string]$Operation,
        [string]$Method,
        [string]$Url,
        [object]$RequestData,
        [object]$ResponseResult
    )
    
    $status = if ($ResponseResult.Success) { "PASSED" } else { "FAILED" }
    
    $logObj = [PSCustomObject]@{
        Controller  = $Controller
        Operation   = $Operation
        Method      = $Method
        Url         = $Url
        Status      = $status
        StatusCode  = $ResponseResult.StatusCode
        Response    = if ($ResponseResult.Success) { $ResponseResult.Content } else { $ResponseResult.Error }
    }
    
    $testResults.Add($logObj)
    
    $color = if ($ResponseResult.Success) { "Green" } else { "Red" }
    Write-Host "[$status] $Method $Url - Status: $($ResponseResult.StatusCode)" -ForegroundColor $color
    if (-not $ResponseResult.Success) {
        Write-Host "      Error: $($ResponseResult.Error)" -ForegroundColor Yellow
    }
}

# --- Entity IDs ---
$roleId = 0
$userId = 0
$patientId = 0
$acteMedicalId = 0
$rendezVousId = 0
$consultationId = 0
$soinEffectueId = 0
$ordonnanceId = 0
$factureId = 0
$paiementId = 0

Write-Host "Starting API endpoint integration tests through gateway at $baseUrl..." -ForegroundColor Cyan

# ==============================================================================
# 1. ROLES CONTROLLER
# ==============================================================================
Write-Host "`n--- Testing Roles ---" -ForegroundColor Blue

# POST Role
$roleBody = @{
    Name = "R_" + (Get-Date -Format "mmHHss")
    Description = "Role cree pour test integration"
}
$res = Invoke-ApiRequest -Uri "$baseUrl/roles" -Method "POST" -Body $roleBody
Log-Test -Controller "Roles" -Operation "POST (Create)" -Method "POST" -Url "$baseUrl/roles" -RequestData $roleBody -ResponseResult $res
if ($res.Success) {
    $roleId = [int]($res.Content.Trim())
    Write-Host "Created Role ID: $roleId" -ForegroundColor DarkGreen
}

# GET All Roles
if ($roleId -gt 0) {
    $res = Invoke-ApiRequest -Uri "$baseUrl/roles" -Method "GET"
    Log-Test -Controller "Roles" -Operation "GET All" -Method "GET" -Url "$baseUrl/roles" -ResponseResult $res

    # GET Role By ID
    $res = Invoke-ApiRequest -Uri "$baseUrl/roles/$roleId" -Method "GET"
    Log-Test -Controller "Roles" -Operation "GET By ID" -Method "GET" -Url "$baseUrl/roles/$roleId" -ResponseResult $res

    # PUT Role (Update)
    $roleUpdateBody = @{
        Id = $roleId
        Name = $roleBody.Name + " Modifie"
        Description = "Role modifie pour test"
    }
    $res = Invoke-ApiRequest -Uri "$baseUrl/roles/$roleId" -Method "PUT" -Body $roleUpdateBody
    Log-Test -Controller "Roles" -Operation "PUT (Update)" -Method "PUT" -Url "$baseUrl/roles/$roleId" -RequestData $roleUpdateBody -ResponseResult $res
}

# ==============================================================================
# 2. USERS CONTROLLER
# ==============================================================================
if ($roleId -gt 0) {
    Write-Host "`n--- Testing Users ---" -ForegroundColor Blue
    
    # POST User
    $userBody = @{
        Username = "u_" + (Get-Date -Format "mmHHss")
        Email = "u" + (Get-Date -Format "mmHHss") + "@t.com"
        Password = "StrongPassword123!"
        Nom = "TestNom"
        Prenom = "TestPrenom"
        RoleId = $roleId
    }
    $res = Invoke-ApiRequest -Uri "$baseUrl/users" -Method "POST" -Body $userBody
    Log-Test -Controller "Users" -Operation "POST (Create)" -Method "POST" -Url "$baseUrl/users" -RequestData $userBody -ResponseResult $res
    if ($res.Success) {
        $userId = [int]($res.Content.Trim())
        Write-Host "Created User ID: $userId" -ForegroundColor DarkGreen
    }
    
    # GET All Users
    if ($userId -gt 0) {
        $res = Invoke-ApiRequest -Uri "$baseUrl/users" -Method "GET"
        Log-Test -Controller "Users" -Operation "GET All" -Method "GET" -Url "$baseUrl/users" -ResponseResult $res
        
        # GET User By ID
        $res = Invoke-ApiRequest -Uri "$baseUrl/users/$userId" -Method "GET"
        Log-Test -Controller "Users" -Operation "GET By ID" -Method "GET" -Url "$baseUrl/users/$userId" -ResponseResult $res
        
        # PUT User (Update)
        $userUpdateBody = @{
            Id = $userId
            Username = $userBody.Username + "_mod"
            Email = $userBody.Email
            Nom = "TestNomModifie"
            Prenom = "TestPrenom"
            IsActive = $true
            RoleId = $roleId
        }
        $res = Invoke-ApiRequest -Uri "$baseUrl/users/$userId" -Method "PUT" -Body $userUpdateBody
        Log-Test -Controller "Users" -Operation "PUT (Update)" -Method "PUT" -Url "$baseUrl/users/$userId" -RequestData $userUpdateBody -ResponseResult $res
    }
}

# ==============================================================================
# 3. PATIENTS CONTROLLER
# ==============================================================================
Write-Host "`n--- Testing Patients ---" -ForegroundColor Blue

# POST Patient
$patientBody = @{
    Nom = "PatientTest"
    Prenom = "Jane"
    DateNaissance = "1995-10-24T00:00:00Z"
    Telephone = "0612345678"
    Email = "jane.test@example.com"
    Adresse = "456 Rue de Test"
    AntecedentsMedicaux = "Aucun"
    GroupSanguin = "O+"
}
$res = Invoke-ApiRequest -Uri "$baseUrl/patients" -Method "POST" -Body $patientBody
Log-Test -Controller "Patients" -Operation "POST (Create)" -Method "POST" -Url "$baseUrl/patients" -RequestData $patientBody -ResponseResult $res
if ($res.Success) {
    $patientId = [int]($res.Content.Trim())
    Write-Host "Created Patient ID: $patientId" -ForegroundColor DarkGreen
}

# GET All Patients
if ($patientId -gt 0) {
    $res = Invoke-ApiRequest -Uri "$baseUrl/patients" -Method "GET"
    Log-Test -Controller "Patients" -Operation "GET All" -Method "GET" -Url "$baseUrl/patients" -ResponseResult $res
    
    # GET Patient By ID
    $res = Invoke-ApiRequest -Uri "$baseUrl/patients/$patientId" -Method "GET"
    Log-Test -Controller "Patients" -Operation "GET By ID" -Method "GET" -Url "$baseUrl/patients/$patientId" -ResponseResult $res
    
    # PUT Patient (Update)
    $patientUpdateBody = @{
        Id = $patientId
        Nom = "PatientTestMod"
        Prenom = "Jane"
        DateNaissance = "1995-10-24T00:00:00Z"
        Telephone = "0699999999"
        Email = "jane.test.mod@example.com"
        Adresse = "456 Rue de Test Modifie"
        AntecedentsMedicaux = "Allergie Penicilline"
        GroupSanguin = "O+"
    }
    $res = Invoke-ApiRequest -Uri "$baseUrl/patients/$patientId" -Method "PUT" -Body $patientUpdateBody
    Log-Test -Controller "Patients" -Operation "PUT (Update)" -Method "PUT" -Url "$baseUrl/patients/$patientId" -RequestData $patientUpdateBody -ResponseResult $res
}

# ==============================================================================
# 4. ACTES MEDICAUX CONTROLLER
# ==============================================================================
Write-Host "`n--- Testing Actes Medicaux ---" -ForegroundColor Blue

# POST Acte Medical
$acteBody = @{
    Libelle = "Detartrage Test " + (Get-Date -Format "yyyyMMdd")
    TarifDeBase = [decimal]45.50
    CodeNomenclature = "DT-TEST"
}
$res = Invoke-ApiRequest -Uri "$baseUrl/actes-medicaux" -Method "POST" -Body $acteBody
Log-Test -Controller "ActesMedicaux" -Operation "POST (Create)" -Method "POST" -Url "$baseUrl/actes-medicaux" -RequestData $acteBody -ResponseResult $res
if ($res.Success) {
    $acteMedicalId = [int]($res.Content.Trim())
    Write-Host "Created Acte Medical ID: $acteMedicalId" -ForegroundColor DarkGreen
}

# GET All Actes Medicaux
if ($acteMedicalId -gt 0) {
    $res = Invoke-ApiRequest -Uri "$baseUrl/actes-medicaux" -Method "GET"
    Log-Test -Controller "ActesMedicaux" -Operation "GET All" -Method "GET" -Url "$baseUrl/actes-medicaux" -ResponseResult $res
    
    # GET Acte By ID
    $res = Invoke-ApiRequest -Uri "$baseUrl/actes-medicaux/$acteMedicalId" -Method "GET"
    Log-Test -Controller "ActesMedicaux" -Operation "GET By ID" -Method "GET" -Url "$baseUrl/actes-medicaux/$acteMedicalId" -ResponseResult $res
    
    # PUT Acte (Update)
    $acteUpdateBody = @{
        Id = $acteMedicalId
        Libelle = $acteBody.Libelle + " Modifie"
        TarifDeBase = [decimal]50.00
        CodeNomenclature = "DT-TEST-M"
    }
    $res = Invoke-ApiRequest -Uri "$baseUrl/actes-medicaux/$acteMedicalId" -Method "PUT" -Body $acteUpdateBody
    Log-Test -Controller "ActesMedicaux" -Operation "PUT (Update)" -Method "PUT" -Url "$baseUrl/actes-medicaux/$acteMedicalId" -RequestData $acteUpdateBody -ResponseResult $res
}

# ==============================================================================
# 5. RENDEZ-VOUS CONTROLLER
# ==============================================================================
if ($patientId -gt 0 -and $userId -gt 0) {
    Write-Host "`n--- Testing Rendez-Vous ---" -ForegroundColor Blue
    
    # POST Rendez-Vous
    $rdvBody = @{
        DateHeure = "2026-06-15T09:00:00Z"
        DureeEstimee = "00:45:00"
        Statut = "Planifie"
        Motif = "Visite de routine"
        Note = "Patient regulier"
        PatientId = $patientId
        DentisteId = $userId
    }
    $res = Invoke-ApiRequest -Uri "$baseUrl/rendezvous" -Method "POST" -Body $rdvBody
    Log-Test -Controller "RendezVous" -Operation "POST (Create)" -Method "POST" -Url "$baseUrl/rendezvous" -RequestData $rdvBody -ResponseResult $res
    if ($res.Success) {
        $rendezVousId = [int]($res.Content.Trim())
        Write-Host "Created RendezVous ID: $rendezVousId" -ForegroundColor DarkGreen
    }
    
    # GET All Rendez-Vous
    if ($rendezVousId -gt 0) {
        $res = Invoke-ApiRequest -Uri "$baseUrl/rendezvous" -Method "GET"
        Log-Test -Controller "RendezVous" -Operation "GET All" -Method "GET" -Url "$baseUrl/rendezvous" -ResponseResult $res
        
        # GET Rendez-Vous By ID
        $res = Invoke-ApiRequest -Uri "$baseUrl/rendezvous/$rendezVousId" -Method "GET"
        Log-Test -Controller "RendezVous" -Operation "GET By ID" -Method "GET" -Url "$baseUrl/rendezvous/$rendezVousId" -ResponseResult $res
        
        # PUT Rendez-Vous (Update)
        $rdvUpdateBody = @{
            Id = $rendezVousId
            DateHeure = "2026-06-15T10:00:00Z"
            DureeEstimee = "01:00:00"
            Statut = "Confirme"
            Motif = "Soin urgence"
            Note = "Duree prolongee"
            PatientId = $patientId
            DentisteId = $userId
        }
        $res = Invoke-ApiRequest -Uri "$baseUrl/rendezvous/$rendezVousId" -Method "PUT" -Body $rdvUpdateBody
        Log-Test -Controller "RendezVous" -Operation "PUT (Update)" -Method "PUT" -Url "$baseUrl/rendezvous/$rendezVousId" -RequestData $rdvUpdateBody -ResponseResult $res
    }
}

# ==============================================================================
# 6. CONSULTATIONS CONTROLLER
# ==============================================================================
if ($patientId -gt 0 -and $userId -gt 0) {
    Write-Host "`n--- Testing Consultations ---" -ForegroundColor Blue
    
    # POST Consultation
    $consBody = @{
        DateConsultation = "2026-06-07T10:00:00Z"
        NotesObservations = "Consultation de diagnostic initiale"
        PatientId = $patientId
        DentisteId = $userId
    }
    $res = Invoke-ApiRequest -Uri "$baseUrl/consultations" -Method "POST" -Body $consBody
    Log-Test -Controller "Consultations" -Operation "POST (Create)" -Method "POST" -Url "$baseUrl/consultations" -RequestData $consBody -ResponseResult $res
    if ($res.Success) {
        $consultationId = [int]($res.Content.Trim())
        Write-Host "Created Consultation ID: $consultationId" -ForegroundColor DarkGreen
    }
    
    # GET All Consultations
    if ($consultationId -gt 0) {
        $res = Invoke-ApiRequest -Uri "$baseUrl/consultations" -Method "GET"
        Log-Test -Controller "Consultations" -Operation "GET All" -Method "GET" -Url "$baseUrl/consultations" -ResponseResult $res
        
        # GET Consultation By ID
        $res = Invoke-ApiRequest -Uri "$baseUrl/consultations/$consultationId" -Method "GET"
        Log-Test -Controller "Consultations" -Operation "GET By ID" -Method "GET" -Url "$baseUrl/consultations/$consultationId" -ResponseResult $res
        
        # PUT Consultation (Update)
        $consUpdateBody = @{
            Id = $consultationId
            DateConsultation = "2026-06-07T10:30:00Z"
            NotesObservations = "Consultation de diagnostic initiale - Detartrage necessaire"
            PatientId = $patientId
            DentisteId = $userId
        }
        $res = Invoke-ApiRequest -Uri "$baseUrl/consultations/$consultationId" -Method "PUT" -Body $consUpdateBody
        Log-Test -Controller "Consultations" -Operation "PUT (Update)" -Method "PUT" -Url "$baseUrl/consultations/$consultationId" -RequestData $consUpdateBody -ResponseResult $res
    }
}

# ==============================================================================
# 7. SOINS EFFECTUES CONTROLLER
# ==============================================================================
if ($consultationId -gt 0 -and $acteMedicalId -gt 0) {
    Write-Host "`n--- Testing Soins Effectues ---" -ForegroundColor Blue
    
    # POST Soin Effectue
    $soinBody = @{
        NumeroDent = 12
        FaceDentaire = "V"
        PrixApplique = [decimal]45.50
        Notes = "Nettoyage standard"
        ConsultationId = $consultationId
        ActeMedicalId = $acteMedicalId
    }
    $res = Invoke-ApiRequest -Uri "$baseUrl/soins-effectues" -Method "POST" -Body $soinBody
    Log-Test -Controller "SoinsEffectues" -Operation "POST (Create)" -Method "POST" -Url "$baseUrl/soins-effectues" -RequestData $soinBody -ResponseResult $res
    if ($res.Success) {
        $soinEffectueId = [int]($res.Content.Trim())
        Write-Host "Created Soin Effectue ID: $soinEffectueId" -ForegroundColor DarkGreen
    }
    
    # GET All Soins Effectues
    if ($soinEffectueId -gt 0) {
        $res = Invoke-ApiRequest -Uri "$baseUrl/soins-effectues" -Method "GET"
        Log-Test -Controller "SoinsEffectues" -Operation "GET All" -Method "GET" -Url "$baseUrl/soins-effectues" -ResponseResult $res
        
        # GET Soin Effectue By ID
        $res = Invoke-ApiRequest -Uri "$baseUrl/soins-effectues/$soinEffectueId" -Method "GET"
        Log-Test -Controller "SoinsEffectues" -Operation "GET By ID" -Method "GET" -Url "$baseUrl/soins-effectues/$soinEffectueId" -ResponseResult $res
        
        # PUT Soin Effectue (Update)
        $soinUpdateBody = @{
            Id = $soinEffectueId
            NumeroDent = 13
            FaceDentaire = "P"
            PrixApplique = [decimal]50.00
            Notes = "Nettoyage standard approfondi"
            ConsultationId = $consultationId
            ActeMedicalId = $acteMedicalId
        }
        $res = Invoke-ApiRequest -Uri "$baseUrl/soins-effectues/$soinEffectueId" -Method "PUT" -Body $soinUpdateBody
        Log-Test -Controller "SoinsEffectues" -Operation "PUT (Update)" -Method "PUT" -Url "$baseUrl/soins-effectues/$soinEffectueId" -RequestData $soinUpdateBody -ResponseResult $res
    }
}

# ==============================================================================
# 8. ORDONNANCES CONTROLLER
# ==============================================================================
if ($consultationId -gt 0) {
    Write-Host "`n--- Testing Ordonnances ---" -ForegroundColor Blue
    
    # POST Ordonnance
    $ordBody = @{
        DateEmission = "2026-06-07T00:00:00Z"
        Traitement = "Antibiotique 500mg - 2 fois par jour"
        ConsultationId = $consultationId
    }
    $res = Invoke-ApiRequest -Uri "$baseUrl/ordonnances" -Method "POST" -Body $ordBody
    Log-Test -Controller "Ordonnances" -Operation "POST (Create)" -Method "POST" -Url "$baseUrl/ordonnances" -RequestData $ordBody -ResponseResult $res
    if ($res.Success) {
        $ordonnanceId = [int]($res.Content.Trim())
        Write-Host "Created Ordonnance ID: $ordonnanceId" -ForegroundColor DarkGreen
    }
    
    # GET All Ordonnances
    if ($ordonnanceId -gt 0) {
        $res = Invoke-ApiRequest -Uri "$baseUrl/ordonnances" -Method "GET"
        Log-Test -Controller "Ordonnances" -Operation "GET All" -Method "GET" -Url "$baseUrl/ordonnances" -ResponseResult $res
        
        # GET Ordonnance By ID
        $res = Invoke-ApiRequest -Uri "$baseUrl/ordonnances/$ordonnanceId" -Method "GET"
        Log-Test -Controller "Ordonnances" -Operation "GET By ID" -Method "GET" -Url "$baseUrl/ordonnances/$ordonnanceId" -ResponseResult $res
        
        # PUT Ordonnance (Update)
        $ordUpdateBody = @{
            Id = $ordonnanceId
            DateEmission = "2026-06-07T00:00:00Z"
            Traitement = "Antibiotique 500mg - 2 fois par jour + Paracetamol 1g si douleurs"
            ConsultationId = $consultationId
        }
        $res = Invoke-ApiRequest -Uri "$baseUrl/ordonnances/$ordonnanceId" -Method "PUT" -Body $ordUpdateBody
        Log-Test -Controller "Ordonnances" -Operation "PUT (Update)" -Method "PUT" -Url "$baseUrl/ordonnances/$ordonnanceId" -RequestData $ordUpdateBody -ResponseResult $res
    }
}

# ==============================================================================
# 9. FACTURES CONTROLLER
# ==============================================================================
if ($patientId -gt 0) {
    Write-Host "`n--- Testing Factures ---" -ForegroundColor Blue
    
    # POST Facture
    $factureBody = @{
        NumeroFacture = "F-" + (Get-Date -Format "mmHHss")
        DateEmission = "2026-06-07T00:00:00Z"
        MontantTotal = [decimal]150.00
        MontantPaye = [decimal]0.00
        StatutPaiement = "NonPaye"
        PatientId = $patientId
    }
    $res = Invoke-ApiRequest -Uri "$baseUrl/factures" -Method "POST" -Body $factureBody
    Log-Test -Controller "Factures" -Operation "POST (Create)" -Method "POST" -Url "$baseUrl/factures" -RequestData $factureBody -ResponseResult $res
    if ($res.Success) {
        $factureId = [int]($res.Content.Trim())
        Write-Host "Created Facture ID: $factureId" -ForegroundColor DarkGreen
    }
    
    # GET All Factures
    if ($factureId -gt 0) {
        $res = Invoke-ApiRequest -Uri "$baseUrl/factures" -Method "GET"
        Log-Test -Controller "Factures" -Operation "GET All" -Method "GET" -Url "$baseUrl/factures" -ResponseResult $res
        
        # GET Facture By ID
        $res = Invoke-ApiRequest -Uri "$baseUrl/factures/$factureId" -Method "GET"
        Log-Test -Controller "Factures" -Operation "GET By ID" -Method "GET" -Url "$baseUrl/factures/$factureId" -ResponseResult $res
        
        # PUT Facture (Update)
        $factureUpdateBody = @{
            Id = $factureId
            NumeroFacture = $factureBody.NumeroFacture + "-REV"
            DateEmission = "2026-06-07T00:00:00Z"
            MontantTotal = [decimal]200.00
            MontantPaye = [decimal]0.00
            StatutPaiement = "NonPaye"
            PatientId = $patientId
        }
        $res = Invoke-ApiRequest -Uri "$baseUrl/factures/$factureId" -Method "PUT" -Body $factureUpdateBody
        Log-Test -Controller "Factures" -Operation "PUT (Update)" -Method "PUT" -Url "$baseUrl/factures/$factureId" -RequestData $factureUpdateBody -ResponseResult $res
    }
}

# ==============================================================================
# 10. PAIEMENTS CONTROLLER
# ==============================================================================
if ($factureId -gt 0) {
    Write-Host "`n--- Testing Paiements ---" -ForegroundColor Blue
    
    # POST Paiement
    $payBody = @{
        DatePaiement = "2026-06-07T11:00:00Z"
        Montant = [decimal]80.00
        ModePaiement = "Especes"
        FactureId = $factureId
    }
    $res = Invoke-ApiRequest -Uri "$baseUrl/paiements" -Method "POST" -Body $payBody
    Log-Test -Controller "Paiements" -Operation "POST (Create)" -Method "POST" -Url "$baseUrl/paiements" -RequestData $payBody -ResponseResult $res
    if ($res.Success) {
        $paiementId = [int]($res.Content.Trim())
        Write-Host "Created Paiement ID: $paiementId" -ForegroundColor DarkGreen
    }
    
    # GET All Paiements
    if ($paiementId -gt 0) {
        $res = Invoke-ApiRequest -Uri "$baseUrl/paiements" -Method "GET"
        Log-Test -Controller "Paiements" -Operation "GET All" -Method "GET" -Url "$baseUrl/paiements" -ResponseResult $res
        
        # GET Paiement By ID
        $res = Invoke-ApiRequest -Uri "$baseUrl/paiements/$paiementId" -Method "GET"
        Log-Test -Controller "Paiements" -Operation "GET By ID" -Method "GET" -Url "$baseUrl/paiements/$paiementId" -ResponseResult $res
        
        # PUT Paiement (Update)
        $payUpdateBody = @{
            Id = $paiementId
            DatePaiement = "2026-06-07T11:30:00Z"
            Montant = [decimal]100.00
            ModePaiement = "Cheque"
            FactureId = $factureId
        }
        $res = Invoke-ApiRequest -Uri "$baseUrl/paiements/$paiementId" -Method "PUT" -Body $payUpdateBody
        Log-Test -Controller "Paiements" -Operation "PUT (Update)" -Method "PUT" -Url "$baseUrl/paiements/$paiementId" -RequestData $payUpdateBody -ResponseResult $res
    }
}

# ==============================================================================
# 11. AUDIT LOGS CONTROLLER
# ==============================================================================
Write-Host "`n--- Testing Audit Logs ---" -ForegroundColor Blue

# GET All Audit Logs
$res = Invoke-ApiRequest -Uri "$baseUrl/audit-logs" -Method "GET"
Log-Test -Controller "AuditLogs" -Operation "GET All" -Method "GET" -Url "$baseUrl/audit-logs" -ResponseResult $res

if ($res.Success) {
    # Try to extract an ID from the logs to test GET by ID
    try {
        $logs = $res.Content | ConvertFrom-Json
        $firstLog = $null
        if ($logs.items -and $logs.items.Count -gt 0) {
            $firstLog = $logs.items[0]
        } elseif ($logs.Count -gt 0) {
            $firstLog = $logs[0]
        }
        
        if ($firstLog -ne $null -and $firstLog.Id) {
            $logId = $firstLog.Id
            $resLog = Invoke-ApiRequest -Uri "$baseUrl/audit-logs/$logId" -Method "GET"
            Log-Test -Controller "AuditLogs" -Operation "GET By ID" -Method "GET" -Url "$baseUrl/audit-logs/$logId" -ResponseResult $resLog
        } else {
            Write-Host "No audit log records available to test GET By ID." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Could not parse audit logs: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# ==============================================================================
# CLEANUP PHASE (DELETE in reverse order of dependencies)
# ==============================================================================
Write-Host "`n--- Cleaning Up Test Data (DELETE) ---" -ForegroundColor Blue

# DELETE Paiement
if ($paiementId -gt 0) {
    $res = Invoke-ApiRequest -Uri "$baseUrl/paiements/$paiementId" -Method "DELETE"
    Log-Test -Controller "Paiements" -Operation "DELETE" -Method "DELETE" -Url "$baseUrl/paiements/$paiementId" -ResponseResult $res
}

# DELETE Facture
if ($factureId -gt 0) {
    $res = Invoke-ApiRequest -Uri "$baseUrl/factures/$factureId" -Method "DELETE"
    Log-Test -Controller "Factures" -Operation "DELETE" -Method "DELETE" -Url "$baseUrl/factures/$factureId" -ResponseResult $res
}

# DELETE Ordonnance
if ($ordonnanceId -gt 0) {
    $res = Invoke-ApiRequest -Uri "$baseUrl/ordonnances/$ordonnanceId" -Method "DELETE"
    Log-Test -Controller "Ordonnances" -Operation "DELETE" -Method "DELETE" -Url "$baseUrl/ordonnances/$ordonnanceId" -ResponseResult $res
}

# DELETE Soin Effectue
if ($soinEffectueId -gt 0) {
    $res = Invoke-ApiRequest -Uri "$baseUrl/soins-effectues/$soinEffectueId" -Method "DELETE"
    Log-Test -Controller "SoinsEffectues" -Operation "DELETE" -Method "DELETE" -Url "$baseUrl/soins-effectues/$soinEffectueId" -ResponseResult $res
}

# DELETE Consultation
if ($consultationId -gt 0) {
    $res = Invoke-ApiRequest -Uri "$baseUrl/consultations/$consultationId" -Method "DELETE"
    Log-Test -Controller "Consultations" -Operation "DELETE" -Method "DELETE" -Url "$baseUrl/consultations/$consultationId" -ResponseResult $res
}

# DELETE Rendez-Vous
if ($rendezVousId -gt 0) {
    $res = Invoke-ApiRequest -Uri "$baseUrl/rendezvous/$rendezVousId" -Method "DELETE"
    Log-Test -Controller "RendezVous" -Operation "DELETE" -Method "DELETE" -Url "$baseUrl/rendezvous/$rendezVousId" -ResponseResult $res
}

# DELETE Acte Medical
if ($acteMedicalId -gt 0) {
    $res = Invoke-ApiRequest -Uri "$baseUrl/actes-medicaux/$acteMedicalId" -Method "DELETE"
    Log-Test -Controller "ActesMedicaux" -Operation "DELETE" -Method "DELETE" -Url "$baseUrl/actes-medicaux/$acteMedicalId" -ResponseResult $res
}

# DELETE Patient
if ($patientId -gt 0) {
    $res = Invoke-ApiRequest -Uri "$baseUrl/patients/$patientId" -Method "DELETE"
    Log-Test -Controller "Patients" -Operation "DELETE" -Method "DELETE" -Url "$baseUrl/patients/$patientId" -ResponseResult $res
}

# DELETE User
if ($userId -gt 0) {
    $res = Invoke-ApiRequest -Uri "$baseUrl/users/$userId" -Method "DELETE"
    Log-Test -Controller "Users" -Operation "DELETE" -Method "DELETE" -Url "$baseUrl/users/$userId" -ResponseResult $res
}

# DELETE Role
if ($roleId -gt 0) {
    $res = Invoke-ApiRequest -Uri "$baseUrl/roles/$roleId" -Method "DELETE"
    Log-Test -Controller "Roles" -Operation "DELETE" -Method "DELETE" -Url "$baseUrl/roles/$roleId" -ResponseResult $res
}

# ==============================================================================
# REPORT SUMMARY
# ==============================================================================
Write-Host "`n==============================================================================" -ForegroundColor Cyan
Write-Host "TESTING COMPLETE. SUMMARY OF RESULTS:" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan

$passedCount = ($testResults | Where-Object { $_.Status -eq "PASSED" }).Count
$failedCount = ($testResults | Where-Object { $_.Status -eq "FAILED" }).Count

$color = if ($failedCount -eq 0) { "Green" } else { "Red" }
Write-Host "Total Tests: $($testResults.Count) | Passed: $passedCount | Failed: $failedCount" -ForegroundColor $color

# Export results as JSON to a report file
$reportPath = Join-Path $PSScriptRoot "test_results.json"
$testResults | ConvertTo-Json -Depth 5 | Out-File -FilePath $reportPath -Encoding utf8
Write-Host "Detailed JSON report saved to: $reportPath" -ForegroundColor Gray
