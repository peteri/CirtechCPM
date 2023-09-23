# Boot sector disassembly
Disassembly of the Apple //e boot sector for Cirtech CP/M Plus.

This uses [6502bench SourcGen](https://6502bench.com/) to disassemble the code.

## BootSectorPatched
Assembly code to copy the Apple Disk II boot ROM code into RAM, patch the boot code to load the first two sectors. Let the boot code run until it finds the Z80 card. This loads what looks like 6502 code into the language code and the CPMLDR code from DRI into $1100 in the 6502 memory space (0100H in the Z80 memory)

Once the code has run copy the language card into 6502 memory at $4000 so it's easier to work with.
