# Source

## Tools required

Binaries for tools that run on CP/M are in the tools folder.
The Microsoft .net 8.0 SDK is need to build a tool used to add and remove CP/M Ctrl-Z from the source code.

NTVCM from https://github.com/davidly/ntvcm has been used to run the CP/M binaries under windows. 

## boot

`boot` contains code for the boot tracks, currently contains code for the `LDRBIOS.REL` which gets linked with `CPMLDR.REL` from DRI.
There are a few more items to be added but most of the code is now understood.
*Note* the sectors on the first three tracks are in ProDOS sector order.

|Track| Sectors | 6502 load address | Code |
|-----|---------|-------------------|------|
| 0   | 0-1     | `$0800` | initial 6502 boot sector. |
| 0   | 2-F     | `$D000` | 6502 BIOS code. |
| 1   | 0-C     | `$1100` | CCP.COM |
| 1   | D-F     | `$1E00` | Cirtech toolkit strings |
| 2   | 0-F     | `$2100` | CPMLDR.COM - CP/M loader loaded |

## cpm3bios

`cmp3bios` contains the source code to the main BIOS (or at least will do) along with the SPR files to build CPM3.SYS.
