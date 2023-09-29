# Boot sector disassembly
Disassembly of the Apple //e boot sector for Cirtech CP/M Plus.

This uses [6502bench SourceGen](https://6502bench.com/) to disassemble the code.

## BootSectorPatched
Assembly code to copy the Apple Disk II boot ROM code into RAM, patch the boot code to load the first two sectors. Let the boot code run until it finds the Z80 card. This loads what looks like 6502 code into the language code and the CPMLDR code from DRI into $1100 in the 6502 memory space (0100H in the Z80 memory)

Once the code has run copy the language card into 6502 memory at $4000 so it's easier to work with.

Mame has quite good debugging tools for the Z80 and 6502 but this let me check on real hardware.

## Helpful links

[Prodos tech ref](https://prodos8.com/docs/techref/adding-routines-to-prodos/)

[Apple II Technical notes](https://www.1000bit.it/support/manuali/apple/technotes/tn.0.html)

[Apple //c Technical reference second edition](https://archive.org/details/AppleIIcTechnicalReference2ndEd/page/n241/mode/2up)

[Apple //e Technical reference] (https://archive.org/details/Apple_IIe_Technical_Reference_Manual/)

[Cirtech SCSI card](https://www.whatisthe2gs.apple2.org.za/files/CirtechSCSICard/Manual/Cirtech_SCSI_Interface_Card-Manual.pdf)

[Disk II boot](https://6502disassembly.com/a2-rom/C600ROM.html)

[DOS 3.3 boot](https://6502disassembly.com/a2-rom/BOOT1.html)

[Beneath Apple DOS / Prodos](https://archive.org/details/beneath-apple-dos-prodos-2020)