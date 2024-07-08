# declare variables
$Copy = 1
$ChildVhdPath = "C:\vhd\clone$copy.vhdx"    # location of Child VHD 
$ChildVhdMountPath = "C:\mnt\clone$copy\"   # NTFS folder mount point

If (Test-Path $ParentVhdMountPath)
{
    # Dismount and remove NTFS folder mount
    DisMount-VHD -Path $ParentVhdPath

    # Make the paren VHD read only
    Set-ItemProperty -Path $ParentVhdPath -Name IsReadOnly -Value $true

    # Remove the NTFS folder (mount)
    Remove-Item $ParentVhdMountPath -force
}
# Create the differencing disk (Child VHD)
New-VHD -ParentPath $ParentVhdPath -Path $ChildVhdPath -Differencing

# Create folder for the mount
New-Item -ItemType directory -Path $ChildVhdMountPath 

# Mount Child VHD 
Mount-Vhd $childvhdpath

# Force the disk to go online, even if the GUID
Get-DiskImage -ImagePath $ChildVhdPath| Get-Disk | Set-disk -IsOffline $False

# Mount the partition as a NTFS folder 
Get-DiskImage -ImagePath $ChildVhdPath| Get-Disk | Get-Partition | Where-Object -FilterScript {$_.Type -Eq "Basic"} | Add-PartitionAccessPath -AccessPath $ChildVhdMountPath
