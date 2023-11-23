# this uses NTVCM to run CP/M native tools
# it also uses the CtrlZ executable that will need a dotnet SDK installing
# This tool adds and removes CtrlZ at the end of the CP/M files
# to mark the end of file.
Write-Host 'Generating files for comparison'
if ((Test-Path -Path comparison -PathType Container) -eq $false)
{
    New-Item -ItemType Directory -Path comparison
}
if ((Test-Path -Path binaries -PathType Container) -eq $false)
{
    New-Item -ItemType Directory -Path binaries
}
remove-item binaries\*.*
Set-location -Path comparison
dotnet run --project ../../../tools\NibReader ../../../DiskImages/BlankBootableCPM3.nib -nodiag
Set-location -Path ..
Write-Host 'Building files'
.\M80.ps1 BOOTSECT
.\M80.ps1 TOOLKEY
.\M80.ps1 LDRBIOS
.\M80.ps1 BIOSVID
.\M80.ps1 BIOSDISK
.\M80.ps1 BIOSCHAR
.\M80.ps1 SCB
.\M80.ps1 BIOS
Write-Host 'Linking'
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK BOOTSECT.BIN[L0800,NR,NL]=BOOTSECT
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK TOOLKEY.BIN[L0000,NR,NL]=TOOLKEY
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK BIOSCHAR.BIN[L0A00,NR,NL]=BIOSCHAR
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK BIOSVID.BIN[LD000,NR,NL]=BIOSVID
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK BIOSDISK.BIN[LD400,NR,NL]=BIOSDISK
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK CPMLDR.BIN[L1100,NL]=CPMLDR,LDRBIOS
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK BNKBIOS3[b,NR,NL]=BIOS,SCB
move-item BNKBIOS3.SPR -Destination gencpm 
Write-host 'Running GENCPM'
Set-location -Path gencpm
C:\tools\ntvcm.exe GENCPM AUTO DISPLAY
move-item CPM3.SYS -Destination ..\binaries
move-item BNKBIOS3.SPR -Destination ..\binaries
Set-location -Path ..
move-item *.BIN -Destination binaries
Remove-item .\CPMLDR.SYM
Write-host ' '
Write-host ' '
Write-Host 'Comparing binaries for BOOTSECT'
fc.exe /b binaries\BOOTSECT.BIN comparison\BOOTSECT.bin
Write-Host 'Comparing binaries for TOOLKEY'
fc.exe /b binaries\TOOLKEY.BIN comparison\TOOLKEY.bin
Write-Host 'Comparing binaries for BIOSVID'
fc.exe /b binaries\BIOSVID.BIN comparison\BIOSVID.BIN  
Write-Host 'Comparing binaries for BIOSDISK'
fc.exe /b binaries\BIOSDISK.BIN comparison\BIOSDISK.BIN  
Write-Host 'Comparing binaries for BIOSCHAR'
fc.exe /b binaries\BIOSCHAR.BIN comparison\BIOSCHAR.BIN  
Write-Host 'Comparing binaries for CPMLDR'
fc.exe /b binaries\CPMLDR.BIN comparison\CPMLDR.bin
Write-Host 'Comparing binaries for CPM3.SYS'
fc.exe /b binaries\CPM3.SYS comparison\CPM3.SYS
remove-item -Path *.REL -Exclude CPMLDR.REL
remove-item -Path '*.$$$'
copy-item -Path .\comparison\CCP.COM -Destination binaries\CCP.COM