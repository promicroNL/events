# declare variables
$SQLDataPath = "C:\SQL\Data\"          # location of the MDF / LDF files

# Copy via VSS the SQL data to the VHD (NTFS Mount)
.\HoboCopy.exe $SQLDataPath $ParentVhdMountPath
