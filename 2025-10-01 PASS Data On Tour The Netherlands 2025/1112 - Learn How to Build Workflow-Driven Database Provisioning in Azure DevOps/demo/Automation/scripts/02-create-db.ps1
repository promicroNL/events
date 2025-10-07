<#
.SYNOPSIS
  Create or unstash a database on SQL Managed Instance.
.DESCRIPTION
  Creates a fresh database or restores a stashed copy and annotates
  it with build metadata.
#>

param(
    [string]$settingsFile = "../config/sqlmi-first.json"
)

. "$PSScriptRoot/00-utils.ps1"

# Load configuration and administrator password
$config = Get-Config -Path $settingsFile
$databaseName = $config.databaseName
$adminPass = Get-AdminPassword -Fallback $pwdDebug

Write-Log "Build name: $buildName"
Write-Log "Build id: $buildId"
Write-Log "Target database name: $databaseName"

# --- Inspect database database ---
$databaseExists = $false
$previousBuildName = $null
$databaseCheck = Invoke-Sql -Config $config -Database "master" -Query "SELECT database_id FROM sys.databases WHERE name = N'$databaseName';" -Password $adminPass
if ($databaseCheck) {
    $databaseExists = $true
    $previousBuildName = Get-DatabaseBuildName -Config $config -Database $databaseName -Password $adminPass
    $previousBuildId = Get-DatabaseBuildId -Config $config -Database $databaseName -Password $adminPass
}

# If database already matches current build, skip everything.
if ($databaseExists -and $previousBuildId -eq $buildId) {
    Write-Log "Database '$databaseName' already exists with forbuild: '$previousBuildName' ($previousBuildId). Skipping creation/unstash."
    Write-Log "##vso[task.setvariable variable=FreshDatabase;isOutput=true]false" "DEBUG"
    return
}
elseif ($databaseExists) {
    # Stash existing database
    if ($previousBuildName -and ($previousBuildName -ne $buildName)) {
        $suffix = $previousBuildName
    }
    else {
        $suffix = "stashed-$(Get-Date -Format yyyyMMddHHmmss)"
    }
    Write-Log "Database '$databaseName' already exists and will be stashed as ${databaseName}_$suffix"

    Rename-Database -Config $config -Database $databaseName -NewName "${databaseName}_$suffix" -Password $adminPass | Out-Null

    Write-Log "Attempt to cancel build: '$previousBuildName' ($previousBuildId) the database is stashed, user can rerun the job if needed." "INFO"
    $ctx = Get-PipelineContext
    $cancelUrl = "$($ctx.OrgUrl)/$($ctx.Project)/_apis/build/builds/$($previousBuildId)?api-version=7.1"
    $body = @{ status = 4 } | ConvertTo-Json -Compress
    Write-Log "PATCH $cancelUrl" "DEBUG"
    try {
        Invoke-RestMethod -Method PATCH -Uri $cancelUrl -Headers $ctx.Headers -ContentType 'application/json' -Body $body | Out-Null
    }
    catch {
        Write-Log "Failed to cancel build $($ctx.BuildId): $($_.Exception.Message)" "WARN"
    }

}

$didUnstash = $false

# --- Attempt to unstash by matching stashed name and verifying BuildName EP ---
$stashedName = "${databaseName}_$buildName"
$checkStashedQuery = "SELECT database_id FROM sys.databases WHERE name = N'$stashedName';"
$stashedCheck = Invoke-Sql -Config $config -Database "master" -Query $checkStashedQuery -Password $adminPass

if ($stashedCheck) {
    Write-Log "Found stashed candidate '$stashedName'. Verifying BuildName EP."
    $epName = Get-DatabaseBuildName -Config $config -Database $stashedName -Password $adminPass
    if ($epName -eq $buildName) {
        Write-Log "Renaming stashed '$stashedName' back to database '$databaseName'."
        Rename-Database -Config $config -Database $stashedName -NewName $databaseName -Password $adminPass | Out-Null
        Write-Log "Unstash complete; using database '$databaseName'. (BuildName EP already validated.)"
        $didUnstash = $true
    }
    else {
        Write-Log "Skipping unstash; BuildName EP '$epName' does not match current build '$buildName'."
    }
}

if (-not $didUnstash) {
    Write-Log "No stashed database recovered; ensuring '$databaseName' exists."

    # Create fresh database if missing
    $createDbCmd = "IF DB_ID(N'$databaseName') IS NULL CREATE DATABASE [$databaseName];"
    Invoke-Sql -Config $config -Database "master" -Query $createDbCmd -Password $adminPass

    # Set/update BuildName and BuildId EPs
    $setEp = @"
IF EXISTS (
    SELECT 1
    FROM fn_listextendedproperty('BuildName', NULL, NULL, NULL, NULL, NULL, NULL)
)
    EXEC sp_updateextendedproperty @name=N'BuildName', @value=N'$buildName';
ELSE
    EXEC sp_addextendedproperty @name=N'BuildName', @value=N'$buildName';

IF EXISTS (
    SELECT 1
    FROM fn_listextendedproperty('BuildId', NULL, NULL, NULL, NULL, NULL, NULL)
)
    EXEC sp_updateextendedproperty @name=N'BuildId', @value=N'$buildId';
ELSE
    EXEC sp_addextendedproperty @name=N'BuildId', @value=N'$buildId';
"@
    Invoke-Sql -Config $config -Database $databaseName -Query $setEp -Password $adminPass

    Write-Log "Database created and BuildName EP set to '$buildName' and BuildId EP set to '$buildId'."
    Write-Log "##vso[task.setvariable variable=FreshDatabase]true" "DEBUG"
}
else {
    # No fresh database (unstashed)
    Write-Log "##vso[task.setvariable variable=FreshDatabase]false" "DEBUG"
}

Write-Log "Provisioning/unstash logic finished."
