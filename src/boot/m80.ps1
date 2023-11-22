param ([string]$filename)
Write-Host "Compiling $filename.MAC"
dotnet run --project ..\..\tools\CtrlZ add "$filename.MAC"
C:\tools\ntvcm.exe ..\..\tools\ALDS\M80P.COM =$filename/R | Tee-Object -FilePath .\M80ERR.LOG
dotnet run --project ..\..\tools\CtrlZ remove "$filename.MAC"
$errLog=(Get-Content -Path .\M80ERR.LOG)[-1]
if ($errLog -ne 'No Fatal Error(s)')
{
    throw "Error assembling $filename.MAC, examine M80ERR.LOG"
}
Remove-Item -Path .\M80ERR.LOG
