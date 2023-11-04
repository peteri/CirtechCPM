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
Write-Host 'Linking'
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK CPMLDR[L1100]=CPMLDR,LDRBIOS
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK BOOTSECT[NR,NL]=BOOTSECT
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK TOOLKEY[NR,NL]=TOOLKEY
Write-Host 'Comparing binaries'
fc.exe /b CPMLDR.COM CPMLDR.bin
fc.exe /b BOOTSECT.COM BOOTSECT.bin
fc.exe /b TOOLKEY.COM TOOLKEY.bin