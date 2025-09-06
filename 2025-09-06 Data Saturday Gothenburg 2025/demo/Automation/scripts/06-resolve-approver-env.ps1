<#
.SYNOPSIS
  Resolve the actual approver of a ManualValidation step and map to an environment
  via a simple JSON file, then expose it as a pipeline output variable.
.DESCRIPTION
  Queries Azure DevOps to determine who approved a manual validation step and
  maps that user to a target environment defined in a JSON configuration file.

.PARAMETER MappingFile
  Path to a JSON file that contains an array `approverEnvironment` with objects:
    {
      "Name": "user@domain",
      "Environment": "env-name"
    }

.NOTES
  - Requires pipeline setting "Allow scripts to access the OAuth token" (for $(System.AccessToken)).
  - Works on Microsoft-hosted agents without extra modules.
#>
[CmdletBinding()]
param(
  [string] $MappingFile = '../config/approver-environment.json',
  [string] $ManualValidationTaskName = 'ManualValidation'
)

. "$PSScriptRoot/00-utils.ps1"

try {
  $ErrorActionPreference = 'Stop'

  $ctx = Get-PipelineContext
  $orgUrl = $ctx.OrgUrl
  $project = $ctx.Project
  $headers = $ctx.Headers

  Write-Log "Resolving approval information..."
  $approvalId = Get-ManualValidationApprovalId -OrgUrl $orgUrl -Project $project -BuildId $buildId -Headers $headers -TaskName $ManualValidationTaskName
  Write-Log "ApprovalId: $approvalId"

  $approver = Get-ActualApprover -OrgUrl $orgUrl -Project $project -ApprovalId $approvalId -Headers $headers
  if (-not $approver) { throw "Approver could not be determined." }
  Write-Log "Approver detected: $approver"

  $map = Get-Content $MappingFile | ConvertFrom-Json
  $envName = $map.approverEnvironment |
    Where-Object { $_.Name -ieq $approver } |
    Select-Object -ExpandProperty Environment

  if (-not $envName) {
    throw "No environment mapped for approver '$approver' in '$MappingFile'."
  }

  Write-Log "Resolved TargetEnvironment: $envName"

  Write-Log "##vso[task.setvariable variable=Approver;isOutput=true]$approver"
  Write-Log "##vso[task.setvariable variable=TargetEnvironment;isOutput=true]$envName"

  exit 0
}
catch {
  Write-Error $_.Exception.Message
  exit 1
}
