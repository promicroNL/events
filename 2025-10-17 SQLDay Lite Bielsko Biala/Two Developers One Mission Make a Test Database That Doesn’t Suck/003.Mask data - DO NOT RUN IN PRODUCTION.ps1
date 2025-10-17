$Instance   = 'BRZ7JX3\SQL2025'
$StageDb    = 'RetroPixelsProduction'
$ConfigPath = 'C:\Temp\DataMaskingConfig.json'  # adjust

# Dry run first (if supported in your build of dbatools)
# Invoke-DbaDbDataMasking -SqlInstance $Instance -Database $StageDb -FilePath $ConfigPath -WhatIf -Debug

# Execute for real
Invoke-DbaDbDataMasking -SqlInstance $Instance -Database $StageDb -FilePath $ConfigPath -Locale nl -BatchSize 5000

# Or for a subset (e.g. dutch customer addresses)
#Invoke-DbaDbDataMasking -SqlInstance $Instance -Database $StageDb -FilePath $ConfigPath -Locale nl -Query "SELECT * FROM dbo.CustomerAddress WHERE CountryId = 'NL'"