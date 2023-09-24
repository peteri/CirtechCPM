# Tracing the boot process..

We can run mame with this command line:

`mame apple2e -sl4 softcard -aux ext80 -flop1 <PathToDiskImages>\DiskImages\BlankBootableCPM3.nib -debug`

Pressing `F6` will run mame to the first Z80 access, at this point a regular CPMLDR is in memory at `$2100` (6502) and `1100H` (Z80). There seems to be code loaded in front of it at $1100, source code to a Caldera Inc branded version from the Unoffical CPM site original zip [here](http://www.cpm.z80.de/download/cpm3_src.zip)

We leave the original boot sector and have what looks like the 6502 bits of a BIOS in the language card at $D000 and the CPM Loader ready to run.

On the first change to the Z80 the $300 range looks like this in the mame debug windows

![6502 code](../images/300VectorsFirstTime.jpg)

Lets put a break point at $090a in the 6502 space

`090a: 4c c0 03     START_Z80       jmp     $03c0``
 
 Then hit `F5` to run that far.

## Apple II vectors

These are some Apple //e vectors in the $300-$3ff range. At this point we don't have code at $38a that
saves the 6502 registers. Time to figure out how it gets there and what our mini BIOS stuff does.

| Addr | Usage |
|------|-------|
| $3C0 | call Z80 |
| $3D0 | Address of 6502 routine to call |
| $3F0 | Break routine |
| $3F2 | Reset routine |
| $3F4 | Reset checksum |
| $3F5 | JMP to ampersand routine for AppleSoft |
| $3F8 | JMP to Ctrl-Y for monitor |
| $3FB | JMP for NMI |
| $3FE | IRQ vector |
