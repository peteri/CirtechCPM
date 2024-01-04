# Disk Images
Various CP/M plus disks for the Cirtech Apple //e card (Probably work on the //c as well)

## BlankBootableCPM3.nib
Bootable disk for CP/M Plus with just CPM3.SYS on it. Works fine on real hardware but not in an emulator for some reason.

## CIRTECH CPM PLUS SYSTEM.DSK
Original Cirtech CP/M plus system disk for the Apple //e.
Files on the disk
```
Directory For Drive A:  User  0

    Name     Bytes   Recs   Attributes      Name     Bytes   Recs   Attributes 
------------ ------ ------ ------------ ------------ ------ ------ ------------
COPYSYS  COM     2k     10 Dir RW       CPM3     SYS    17k    134 Dir RW      
DATE     COM     3k     22 Dir RW       DEVICE   COM     8k     58 Dir RW      
DIR      COM    15k    114 Dir RW       ERASE    COM     4k     29 Dir RW      
GET      COM     7k     51 Dir RW       PATCH    COM     3k     19 Dir RW      
PIP      COM     9k     68 Dir RW       PROFILE  SUB     1k      1 Dir RW      
PUT      COM     7k     55 Dir RW       RENAME   COM     3k     23 Dir RW      
SDT      COM     2k     12 Dir RW       SET      COM    11k     81 Dir RW      
SETDEF   COM     4k     32 Dir RW       SHOW     COM     9k     66 Dir RW      
START    COM     1k      5 Dir RW       SUBMIT   COM     6k     42 Dir RW      
TYPE     COM     3k     24 Dir RW       system   trk    12k     96 Sys RO Arcv 

Total Bytes     =    127k  Total Records =     942  Files Found =   20
Total 1k Blocks =    127   Used/Max Dir Entries For Drive A:   21/  64
```

## CIRTECH CPM PLUS UTILITY.DSK
Original Cirtech CP/M plus utility disk for the Apple //e.

## 0030_Cirtech_CPM_Plus_System_Master.po
CP/M plus for the Apple, probably for the //GS doesn't boot on the Apple //e or emulators failing with a cannot find Z80 card error. Looks to be an 800K 3.5" floppy image. After creating a suitable partition on a CFFA card and copying the system using AdtPRO to a real Apple //e and booting the original Cirtech CP/M plus disk the directory has the following files:
```
Directory For Drive D:  User  0

    Name     Bytes   Recs   Attributes   Prot      Update          Create    
------------ ------ ------ ------------ ------ --------------  --------------

COPYSYS  COM     4k     15 Dir RW       None   05/09/87 14:20  05/09/87 14:20
CPM3     SYS    20k    134 Dir RW       None   08/20/87 09:30  05/20/87 11:20
DATE     COM     4k     23 Sys RW       None   05/11/87 14:02  05/11/87 14:02
DEVICE   COM     8k     58 Dir RW       None   03/24/87 00:00  03/24/87 00:00
DIR      COM    16k    114 Dir RW       None   03/24/87 00:00  03/24/87 00:00
DRIVES   COM     4k      3 Dir RW       None   03/24/87 00:00  03/24/87 00:00
DUMP     ASM     4k     32 Dir RW       None   03/25/87 00:00  03/25/87 00:00
DUMP     COM     4k      3 Dir RW       None   03/26/87 17:54  03/26/87 17:54
ED       COM    12k     73 Dir RW       None   03/24/87 00:00  03/24/87 00:00
ERASE    COM     4k     29 Dir RW       None   03/24/87 00:00  03/24/87 00:00
GENCOM   COM    16k    116 Dir RW       None   03/24/87 00:00  03/24/87 00:00
GET      COM     8k     51 Dir RW       None   03/24/87 00:00  03/24/87 00:00
GPATCH   COM     4k      3 Dir RW       None   06/08/87 10:54  06/08/87 10:54
HARDISK  COM     8k     36 Dir RW       None   06/08/87 10:37  06/08/87 10:37
HELP     COM     8k     56 Dir RW       None   03/24/87 00:00  03/24/87 00:00
HELP     HLP    76k    591 Dir RW       None   05/09/87 15:57  05/09/87 15:57
HEXCOM   COM     4k      9 Dir RW       None   03/24/87 00:00  03/24/87 00:00
HIST     UTL     4k     10 Dir RW       None   03/24/87 00:00  03/24/87 00:00
INITDIR  COM    32k    250 Dir RW       None   03/24/87 00:00  03/24/87 00:00
LIB      COM     8k     56 Dir RW       None   03/24/87 00:00  03/24/87 00:00
LINK     COM    16k    123 Dir RW       None   03/24/87 00:00  03/24/87 00:00
MAC      COM    12k     92 Dir RW       None   03/24/87 00:00  03/24/87 00:00
MANAGER  COM     8k     33 Dir RW       None   05/09/87 14:37  05/09/87 14:37
MPATCH   COM     4k      3 Dir RW       None   06/08/87 10:54  06/08/87 10:54
PATCH    COM     4k     19 Dir RW       None   03/24/87 00:00  03/24/87 00:00
PIP      COM    12k     68 Dir RW       None   03/24/87 00:00  03/24/87 00:00
PUT      COM     8k     55 Dir RW       None   03/24/87 00:00  03/24/87 00:00
RAMCALC  COM     4k     26 Dir RW       None   05/09/87 14:20  05/09/87 14:20
RENAME   COM     4k     23 Dir RW       None   03/24/87 00:00  03/24/87 00:00
RMAC     COM    16k    106 Dir RW       None   03/24/87 00:00  03/24/87 00:00
SAVE     COM     4k     14 Dir RW       None   03/24/87 00:00  03/24/87 00:00
SDT      COM     4k     12 Dir RW       None   03/24/87 00:00  03/24/87 00:00
SET      COM    12k     81 Dir RW       None   03/24/87 00:00  03/24/87 00:00
SETDEF   COM     4k     32 Dir RW       None   03/24/87 00:00  03/24/87 00:00
SETMOUSE COM     4k      7 Dir RW       None   03/24/87 00:00  03/24/87 00:00
SHOW     COM    12k     66 Dir RW       None   03/24/87 00:00  03/24/87 00:00
SID      COM     8k     62 Dir RW       None   03/24/87 00:00  03/24/87 00:00
SUBMIT   COM     8k     42 Dir RW       None   03/24/87 00:00  03/24/87 00:00
TRACE    UTL     4k     10 Dir RW       None   03/24/87 00:00  03/24/87 00:00
TYPE     COM     4k     24 Dir RW       None   03/24/87 00:00  03/24/87 00:00
XREF     COM    16k    121 Dir RW       None   03/24/87 00:00  03/24/87 00:00
Z80      LIB     8k     56 Dir RW       None   03/24/87 00:00  03/24/87 00:00
ZSID     COM    12k     80 Dir RW       None   03/24/87 00:00  03/24/87 00:00

Total Bytes     =    508k  Total Records =    3393  Files Found =   46
Total 1k Blocks =    444   Used/Max Dir Entries For Drive D:   66/ 128
```

## CIRTECH CPM V2 BOOT.DSK
Possible boot image created by booting the Apple //e version and using `COPYSYS.COM` from the 800K CP/M Plus image.

## buildcpm3.hdv
Image containing the source code and compiler to build the CP/M system directly on the Apple //e.

Can be run in mame using (assuming you have all the right ROMs): 
`mame apple2ee -sl1 parallel -sl2 ssc -sl4 softcard -aux ext80 -sl7 cffa2 -hard1 {PathTo}\DiskImages\buildcpm3.hdv`

_Note: AppleWin does not currently return the disk size in the X/Y registers when the ProDOS status call is made so Cirtech CP/M fails to run correctly when there is a hard disk setup._
