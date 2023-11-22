# this uses NTVCM to run CP/M native tools
# it also uses the CtrlZ executable that will need a dotnet SDK installing
# This tool adds and removes CtrlZ at the end of the CP/M files
# to mark the end of file.
Write-Host 'Generating files for comparison'
if ((Test-Path -Path comparison -PathType Container) -eq $false)
{
    New-Item -ItemType Directory -Path comparison
}
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
Write-Host 'Linking'
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK BOOTSECT.BIN[L0800,NR,NL]=BOOTSECT
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK TOOLKEY.BIN[L0000,NR,NL]=TOOLKEY
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK BIOSCHAR.BIN[L0A00,NR,NL]=BIOSCHAR
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK BIOSVID.BIN[LD000,NR,NL]=BIOSVID
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK BIOSDISK.BIN[LD400,NR,NL]=BIOSDISK
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK CPMLDR.BIN[L1100,NR,NL]=CPMLDR,LDRBIOS
Write-Host 'Comparing binaries for BOOTSECT'
fc.exe /b BOOTSECT.BIN comparison\BOOTSECT.bin
Write-Host 'Comparing binaries for TOOLKEY'
fc.exe /b TOOLKEY.BIN comparison\TOOLKEY.bin
Write-Host 'Comparing binaries for BIOSVID'
fc.exe /b BIOSVID.BIN comparison\BIOSVID.BIN  
Write-Host 'Comparing binaries for BIOSDISK'
fc.exe /b BIOSDISK.BIN comparison\BIOSDISK.BIN  
Write-Host 'Comparing binaries for BIOSCHAR'
fc.exe /b BIOSCHAR.BIN comparison\BIOSCHAR.BIN  
Write-Host 'Comparing binaries for CPMLDR'
fc.exe /b CPMLDR.BIN comparison\CPMLDR.bin
remove-item -Path *.REL -Exclude CPMLDR.REL
remove-item -Path '*.$$$'
remove-item -Path IOSMLDR.BIN
copy-item -Path .\comparison\CCP.COM -Destination .\CCP.COM