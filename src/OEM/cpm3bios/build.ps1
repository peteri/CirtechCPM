# this uses NTVCM to run CP/M native tools
# it also uses the CtrlZ executable that will need a dotnet SDK installing
# This tool adds and removes CtrlZ at the end of the CP/M files
# to mark the end of file.
Write-Host 'Generating files for comparison'
#dotnet run --project ..\..\tools\NibReader ../../DiskImages/BlankBootableCPM3.nib -nodiag
Write-Host 'Building files'
.\M80.ps1 SCB
.\M80.ps1 BIOS
Write-Host 'Linking'
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK BNKBIOS3[b]=BIOS,SCB
Write-Host 'Running GENCPM'
C:\tools\ntvcm.exe GENCPM AUTO DISPLAY
