<#
.SYNOPSIS
    Utility functions for PowerShell scripts in this repository.
.DESCRIPTION
    Provides logging, configuration loading, password retrieval, SQL helpers, and
    pipeline context utilities shared across the other scripts.
#>

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp][$Level] $Message"
}
# For easy local debugging we add this section, no $env:AGENT_ID? Then we init our debug.ps1 file
if ($env:AGENT_ID) {
    Write-Log "Pipeline run" "DEBUG"
    $buildName = $env:BUILD_BUILDNUMBER
    $buildId = $env:BUILD_BUILDID
}
else {
    $DebugScript = "$PSScriptRoot/Debug.ps1"
    Write-Log "Local run" "DEBUG"
    if (Test-Path $DebugScript) {
        . $DebugScript
        Write-Log "Variables loaded from debug script" "DEBUG"
    }
}

function Get-Config {
    param(
        [string]$Path = "../config/sqlmi-first.json"
    )
    if (-not (Test-Path $Path)) {
        throw "Config file not found at $Path"
    }
    Write-Log "Loading config from $Path" "DEBUG"
    return Get-Content $Path | ConvertFrom-Json
}

function Get-AdminPassword {
    param(
        [string]$Fallback = $null
    )
    $adminPass = $env:SQLMIADMINPASS
    if ([string]::IsNullOrWhiteSpace($adminPass)) {
        Write-Log "SQLMIADMINPASS not found in pipeline vars" "WARN"
        $adminPass = $Fallback
    }
    if (-not $adminPass) {
        throw "SQL MI admin password not provided"
    }
    else  {
         Write-Log "SQLMIADMINPASS found in debug fallback" "DEBUG"
    }
    
    return $adminPass
}

function Invoke-Sql {
    param(
        [object]$Config,
        [string]$Database,
        [string]$Query,
        [string]$Password
    )
    Write-Log "Invoke-Sql on '$Database' with '$Query'" "DEBUG"
    Invoke-Sqlcmd -ServerInstance $Config.sqlServerNameFqdn `
        -Database $Database `
        -Username $Config.adminUser `
        -Password $Password `
        -Query $Query `
        -ErrorAction Stop
}

function Get-DatabaseBuildName {
    param(
        [object]$Config,
        [string]$Database,
        [string]$Password
    )
    try {
        $epVal = Invoke-Sql -Config $Config -Database $Database -Query @"
SELECT CAST(value AS NVARCHAR(200)) AS BuildName
FROM fn_listextendedproperty(
    'BuildName',
    NULL, NULL,
    NULL, NULL,
    NULL, NULL
);
"@ -Password $Password
        if ($epVal -and $epVal.BuildName) {
            return $epVal.BuildName.Trim()
        }
    }
    catch {
        Write-Log "Could not read existing BuildName EP on '$Database'." "WARN"
    }
    return $null
}

function Get-DatabaseBuildId {
    param(
        [object]$Config,
        [string]$Database,
        [string]$Password
    )
    try {
        $epVal = Invoke-Sql -Config $Config -Database $Database -Query @"
SELECT CAST(value AS NVARCHAR(200)) AS BuildId
FROM fn_listextendedproperty(
    'BuildId',
    NULL, NULL,
    NULL, NULL,
    NULL, NULL
);
"@ -Password $Password
        if ($epVal -and $epVal.BuildId) {
            return $epVal.BuildId.Trim()
        }
    }
    catch {
        Write-Log "Could not read existing BuildId EP on '$Database'." "WARN"
    }
    return $null
}

function Rename-Database {
    param(
        [object]$Config,
        [string]$Database,
        [string]$NewName,
        [string]$Password
    )
    if ($NewName -eq $Database) {
        Write-Log "Rename target equals original; skipping rename." "WARN"
        return $Database
    }
    Write-Log "Renaming database '$Database' to '$NewName'."
    $renameScript = @"
ALTER DATABASE [$Database]
  MODIFY NAME = [$NewName];
"@
    Invoke-Sql -Config $Config -Database "master" -Query $renameScript -Password $Password
    Write-Log "Rename complete."
    return $NewName
}

function Get-BasicAuthHeader {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [string]$PAT
    )
    $Auth = '{0}:{1}' -f $Name, $PAT
    $Auth = [System.Text.Encoding]::UTF8.GetBytes($Auth)
    $Auth = [System.Convert]::ToBase64String($Auth)
    return @{ Authorization = ("Basic {0}" -f $Auth) }
}

function Get-ManualValidationApprovalId {
    param(
        [string] $OrgUrl,
        [string] $Project,
        [string] $BuildId,
        [hashtable] $Headers,
        [string] $TaskName
    )
    $timelineUrl = "$OrgUrl/$Project/_apis/build/builds/$BuildId/timeline?api-version=7.1-preview.2"
    Write-Log "GET $timelineUrl"
    $timeline = Invoke-RestMethod -Method GET -Uri $timelineUrl -Headers $Headers

    $mvRecord = $timeline.records |
    Where-Object { $_.type -eq 'Task' -and $_.name -eq $TaskName -and $_.state -eq 'completed' } |
    Sort-Object -Property lastModified -Descending |
    Select-Object -First 1

    if (-not $mvRecord -or -not $mvRecord.identifier) {
        throw "ManualValidation record not found or missing identifier in timeline."
    }

    return $mvRecord.identifier
}

function Get-ActualApprover {
    param(
        [string] $OrgUrl,
        [string] $Project,
        [string] $ApprovalId,
        [hashtable] $Headers
    )
    $approvalUrl = "$OrgUrl/$Project/_apis/pipelines/approvals/$ApprovalId/?`$expand=steps&api-version=7.1"
    Write-Log "GET $approvalUrl"
    $approval = Invoke-RestMethod -Method GET -Uri $approvalUrl -Headers $Headers

    $step = $approval.steps | Where-Object { $_.status -eq 'approved' -and $_.actualApprover } | Select-Object -First 1
    if (-not $step) {
        throw "No approved approval step with actualApprover found."
    }

    return $step.actualApprover.uniqueName ?? $step.actualApprover.displayName
}

function Get-PipelineContext {
    param(
        [string]$DebugScript = "$PSScriptRoot/Debug.ps1"
    )
    if ($env:AGENT_ID) {
        $pipelineRun = $true
        Write-Log "Invoke web request using OAuth 2" "DEBUG"
        $orgUrl = $env:SYSTEM_COLLECTIONURI.TrimEnd('/')
        $project = $env:SYSTEM_TEAMPROJECT
        $token = $env:SYSTEM_ACCESSTOKEN
        $headers = @{ Authorization = "Bearer $token" }
    }
    else {
        $pipelineRun = $false
        Write-Log "Invoke web request using basic authentication" "DEBUG"
        if (Test-Path $DebugScript) { . $DebugScript }
        $headers = Get-BasicAuthHeader 'PAT' $pat
    }

    return [pscustomobject]@{
        PipelineRun = $pipelineRun
        OrgUrl      = $orgUrl
        Project     = $project
        Headers     = $headers
    }
}
