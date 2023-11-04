param ([string]$filename)
Write-Host "Compiling $filename.MAC"
dotnet run --project ..\..\tools\CtrlZ add "$filename.MAC"
C:\tools\ntvcm.exe ..\..\tools\ALDS\M80P.COM =$filename/R/L
dotnet run --project ..\..\tools\CtrlZ remove "$filename.MAC"