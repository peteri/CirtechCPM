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
.\M80.ps1 BIOSCHAR
Write-Host 'Linking'
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK BOOTSECT[L0800,NR,NL]=BOOTSECT
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK TOOLKEY[L0000,NR,NL]=TOOLKEY
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK BIOSCHAR[L0A00,NR,NL]=BIOSCHAR
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK BIOSVID[LD000,NR,NL]=BIOSVID
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK BIOSDISK[LD400,NR,NL]=BIOSDISK
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK CPMLDR[L1100,NL]=CPMLDR,LDRBIOS
# Use cmd to copy the binaries into a single file
Write-Host 'Merging for language card D000'
cmd /c copy BIOSVID.COM /b + BIOSDISK.COM /b + BIOSCHAR.COM /b D000.COM
Write-Host 'Comparing binaries for BOOTSECT'
fc.exe /b BOOTSECT.COM BOOTSECT.bin
Write-Host 'Comparing binaries for TOOLKEY'
fc.exe /b TOOLKEY.COM TOOLKEY.bin
Write-Host 'Comparing binaries for D000'
fc.exe /b D000.COM D000.bin
Write-Host 'Comparing binaries for CPMLDR'
fc.exe /b CPMLDR.COM CPMLDR.bin
