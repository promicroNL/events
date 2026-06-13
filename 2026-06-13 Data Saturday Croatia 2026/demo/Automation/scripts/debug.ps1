# Debug.ps1 --- IGNORE --- put this normally in .gitignore, but we want to share it for demo purposes.

# Local debug initialization for scripts that normally run in Azure DevOps pipelines.
# Update these values before running locally.

# Build metadata normally provided by Azure Pipelines
$buildName = 'local-build-zagreb'
$buildId   = '1337'

# SQL MI admin password fallback for local development
$pwdDebug = $env:MI_PASSWORD

# Debug script for pipeline access
$pat = $env:ADO_PAT_DevOps
$orgUrl = 'https://dev.azure.com/promicronl'
$project = 'NYC-dbDevOps'
