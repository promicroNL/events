Import-Module PSWriteColor
Import-Module powershell-yaml

$agentID = $env:AGENT_ID;

if ($null -eq $agentID) {
    $pipelineRun = $false
}
else {
    $pipelineRun = $true
}

function Write-Information {
    param (
        $Message
    )
    if ($pipelineRun) {
        Write-Host $Message
    }
    else {
        Import-Module PSWriteColor
        Write-Color "[$(Get-Date) INF] ", $Message -Color Green, White
    }
}

function Write-Error {
    param (
        $Message,
        [bool] $WithLog = 0
    )
    if ($pipelineRun) {
        if ($WithLog) {
            Write-Host "##vso[task.logissue type=error]$Message"
        }
        else {
            Write-Host "##[error]$Message"
        }
    }
    else {
        Import-Module PSWriteColor
        Write-Color "[$(Get-Date) ERR] ", $Message -Color Red, White
    }
}

function Write-Warning {
    param (
        $Message,
        [bool] $WithLog = 0
    )
    if ($pipelineRun) {
        if ($WithLog) {
            Write-Host "##vso[task.logissue type=warning]$Message"
        }
        else {
            Write-Host "##[warning]$Message"
        }
    }
    else {
        Import-Module PSWriteColor
        Write-Color "[$(Get-Date) WRN] ", $Message -Color Yellow, White
    }
}

function New-SQLCompareSnapshotCmd {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, Position = 0)] [string]$SnapshotPathAndFileName,
        [Parameter(Mandatory = $true, Position = 1)] [string]$TargetHost,
        [Parameter(Mandatory = $false, Position = 2)] [string]$Port,
        [Parameter(Mandatory = $true, Position = 3)] [string]$DatabaseName,
        [Parameter(Mandatory = $false, Position = 4)] [string]$User,
        [Parameter(Mandatory = $false, Position = 5)] [string]$Password,
        [Parameter(Mandatory = $false, Position = 6)] [string]$SqlCompareLicenseKey)

    try {
  
        # Build parameters to run with sql compare command line
        $params = 
        "/activateserial=$SqlCompareLicenseKey",
        "/s1:$TargetHost,$Port",
        "/db1:$DatabaseName",
        "/u1:$User",
        "/p1:$Password",
        "/makeSnapshot:$SnapshotPathAndFileName"

        &"C:\Program Files (x86)\Red Gate\SQL Compare 14\SQLCompare.exe"  @params
  
    }
    catch {
        Write-Error "Error invoking SQLCompare command line: $_"
        return $null
    }
}
function New-SQLCompareReportCmd {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, Position = 0)] [string]$ReportPathAndFileName,  
        [Parameter(Mandatory = $true, Position = 1)] [string]$Snapshot1PathAndFileName,
        [Parameter(Mandatory = $true, Position = 2)] [string]$Snapshot2PathAndFileName,
        [Parameter(Mandatory = $false, Position = 3)] [string]$SqlCompareLicenseKey)

    try {
  
        # Build parameters to run with sql compare command line
        $params = 
        "/activateserial=$SqlCompareLicenseKey",
        "/Snapshot1:$Snapshot1PathAndFileName",                   
        "/Snapshot2:$Snapshot2PathAndFileName" ,                  
        "/Report:$ReportPathAndFileName",                         
        '/Force',
        '/ReportType:Html',
        '/exclude:table:flyway_schema_history',
        '/exclude:table:__SchemaSnapshot',
        '/Assertidentical'
  
        &"C:\Program Files (x86)\Red Gate\SQL Compare 14\SQLCompare.exe" @params
    }
    catch {
        Write-Error "Error invoking SQLCompare command line: $_"
        return $null
    }
  
}

function Update-YamlFile {
    param (
        [string]$filePath,
        [hashtable]$variable
    )

    # Initialize data hashtable
    $data = @{}

    # Check if the file exists and read its content
    if (Test-Path $filePath) {
        $yamlContent = Get-Content $filePath -Raw
        $data = ConvertFrom-Yaml $yamlContent
    }

    # Merge or add new variable(s)
    foreach ($key in $variable.Keys) {
        $data[$key] = $variable[$key]
    }

    # Convert the data back to YAML format and write to the file
    $yamlContent = ConvertTo-Yaml $data
    $yamlContent | Out-File $filePath

}

function Read-YamlFile {
    param (
        [string]$filePath
    )

    # Check if the file exists
    if (Test-Path $filePath) {
        # Read the YAML file content and convert it to a PowerShell object
        $yamlContent = Get-Content $filePath -Raw
        $data = ConvertFrom-Yaml $yamlContent

        return $data
    }
    else {
        Write-Warning "File not found: $filePath"
        return $null
    }
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
    $Header = @{Authorization = ("Basic {0}" -f $Auth) } 
    return $Header
}
