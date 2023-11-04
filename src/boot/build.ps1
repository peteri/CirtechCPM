# this uses NTVCM to run CP/M native tools
# it also uses the CtrlZ executable that will need a dotnet SDK installing
# This tool adds and removes CtrlZ at the end of the CP/M files
# to mark the end of file.
Write-Host 'Generating files for comparison'
dotnet run --project ..\..\tools\NibReader ../../DiskImages/BlankBootableCPM3.nib -nodiag
Write-Host 'Adding Ctrl-Z to source files'
dotnet run --project ..\..\tools\CtrlZ add LDRBIOS.MAC
dotnet run --project ..\..\tools\CtrlZ add BOOTSECT.MAC
dotnet run --project ..\..\tools\CtrlZ add TOOLKEY.MAC
Write-Host 'Assembling LDRBIOS'
C:\tools\ntvcm.exe ..\..\tools\ALDS\M80P.com =LDRBIOS
Write-Host 'Assembling BootSector'
C:\tools\ntvcm.exe ..\..\tools\ALDS\M80P.com =BOOTSECT
Write-Host 'Assembling BootSector'
C:\tools\ntvcm.exe ..\..\tools\ALDS\M80P.com =TOOLKEY
Write-Host 'Linking'
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK CPMLDR[L1100]=CPMLDR,LDRBIOS
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK BOOTSECT[NR,NL]=BOOTSECT
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK TOOLKEY[NR,NL]=TOOLKEY
Write-Host 'Removing Ctrl-Z from source files'
dotnet run --project ..\..\tools\CtrlZ remove LDRBIOS.MAC
dotnet run --project ..\..\tools\CtrlZ remove BOOTSECT.MAC
dotnet run --project ..\..\tools\CtrlZ remove TOOLKEY.MAC
Write-Host 'Comparing binaries'
fc.exe /b CPMLDR.COM CPMLDR.bin
fc.exe /b BOOTSECT.COM BOOTSECT.bin
fc.exe /b TOOLKEY.COM TOOLKEY.bin