$Instance = 'BRZ7JX3\SQL2025'
$StageDb  = 'RetroPixelsProduction'

$OutDir   = "C:Temp\\PII-Masking\$(Get-Date -Format yyyyMMdd-HHmm)"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

# Generate starter masking config (for finetuning)
$ConfigPath = Join-Path $OutDir 'masking-config.json'
New-DbaDbMaskingConfig -SqlInstance $Instance -Database $StageDb -Path $ConfigPath

#https://docs.dbatools.io/bogus/