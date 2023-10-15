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

So how does the CPMLDR code work, there are a couple of interesting things we can look at, the CPMLDR code looks like this z80 mnemnomics with the 8080 ones in comments:
```
1100: 31 81 12 ld   sp,$1281    ;lxi	sp,stackbot
; first call is to Cold Boot
1103: CD 00 1B call $1B00   ;call	bootf
; Initialize the System
1106: 0E 0D    ld   c,$0D   ;mvi	c,resetsys
1108: CD 8D 12 call $128D   ;call	bdos
; print the sign on message
110B: 0E 09    ld   c,$09   ;mvi	c,printbuf
110D: 11 25 12 ld   de,$1225;lxi	d,signon
1110: CD 8D 12 call $128D   ;call	bdos
```

## BIOS vectors

The cold boot call at 1100H is to the start of the BIOS jump table, we can dump this out with `dasm SmallBIOSjumpTable.asm,1b00,57`

A lot of the jumps are 
```ld a,$00
ret
```
which is basically a null operation. The ones we're interested are defined at the end of the CPMLDR.ASM

```
1B00: C3 57 1B jp   $1B57 // 00. Cold boot
1B03: C3 57 1B jp   $1B57 // 01. Warm boot
1B0C: C3 B8 1F jp   $1FB8 // 04. console output function
1B18: C3 D5 1F jp   $1FD5 // 08. disk home function
1B1B: C3 CB 1F jp   $1FCB // 09. select disk function
1B1E: C3 D8 1F jp   $1FD8 // 10. set track function
1B21: C3 7F 20 jp   $207F // 11. set sector function
1B24: C3 E1 1F jp   $1FE1 // 12. set dma function
1B27: C3 E6 1F jp   $1FE6 // 13. read disk function
1B30: C3 C8 1F jp   $1FC8 // 16. sector translate
1B4B: C3 84 20 jp   $2084 // 25. memory move function
```

## Mini BIOS Disassembly

We can start to disassemble the BIOS functions, we should have some equates we can use
to help make things a bit clearer. (Note these have reversed out from the disassembly)

| 6502  | Z80    |Label      | Notes|
|-------|--------|-----------|------|
| $0045 | 0F045H | ACC_6502  | 6502 Acc |
| $0046 | 0F046H | X_6502    | 6502 X reg |
| $0047 | 0F047H | Y_6502    | 6502 Y reg |
| $0048 | 0F048H | FLAG_6502 | 6502 flag |
| $03D0 | 0F3D0H | ROUT_6502 | 6502 routine to call |
| $03DE | 0F3DEH | CARD_Z80  | Card address from Z80 0E401H|
| $0380 | 0F380H | DISK_TRKL | Disk track low |
| $0381 | 0F381H | DISK_SECT | Disk sector |
| $0384 | 0F384H | DISK_DRV  | Disk drive slot ($60) |
| $0385 | 0F385H | DISK_ACTD | Disk active drive |
| $0386 | 0F386H | DISK_TRKH | Disk track high |
| $0388 | 0F388H | DISK_OP   | Disk operation (set 1 by read) |
| $0389 | 0F389H | DISK_ERR  | Disk Result (0=OK) |
| $03DC |        | DISK_ROUT | Disk routine to call |

The mini BIOS functions have been disassembled into [MiniBIOS.ASM](MiniBIOS.ASM) most of the functions just take their parameters and store them into various locations for the 6502 to work on next.

## Console out

The console out function is a bit more interesting as it directly calls the 80 column card on the //e, it looks like this:

```
;==================================================================
; Call 6502 helper routine
; Entry
; HL=address to call
; Exit
;==================================================================
1F98: 3E 04       CALL6502 ld   a,$04         ;Set 6502 flags
1F9A: 32 48 F0             ld   (FLAG_6502),a ;Just Interrupts disabled
1F9D: 22 D0 F3             ld   (ROUT_6502),hl;Set our destination
1FA0: 2A DE F3             ld   hl,(CARD_Z80) ;Bounce off to 
1FA3: 77                   ld   (hl),a        ;6502 land
1FA4: C9                   ret
;==================================================================
; BIOS Func 5 - CONOUT
; Write character in to screen.
; Entry
; C = Character to write
;==================================================================
1FB8: 79          CONOUT  ld   a,c      ;character to output
1FB9: 32 45 F0            ld   (ACC_6502),a
1FBC: 3A 0F E3            ld   a,($E30F) ;80 column card out
1FBF: 21 30 C3            ld   hl,$C330  ;Set X=$30
1FC2: 22 46 F0            ld   ($F046),hl;Set Y=$C3
1FC5: 6F                  ld   l,a       ;HL=$C3XX
1FC6: 18 D0               jr   CALL6502
```

It reads the card entry pascal point from the $C300 (0E300H) ROM saves away the registers into the 6502 zero page then calls the 6502 which restores the registers and calls the 80 column card.

## Disk read

The other interesting routine is the disk read routine which looks like this:
```
;==================================================================
; BIOS Func 13 - READ
; Set the address next disc operation will use
; Entry
; Exit
; A = 0 for OK
;     1 for Unrecoverable error
;     FF if media changed.
;==================================================================
1FE6: 3E 01       READ    ld   a,$01
1FE8: 32 88 F3            ld   (DISK_OP),a ;Assumption here
1FEB: 21 DC 03            ld   hl,DISK_ROUT
1FEE: CD 98 1F            call CALL6502
1FF1: 11 00 00    READDST ld   de,$0000 ;Setup to copy result back
1FF4: 21 00 F8            ld   hl,$F800
1FF7: 01 00 02            ld   bc,$0200
1FFA: ED B0               ldir
1FFC: 3A 89 F3            ld   a,(DISK_ERR) ;Disk read result
1FFF: B7                  or   a         ;All ok?
2000: C8                  ret  z         ;Go home
2001: 0E 07               ld   c,$07     ;Ring the bell   
2003: CD B8 1F            call CONOUT
2006: 3E 01               ld   a,$01     ;Flag the error
2008: C9                  ret
```

This is fairly straight forward it just sets up to call the disk routine at $3D0
which calls the 6502 routine, copies the sector out of the buffer and checks to 
see if there was a disk error in which case it beeps at the user.

The 6502 code looks like this:
```
03DC: EA       nop
03DD: 2C 01 E4 bit $e401
03E0: 2C 8B C0 bit $c08b ; Language card LCBANK1
03E3: 2C 8B C0 bit $c08b ; Language card LCBANK1
03E6: D8       cld
03E7: 4C 00 D4 jmp $d400
```

Not entirely clear if the NOP and BIT at $3DC will be around for ever and why we're not just calling $03E0 or why the address is $E401 rather than $E400.
Anyway this code brings back LCBANK1 which has our 6502 code in it (the Z80 uses LCBANK2 for normal memory) and jumps off into $D400 which at this stage we assume is our disk routine.

Next stop is disassembling the 6502 code

## Disassembling the 6502 code

Again we're going to use [6502bench SourceGen](https://6502bench.com/) to disassemble the code. 

Highlights of the code will be put here afterwards.

### Terminal emulator

The code from $D000-$D3FF handles writing to the screen and emulates a Televideo 920 (I think) Weirdly it seems to be missing the Cursor Up sequence which should either be Ctrl-K (Currently clear to end of screen) or Ctrl-_ I'm not entirely sure why this is missing, there is more than enough space. There is also no code to deal with the Tab character which leaves me wondering if this is dealt with in some Z80 code?

The only really tricky piece of code is the bit that deals with Escape followed by either a single character code OR an `=` which is then followed by a Y and X character to form a GOTOYX sequence for the cursor. This has some comments around address $D013 to explain what's happening.

### Disk driver code

Disk driver is from $D400 - $DBFF
Buffer is $800-$9FF (512 bytes)

Currently the Smart Drive code is disassembled, ProDOS and regular RWTS code still has more work to do.

### Slot / Card driver
Code is copied in $A00-$BFF by the boot routine from $DC00

Looks like this deals with talking to the other cards (serial ports / printers etc)

