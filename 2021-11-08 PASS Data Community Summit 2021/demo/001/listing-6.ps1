# declare variables
$Copy = 1
$ChildVhdPath = "C:\vhd\clone$copy.vhdx"    # location of Child VHD 
$ChildVhdMountPath = "C:\mnt\clone$copy\"   # NTFS folder mount point

# Dismount and remove NTFS folder mount
If (Test-Path $ChildVhdMountPath)
{
    DisMount-VHD -Path $ChildVhdPath
    Remove-Item $ChildVhdMountPath -force
    Remove-Item $ChildVhdPath -Force
}