1B57: ED 73 73 1C ld   ($1C73),sp
1B5B: 31 16 21    ld   sp,$2116
1B5E: 21 00 0E    ld   hl,$0E00 ;Copy a bunch of Stuff
1B61: 11 00 FC    ld   de,$FC00 ;Looks like the Cirtech toolkit
1B64: 01 00 03    ld   bc,$0300 ;Text messages (6520 $0C00)
1B67: ED B0       ldir
1B69: 21 00 03    ld   hl,$0300
1B6C: 22 F2 F3    ld   ($F3F2),hl ;6502 reset vector
1B6F: 22 F0 F3    ld   ($F3F0),hl ;6502 break vector
1B72: 22 FC F3    ld   ($F3FC),hl ;NMI jump
1B75: 3E A6       ld   a,$A6      ;reset checksum
1B77: 32 F4 F3    ld   ($F3F4),a
; Setup jumps etc
1B7A: 3A DF F3    ld   a,($F3DF) ;Save card in Z80 land
1B7D: 2A C7 F3    ld   hl,($F3C7) ;Hi byte of Card address
1B80: D9          exx
1B81: 21 09 20    ld   hl,$2009 ;Copy a bunch of code
1B84: 11 00 F3    ld   de,$F300 ;into $300 plus probably
1B87: 01 ED 00    ld   bc,$00ED ;IO config block
1B8A: ED B0       ldir
1B8C: D9          exx
1B8D: 22 C7 F3    ld   ($F3C7),hl ;put back card address
1B90: 32 DF F3    ld   ($F3DF),a ;put back high byte of card
1B93: 3A 88 E0    ld   a,($E088);LC1 Bank RAM
1B96: 21 00 BC    ld   hl,$BC00 ;Copy from $DC00 language card
1B99: 11 00 FA    ld   de,$FA00 ;6502 destination $A00
1B9C: 01 00 02    ld   bc,$0200
1B9F: ED B0       ldir
1BA1: 21 BC 5D    ld   hl,$5DBC ;Clear a bunch of memory
1BA4: 36 00       ld   (hl),$00 ;$6DBC-$8400
1BA6: 11 BD 5D    ld   de,$5DBD ;or 5DBCH-7400H
1BA9: 01 44 16    ld   bc,$1644
1BAC: ED B0       ldir
1BAE: 21 20 5E    ld   hl,$5E20 ;No idea what we're doing here
1BB1: 22 E0 1E    ld   ($1EE0),hl
1BB4: 21 00 5E    ld   hl,$5E00
1BB7: 22 D2 1E    ld   ($1ED2),hl
1BBA: 21 A8 6E    ld   hl,$6EA8
1BBD: 22 4D 1F    ld   ($1F4D),hl
1BC0: 3E 05       ld   a,$05
1BC2: 21 2C 5E    ld   hl,$5E2C
1BC5: CD 14 1F    call $1F14
1BC8: 3E 01       ld   a,$01
1BCA: 21 88 6A    ld   hl,$6A88
1BCD: CD 14 1F    call $1F14
1BD0: 3A 04 F0    ld   a,($F004) ;boot slot 
1BD3: 5F          ld   e,a
1BD4: 16 00       ld   d,$00
1BD6: DD 21 B8 F3 ld   ix,$F3B8
1BDA: DD 19       add  ix,de
1BDC: F6 E0       or   $E0
1BDE: 67          ld   h,a
1BDF: 3E A0       ld   a,$A0
1BE1: 18 14       jr   $1BF7
1BE3: DD 21 BF F3 ld   ix,$F3BF
1BE7: 21 00 E7    ld   hl,$E700
1BEA: 3E E0       ld   a,$E0
1BEC: BC          cp   h
1BED: 28 54       jr   z,$1C43
1BEF: 3A 04 F0    ld   a,($F004)
1BF2: F6 E0       or   $E0
1BF4: BC          cp   h
1BF5: 3E A7       ld   a,$A7
1BF7: 32 42 1C    ld   ($1C42),a
1BFA: 28 42       jr   z,$1C3E
1BFC: CD 6A 1F    call $1F6A
1BFF: AF          xor  a
1C00: B8          cp   b
1C01: 28 08       jr   z,$1C0B
1C03: 79          ld   a,c
1C04: BB          cp   e
1C05: 20 04       jr   nz,$1C0B
1C07: 7A          ld   a,d
1C08: B8          cp   b
1C09: 28 04       jr   z,$1C0F
1C0B: 0E 00       ld   c,$00
1C0D: 18 2C       jr   $1C3B
1C0F: 0E 03       ld   c,$03
1C11: 11 38 18    ld   de,$1838
1C14: CD 7C 1F    call $1F7C
1C17: 28 22       jr   z,$1C3B
1C19: 0C          inc  c
1C1A: 11 18 38    ld   de,$3818
1C1D: CD 7C 1F    call $1F7C
1C20: 20 10       jr   nz,$1C32
1C22: 2E 0B       ld   l,$0B
1C24: 3E 01       ld   a,$01
1C26: BE          cp   (hl)
1C27: 20 12       jr   nz,$1C3B
1C29: 2C          inc  l
1C2A: 7E          ld   a,(hl)
1C2B: E6 F0       and  $F0
1C2D: F6 06       or   $06
1C2F: 4F          ld   c,a
1C30: 18 09       jr   $1C3B
1C32: 0C          inc  c
1C33: 11 48 48    ld   de,$4848
1C36: CD 7C 1F    call $1F7C
1C39: 20 3F       jr   nz,$1C7A
1C3B: DD 71 00    ld   (ix+$00),c
1C3E: DD 2B       dec  ix
1C40: 25          dec  h
1C41: 18 A0       jr   $1BE3
1C43: 32 05 E0    ld   ($E005),a ;Write to aux memory (48K)
1C46: AF          xor  a
1C47: 32 27 F0    ld   ($F027),a ;Store a zero in 6502?
1C4A: 11 00 F3    ld   de,$F300  ;Copy $300 to aux memory
1C4D: 62          ld   h,d
1C4E: 6B          ld   l,e
1C4F: 01 FF 08    ld   bc,$08FF
1C52: ED B0       ldir
1C54: 32 04 E0    ld   ($E004),a ; Back to main memory
1C57: 3E 04       ld   a,$04
1C59: 32 7E F4    ld   ($F47E),a
1C5C: AF          xor  a
1C5D: 32 FE F4    ld   ($F4FE),a
1C60: 3A 0D E3    ld   a,($E30D)  ; 80 column card init
1C63: CD BF 1F    call $1FBF
1C66: 21 BA 6E    ld   hl,$6EBA
1C69: 11 2E 5E    ld   de,$5E2E
1C6C: CD 75 1C    call $1C75
1C6F: 11 8A 6A    ld   de,$6A8A
1C72: 31 00 00    ld   sp,$0000
STORE_DE_TO_HL_ADDR:
1C75: 73          ld   (hl),e
1C76: 23          inc  hl
1C77: 72          ld   (hl),d
1C78: 23          inc  hl
1C79: C9          ret


1F14: 54          ld   d,h
1F15: 5D          ld   e,l
1F16: 13          inc  de
1F17: 13          inc  de
1F18: CD 75 1C    call STORE_DE_TO_HL_ADDR 
1F1B: CD 2D 1F    call $1F2D
1F1E: 23          inc  hl
1F1F: E5          push hl
1F20: 11 02 02    ld   de,$0202
1F23: 19          add  hl,de
1F24: EB          ex   de,hl
1F25: E1          pop  hl
1F26: CD 75 1C    call STORE_DE_TO_HL_ADDR
1F29: EB          ex   de,hl
1F2A: 3D          dec  a
1F2B: 20 EE       jr   nz,$1F1B
1F2D: 36 FF       ld   (hl),$FF
1F2F: 11 0A 00    ld   de,$000A
1F32: 19          add  hl,de
1F33: E5          push hl
1F34: D1          pop  de
1F35: 01 05 00    ld   bc,$0005
1F38: 09          add  hl,bc
1F39: EB          ex   de,hl
1F3A: CD 75 1C    call STORE_DE_TO_HL_ADDR
1F3D: C9          ret