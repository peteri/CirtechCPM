# This uses NTVCM to run CP/M native tools and expects to find it in C:\tools\ntvcm.exe
# you could use the ZXCC tool chain instead if you want to.
# it also builds and use some tools that will need a dotnet 8.0 SDK installing
# These tools:
# - Add and remove CtrlZ at the end of the CP/M files
# - Writes the binaries into a Apple disk image. 
#
$systemFiles=@(
'binaries/CPM3.SYS',
'binaries/COPYSYS.COM',
'RomWBW/SET.COM',
'RomWBW/PUT.COM',
'RomWBW/RENAME.COM',
'RomWBW/PATCH.COM',
'binaries/SDT.COM',
'RomWBW/DATE.COM',
'RomWBW/PIP.COM',
'RomWBW/DEVICE.COM',
'system/PROFILE.SUB',
'RomWBW/SHOW.COM',
'RomWBW/DIR.COM',
'RomWBW/ERASE.COM',
'RomWBW/GET.COM',
'RomWBW/SETDEF.COM',
'RomWBW/SUBMIT.COM',
'RomWBW/TYPE.COM',
'binaries/START.COM'
)
if ((Test-Path -Path binaries -PathType Container) -eq $false)
{
    New-Item -ItemType Directory -Path binaries
}
if ((Test-Path -Path utility -PathType Container) -eq $false)
{
    New-Item -ItemType Directory -Path utility
}
if ((Test-Path -Path system -PathType Container) -eq $false)
{
    New-Item -ItemType Directory -Path system
}
# Delete output from earlier runs
remove-item binaries\*.*
remove-item utility\*.*
remove-item system\*.*
# extract files from the cirtech drive (help + patchers)
Set-location -Path utility
dotnet run --project ../../../tools/CpmDsk -- extract *.* --disk-image "../../../DiskImages/CIRTECH CPM PLUS UTILITY.DSK" 
Set-location -Path ../system
dotnet run --project ../../../tools/CpmDsk -- extract *.* --disk-image "../../../DiskImages/CIRTECH CPM PLUS SYSTEM.DSK" 
Set-location -Path ..
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
.\M80.ps1 SDT
# Annoyingly the linker doesn't return errors
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
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK SDT[NR,NL]=SDT
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
remove-item gencpm\BNKBIOS3.SPR
copy-item -Path .\RomWBW\CCP.COM -Destination binaries\CCP.COM
remove-item .\CPMLDR.SYM
remove-item -Path *.REL -Exclude CPMLDR.REL
remove-item -Path '*.$$$'
dotnet run --project ../../tools/CpmDsk -- create --disk-image binaries/system.dsk --binaries-folder ./binaries
dotnet run --project ../../tools/CpmDsk -- add $systemFiles  --disk-image binaries/system.dsk

