# this uses NTVCM to run CP/M native tools
# it also uses the CtrlZ executable that will need a dotnet SDK installing
# This tool adds and removes CtrlZ at the end of the CP/M files
# to mark the end of file.
Write-Host 'Generating files for comparison'
dotnet run --project ..\..\tools\NibReader ../../DiskImages/BlankBootableCPM3.nib -nodiag
Write-Host 'Building files'
.\M80.ps1 BOOTSECT
.\M80.ps1 TOOLKEY
.\M80.ps1 LDRBIOS
.\M80.ps1 BIOSVID
.\M80.ps1 BIOSDISK
Write-Host 'Linking'
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK BOOTSECT[L0800,NR,NL]=BOOTSECT
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK TOOLKEY[L0000,NR,NL]=TOOLKEY
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK D000[LD000,NR,NL]=BIOSVID,BIOSDISK
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK CPMLDR[L1100,NL]=CPMLDR,LDRBIOS
Write-Host 'Comparing binaries for BOOTSECT'
fc.exe /b BOOTSECT.COM BOOTSECT.bin
Write-Host 'Comparing binaries for TOOLKEY'
fc.exe /b TOOLKEY.COM TOOLKEY.bin
Write-Host 'Comparing binaries for D000'
fc.exe /b D000.COM D000.bin
Write-Host 'Comparing binaries for CPMLDR'
fc.exe /b CPMLDR.COM CPMLDR.bin
