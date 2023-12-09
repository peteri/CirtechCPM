# This uses NTVCM to run CP/M native tools and expects to find it in C:\tools\ntvcm.exe
# you could use the ZXCC tool chain instead if you want to.
# it also builds and use some tools that will need a dotnet 8.0 SDK installing
# These tools:
# - Add and remove CtrlZ at the end of the CP/M files
# - Dumps the binaries from a nibble image of a bootable disk for comparison
# - (future) Writes the binaries into a Apple disk image. 
# Note this will not boot on an emulator due to code that detects a Cirtech code
#
Write-Host 'Generating files for comparison'
if ((Test-Path -Path comparison -PathType Container) -eq $false)
{
    New-Item -ItemType Directory -Path comparison
}
if ((Test-Path -Path binaries -PathType Container) -eq $false)
{
    New-Item -ItemType Directory -Path binaries
}
if ((Test-Path -Path system -PathType Container) -eq $false)
{
    New-Item -ItemType Directory -Path system
}
# Delete output from earlier runs
remove-item binaries\*.*
remove-item system\*.*
remove-item comparison\*.*
# create some comparison binaries from a disk image
Set-location -Path comparison
dotnet run --project ../../../tools/NibReader -- ../../../DiskImages/BlankBootableCPM3.nib -nodiag
# extract files from the cirtech drive
Set-location -Path ../system
#dotnet run --project ../../../tools/CpmDsk -- directory --disk-image "../../../DiskImages/CIRTECH CPM PLUS SYSTEM.DSK" 
dotnet run --project ../../../tools/CpmDsk -- extract *.* --disk-image "../../../DiskImages/CIRTECH CPM PLUS SYSTEM.DSK" 
Set-location -Path ..
# Copy files into comparison folder
copy-item -Path .\system\START.COM -Destination .\comparison\START.COM
copy-item -Path .\system\COPYSYS.COM -Destination .\comparison\COPYSYS.COM
Write-Host 'Building files'
# For M80 we can wrap in powershell script and catch and errors by
# teeing output to a file and looking for No Fatal Error(s)
.\M80.ps1 BOOTSECT
.\M80.ps1 TOOLKEY
.\M80.ps1 LDRBIOS
.\M80.ps1 BIOSVID
.\M80.ps1 BIOSDISK
.\M80.ps1 BIOSCHAR
.\M80.ps1 SCB
.\M80.ps1 BIOS
.\M80.ps1 COPYSYS
.\M80.ps1 START
# Annoyingly the linker doesn't return errors
# however the file comparisons will blow up.
Write-Host 'Linking'
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK BOOTSECT.BIN[NR,NL]=BOOTSECT
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK TOOLKEY.BIN[NR,NL]=TOOLKEY
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK BIOSCHAR.BIN[NR,NL]=BIOSCHAR
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK BIOSVID.BIN[NR,NL]=BIOSVID
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK BIOSDISK.BIN[NR,NL]=BIOSDISK
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK CPMLDR.BIN[L1100,NL]=CPMLDR,LDRBIOS
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK BNKBIOS3[b,NR,NL]=BIOS,SCB
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK COPYSYS[NR,NL]=COPYSYS
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK START[NR,NL]=START
# move the Banked BIOS into the gencpm folder and run it.
move-item BNKBIOS3.SPR -Destination gencpm 
Write-host 'Running GENCPM'
Set-location -Path gencpm
C:\tools\ntvcm.exe GENCPM AUTO DISPLAY
Set-location -Path ..
Write-host ' '
# move files into the binaries folder and some cleanup
move-item *.BIN -Destination .\binaries
move-item *.COM -Destination .\binaries
move-item gencpm\CPM3.SYS -Destination .\binaries
move-item gencpm\BNKBIOS3.SPR -Destination .\binaries
copy-item -Path .\comparison\CCP.COM -Destination binaries\CCP.COM
remove-item .\CPMLDR.SYM
remove-item -Path *.REL -Exclude CPMLDR.REL
remove-item -Path '*.$$$'
# compare the binaries
Write-host '======= Comparing ======='
Write-Host 'Comparing binaries for BOOTSECT'
fc.exe /b binaries\BOOTSECT.BIN comparison\BOOTSECT.BIN
Write-Host 'Comparing binaries for TOOLKEY'
fc.exe /b binaries\TOOLKEY.BIN comparison\TOOLKEY.BIN
Write-Host 'Comparing binaries for BIOSVID'
fc.exe /b binaries\BIOSVID.BIN comparison\BIOSVID.BIN  
Write-Host 'Comparing binaries for BIOSDISK'
fc.exe /b binaries\BIOSDISK.BIN comparison\BIOSDISK.BIN  
Write-Host 'Comparing binaries for BIOSCHAR'
fc.exe /b binaries\BIOSCHAR.BIN comparison\BIOSCHAR.BIN  
Write-Host 'Comparing binaries for CPMLDR'
fc.exe /b binaries\CPMLDR.BIN comparison\CPMLDR.BIN
Write-Host 'Comparing binaries for CPM3.SYS'
fc.exe /b binaries\CPM3.SYS comparison\CPM3.SYS
Write-Host 'Comparing binaries for COPYSYS.COM'
fc.exe /b binaries\COPYSYS.COM comparison\COPYSYS.COM
Write-Host 'Comparing binaries for START.COM'
fc.exe /b binaries\START.COM comparison\START.COM
dotnet run --project ../../tools/CpmDsk -- create --disk-image binaries/system.dsk --binaries-folder ./binaries
dotnet run --project ../../tools/CpmDsk -- add system/*.* --disk-image binaries/system.dsk
dotnet run --project ../../tools/CpmDsk -- remove cpm3.sys --disk-image binaries/system.dsk
dotnet run --project ../../tools/CpmDsk -- add binaries/cpm3.sys --disk-image binaries/system.dsk
