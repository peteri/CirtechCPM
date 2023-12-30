# After building the system create a hdv file that mame can use.
# can be run with a command line like:
#  ./mame apple2ee -sl1 parallel -sl2 ssc -sl4 softcard -aux ext80  -sl7 cffa2 -hard1 {Path to repo}\src\patched\binaries\cpm3.hdv -debug
$systemFiles=@(
'binaries/CPM3.SYS',
'binaries/COPYSYS.COM',
'RomWBW/SET.COM',
'RomWBW/PUT.COM',
'RomWBW/RENAME.COM',
'RomWBW/PATCH.COM',
'binaries/SDT.COM',
'RomWBW/DATE.COM',
'RomWBW/PIP.COM',
'RomWBW/DEVICE.COM',
'system/PROFILE.SUB',
'RomWBW/SHOW.COM',
'RomWBW/DIR.COM',
'RomWBW/ERASE.COM',
'RomWBW/GET.COM',
'RomWBW/SETDEF.COM',
'RomWBW/SUBMIT.COM',
'RomWBW/TYPE.COM',
'binaries/START.COM'
)
$utilityFiles=@(
'RomWBW/HELP.COM',
'utility/HELP.HLP',
'RomWBW/ED.COM',
'binaries/MPATCH.COM',
'RomWBW/INITDIR.COM',
'RomWBW/GENCOM.COM',
'binaries/GPATCH.COM'
)
$buildFiles=@(
'../../tools/ALDS/M80.COM',
'../../tools/DRI/LINK.COM',
'gencpm/*.*',
'CPMLDR.REL',
'*.MAC'
'RomWBW/SUBMIT.COM',
'RomWBW\CCP.COM',
'BUILD.SUB'
)
Write-Host 'Create cpm3.hdv'
dotnet run --project ../../tools/CpmDsk -- create --disk-image binaries/cpm3.hdv --binaries-folder ./binaries --numblocks 10240
Write-Host 'Adding system files'
dotnet run --project ../../tools/CpmDsk -- add $systemFiles --disk-image binaries/cpm3.hdv
dotnet run --project ../../tools/CpmDsk -- add $utilityFiles --disk-image binaries/cpm3.hdv
Write-Host 'Creating build files in USER 1'
dotnet run --project ../../tools/CtrlZ -- add *.MAC BUILD.SUB
dotnet run --project ../../tools/CpmDsk -- add $buildFiles --disk-image binaries/cpm3.hdv --user 1
dotnet run --project ../../tools/CtrlZ -- remove *.MAC BUILD.SUB
