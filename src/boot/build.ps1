# this uses NTVCM to run CP/M native tools
# it also uses the CtrlZ executable that will need a dotnet SDK installing
# This tool adds and removes CtrlZ at the end of the CP/M files
# to mark the end of file.
dotnet run ..\..\tools\CtrlZ add LDRBIOS.MAC
C:\tools\ntvcm.exe ..\..\tools\MS\M80.com =LDRBIOS/L
C:\tools\ntvcm.exe ..\..\tools\DRI\LINK CPMLDR[L1100]=CPMLDR,LDRBIOS
dotnet run ..\..\tools\CtrlZ remove LDRBIOS.MAC