#
# Helper to build a single utility COM file
#
param ([string]$filename)
C:\tools\ntvcm.exe ..\..\tools\ALDS\M80P.COM =$filename/R/L | Tee-Object -FilePath .\M80ERR.LOG
$errLog=(Get-Content -Path .\M80ERR.LOG)[-1]
if ($errLog -ne 'No Fatal Error(s)')
{	
    $errMsg="Error assembling $filename.MAC, examine M80ERR.LOG"
    throw $errMsg
}
Remove-Item -Path .\M80ERR.LOG
$param=$fileName + '[NR,NL]=' + $filename
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK $param
Write-Host "Comparing binaries for $filename"
$params=@('/b', ".`\$fileName.COM", ".`\comparison`\$filename.COM")
Write-Host $params
fc.exe $params

