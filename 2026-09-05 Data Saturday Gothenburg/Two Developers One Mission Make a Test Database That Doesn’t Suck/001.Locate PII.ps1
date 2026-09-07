$Instance = 'BRZ7JX3\SQL2025'
$Database = 'RetroPixelsProduction'
$OutDir   = "C:\Temp\PII-Scan\$(Get-Date -Format yyyyMMdd-HHmm)"

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

# Execute scan...
$scan = Invoke-DbaDbPiiScan `
  -SqlInstance $Instance `
  -Database   $Database `
  -SampleCount 500 `
  -EnableException

# Review on screen
$scan | Out-GridView -Title "PII candidates in $Database on $Instance"

# Save results
$scan | Export-Csv    -NoTypeInformation -Path (Join-Path $OutDir 'pii-scan.csv')
$scan | ConvertTo-Json -Depth 5          | Set-Content (Join-Path $OutDir 'pii-scan.json')

Write-Host "Saved to $OutDir"
