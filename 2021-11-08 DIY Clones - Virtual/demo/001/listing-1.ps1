# declare variables
$ParentVhdPath = "C:\vhd\parent.vhdx"  # location of base VHD 
$ParentVhdSize = 2048GB                # maximum size of a VHD, size is dynamically expanding
$ParentVhdMountPath = "C:\mnt\parent\" # NTFS folder mount point

# Create folder
New-Item -ItemType directory -Path $ParentVhdMountPath
# Create the parent VHD, Mount + format it
New-VHD -Path $ParentVhdPath -Dynamic -SizeBytes $ParentVhdSize  | Mount-VHD -Passthru | Initialize-Disk -Passthru | New-Partition -UseMaximumSize | Format-Volume -FileSystem NTFS -Confirm:$false -Force

# Mount the partition as a NTFS folder 
Get-DiskImage -ImagePath $ParentVhdPath | Get-Disk | Get-Partition | Where-Object -FilterScript {$_.Type -Eq "Basic"} | Add-PartitionAccessPath -AccessPath $ParentVhdMountPath


