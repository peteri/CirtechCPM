#
$filename='MAPTEST'
C:\tools\ntvcm.exe ..\..\tools\ALDS\M80P.COM =$filename/R/L | Tee-Object -FilePath .\M80ERR.LOG
$errLog=(Get-Content -Path .\M80ERR.LOG)[-1]
if ($errLog -ne 'No Fatal Error(s)')
{	
    $errMsg="Error assembling $filename.MAC, examine M80ERR.LOG"
    throw $errMsg
}
Remove-Item -Path .\M80ERR.LOG
$outfile=$filename +'.COM'
$param=$script:outfile + '[NR,NL]=' + $filename
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK $param
dotnet run --project ../../tools/CpmDsk -- create --disk-image maptest.dsk --binaries-folder ../patched/binaries
dotnet run --project ../../tools/CpmDsk -- add '../patched/binaries/CPM3.SYS' 'MAPTEST.COM' --disk-image maptest.dsk --binaries-folder ../patched/binaries
