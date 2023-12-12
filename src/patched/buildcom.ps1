#
# Helper to build a single utility COM file
# leaving behind a prn file.
# use -bin to output a XXX.BIN rather XXX.COM
#
param (
	[string]$filename,
	[switch]$bin
	)
C:\tools\ntvcm.exe ..\..\tools\ALDS\M80P.COM =$filename/R/L | Tee-Object -FilePath .\M80ERR.LOG
$errLog=(Get-Content -Path .\M80ERR.LOG)[-1]
if ($errLog -ne 'No Fatal Error(s)')
{	
    $errMsg="Error assembling $filename.MAC, examine M80ERR.LOG"
    throw $errMsg
}
Remove-Item -Path .\M80ERR.LOG
$outfile=$filename +'.COM'
if ($bin -eq $true)
{
    $outfile=$filename+".BIN"
}
$param=$script:outfile + '[NR,NL]=' + $filename
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK $param
Write-Host "Comparing binaries for $outfile"
$params=@('/b', ".`\$outfile", ".`\comparison`\$outfile")
Write-Host $params
fc.exe $params

