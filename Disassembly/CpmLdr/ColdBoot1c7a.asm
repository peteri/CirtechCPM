1C7A: 0E 07       ld   c,$07
1C7C: 2E 05       ld   l,$05
1C7E: 7E          ld   a,(hl)
1C7F: FE 03       cp   $03
1C81: C2 04 1D    jp   nz,$1D04
1C84: 11 00 20    ld   de,$2000
1C87: 2E 01       ld   l,$01
1C89: 7E          ld   a,(hl)
1C8A: BA          cp   d
1C8B: 20 77       jr   nz,$1D04
1C8D: 2E 03       ld   l,$03
1C8F: CD 83 1F    call $1F83
1C92: 20 70       jr   nz,$1D04
1C94: 2E FF       ld   l,$FF
1C96: 7E          ld   a,(hl)
1C97: B7          or   a
1C98: 20 3C       jr   nz,$1CD6
1C9A: 2E 02       ld   l,$02
1C9C: E5          push hl
1C9D: CD 3E 1F    call $1F3E
1CA0: FD 21 BC 5D ld   iy,$5DBC
1CA4: 2E 04       ld   l,$04
1CA6: FD 7E 02    ld   a,(iy+$02)
1CA9: B7          or   a
1CAA: 28 0F       jr   z,$1CBB
1CAC: FE 03       cp   $03
1CAE: 28 16       jr   z,$1CC6
1CB0: 11 11 00    ld   de,$0011
1CB3: FD 19       add  iy,de
1CB5: 2D          dec  l
1CB6: 20 EE       jr   nz,$1CA6
1CB8: E1          pop  hl
1CB9: 18 49       jr   $1D04
1CBB: FD E5       push iy
1CBD: D1          pop  de
1CBE: 21 E9 1E    ld   hl,$1EE9
1CC1: 01 11 00    ld   bc,$0011
1CC4: ED B0       ldir
1CC6: CD 75 1E    call $1E75
1CC9: 38 ED       jr   c,$1CB8
1CCB: 21 DE 1E    ld   hl,$1EDE
1CCE: CB FE       set  7,(hl)
1CD0: CD 75 1E    call $1E75
1CD3: C3 72 1D    jp   $1D72
1CD6: FE FA       cp   $FA
1CD8: 30 2A       jr   nc,$1D04
1CDA: C6 03       add  a,$03
1CDC: 32 A9 1F    ld   ($1FA9),a
1CDF: 7C          ld   a,h
1CE0: D6 20       sub  $20
1CE2: 32 AA 1F    ld   ($1FAA),a
1CE5: 2D          dec  l
1CE6: 7E          ld   a,(hl)
1CE7: 47          ld   b,a
1CE8: E6 07       and  $07
1CEA: FE 07       cp   $07
1CEC: 20 16       jr   nz,$1D04
1CEE: 2E FB       ld   l,$FB
1CF0: CB 46       bit  0,(hl)
1CF2: 20 0A       jr   nz,$1CFE
1CF4: 0C          inc  c
1CF5: CB 78       bit  7,b
1CF7: C2 5B 1D    jp   nz,$1D5B
1CFA: 0C          inc  c
1CFB: C3 5B 1D    jp   $1D5B
1CFE: 2E 07       ld   l,$07
1D00: 7E          ld   a,(hl)
1D01: B7          or   a
1D02: 28 05       jr   z,$1D09
1D04: 0E 01       ld   c,$01
1D06: C3 3B 1C    jp   $1C3B
1D09: 2E FB       ld   l,$FB
1D0B: 7E          ld   a,(hl)
1D0C: FE A5       cp   $A5
1D0E: D9          exx
1D0F: 28 3C       jr   z,$1D4D
1D11: 3E 08       ld   a,$08
1D13: 21 02 32    ld   hl,$3202
1D16: 0E 00       ld   c,$00
1D18: CD 86 1F    call $1F86
1D1B: 21 00 F8    ld   hl,$F800
1D1E: 11 00 22    ld   de,$2200
1D21: 06 10       ld   b,$10
1D23: 1A          ld   a,(de)
1D24: BE          cp   (hl)
1D25: 20 06       jr   nz,$1D2D
1D27: 2C          inc  l
1D28: 1C          inc  e
1D29: 10 F8       djnz $1D23
1D2B: 18 2D       jr   $1D5A
1D2D: CD FA 1E    call $1EFA
1D30: 3E E5       ld   a,$E5
1D32: 21 00 22    ld   hl,$2200
1D35: 77          ld   (hl),a
1D36: 11 01 22    ld   de,$2201
1D39: 01 FF 1F    ld   bc,$1FFF
1D3C: ED B0       ldir
1D3E: 21 20 32    ld   hl,$3220
1D41: 0E 30       ld   c,$30
1D43: CD 89 1F    call $1F89
1D46: 0E 50       ld   c,$50
1D48: CD 91 1F    call $1F91
1D4B: 18 0D       jr   $1D5A
1D4D: 2A A9 1F    ld   hl,($1FA9)
1D50: 7D          ld   a,l
1D51: D6 0D       sub  $0D
1D53: 6F          ld   l,a
1D54: CD 98 1F    call $1F98
1D57: CD FA 1E    call $1EFA
1D5A: D9          exx
1D5B: 69          ld   l,c
1D5C: E5          push hl
1D5D: 79          ld   a,c
1D5E: 32 07 1E    ld   ($1E07),a
1D61: CD 3E 1F    call $1F3E
1D64: CD 77 1D    call $1D77
1D67: DA B8 1C    jp   c,$1CB8
1D6A: 21 DE 1E    ld   hl,$1EDE
1D6D: CB FE       set  7,(hl)
1D6F: CD 77 1D    call $1D77
1D72: E1          pop  hl
1D73: 4D          ld   c,l
1D74: C3 3B 1C    jp   $1C3B
1D77: 26 00       ld   h,$00
1D79: 2E FF       ld   l,$FF
1D7B: 6E          ld   l,(hl)
1D7C: CB AC       res  5,h
1D7E: 22 D0 F3    ld   ($F3D0),hl
1D81: 3A DE 1E    ld   a,($1EDE)
1D84: 32 43 F0    ld   ($F043),a
1D87: AF          xor  a
1D88: 32 42 F0    ld   ($F042),a
1D8B: 2A DE F3    ld   hl,($F3DE)
1D8E: 77          ld   (hl),a
1D8F: 3A 45 F0    ld   a,($F045)
1D92: FE 28       cp   $28
1D94: 2A 46 F0    ld   hl,($F046)
1D97: 37          scf
1D98: C8          ret  z
1D99: 11 18 00    ld   de,$0018
1D9C: B7          or   a
1D9D: ED 52       sbc  hl,de
1D9F: EB          ex   de,hl
1DA0: CB 3A       srl  d
1DA2: CB 1B       rr   e
1DA4: CB 3A       srl  d
1DA6: CB 1B       rr   e
1DA8: 7A          ld   a,d
1DA9: FE 10       cp   $10
1DAB: 38 08       jr   c,$1DB5
1DAD: CB 6F       bit  5,a
1DAF: 3E 10       ld   a,$10
1DB1: 28 02       jr   z,$1DB5
1DB3: CB D7       set  2,a
1DB5: CB 3F       srl  a
1DB7: CB 3F       srl  a
1DB9: CB 3F       srl  a
1DBB: F5          push af
1DBC: 3C          inc  a
1DBD: 47          ld   b,a
1DBE: CB 3A       srl  d
1DC0: CB 1B       rr   e
1DC2: 10 FA       djnz $1DBE
1DC4: 1B          dec  de
1DC5: ED 53 1C 1E ld   ($1E1C),de
1DC9: 6F          ld   l,a
1DCA: C6 04       add  a,$04
1DCC: 32 1F 1E    ld   ($1E1F),a
1DCF: 47          ld   b,a
1DD0: 3E 01       ld   a,$01
1DD2: CB 27       sla  a
1DD4: 10 FC       djnz $1DD2
1DD6: 3D          dec  a
1DD7: 32 53 1E    ld   ($1E53),a
1DDA: AF          xor  a
1DDB: BA          cp   d
1DDC: 20 01       jr   nz,$1DDF
1DDE: 3C          inc  a
1DDF: 45          ld   b,l
1DE0: 21 40 00    ld   hl,$0040
1DE3: 37          scf
1DE4: CB 17       rl   a
1DE6: 29          add  hl,hl
1DE7: 10 FA       djnz $1DE3
1DE9: 32 56 1E    ld   ($1E56),a
1DEC: 06 80       ld   b,$80
1DEE: F1          pop  af
1DEF: 30 04       jr   nc,$1DF5
1DF1: 29          add  hl,hl
1DF2: 37          scf
1DF3: CB 18       rr   b
1DF5: 2B          dec  hl
1DF6: 22 5D 1E    ld   ($1E5D),hl
1DF9: 78          ld   a,b
1DFA: 32 63 1E    ld   ($1E63),a
1DFD: 23          inc  hl
1DFE: CB 3C       srl  h
1E00: CB 1D       rr   l
1E02: CB 3C       srl  h
1E04: CB 1D       rr   l
1E06: 3E 00       ld   a,$00
1E08: FE 08       cp   $08
1E0A: 28 03       jr   z,$1E0F
1E0C: 21 00 80    ld   hl,$8000
1E0F: 7D          ld   a,l
1E10: 32 67 1E    ld   ($1E67),a
1E13: 7C          ld   a,h
1E14: 32 6A 1E    ld   ($1E6A),a
1E17: FD 21 BC 5D ld   iy,$5DBC
1E1B: 21 00 00    ld   hl,$0000
1E1E: 0E 00       ld   c,$00
1E20: 06 04       ld   b,$04
1E22: FD 7E 02    ld   a,(iy+$02)
1E25: B7          or   a
1E26: 28 20       jr   z,$1E48
1E28: B9          cp   c
1E29: 20 14       jr   nz,$1E3F
1E2B: FD 7E 05    ld   a,(iy+$05)
1E2E: BD          cp   l
1E2F: 20 0E       jr   nz,$1E3F
1E31: FD 7E 06    ld   a,(iy+$06)
1E34: BC          cp   h
1E35: 20 08       jr   nz,$1E3F
1E37: 3A 6A 1E    ld   a,($1E6A)
1E3A: FD BE 0C    cp   (iy+$0c)
1E3D: 28 36       jr   z,$1E75
1E3F: 11 11 00    ld   de,$0011
1E42: FD 19       add  iy,de
1E44: 10 DC       djnz $1E22
1E46: 37          scf
1E47: C9          ret
1E48: E5          push hl
1E49: FD E5       push iy
1E4B: E1          pop  hl
1E4C: 36 20       ld   (hl),$20
1E4E: 23          inc  hl
1E4F: 23          inc  hl
1E50: 71          ld   (hl),c
1E51: 23          inc  hl
1E52: 36 00       ld   (hl),$00
1E54: 23          inc  hl
1E55: 36 00       ld   (hl),$00
1E57: 23          inc  hl
1E58: D1          pop  de
1E59: CD 75 1C    call $1C75
1E5C: 11 00 00    ld   de,$0000
1E5F: CD 75 1C    call $1C75
1E62: 36 00       ld   (hl),$00
1E64: 23          inc  hl
1E65: 23          inc  hl
1E66: 36 00       ld   (hl),$00
1E68: 23          inc  hl
1E69: 36 00       ld   (hl),$00
1E6B: 23          inc  hl
1E6C: 36 03       ld   (hl),$03
1E6E: 23          inc  hl
1E6F: 23          inc  hl
1E70: 36 02       ld   (hl),$02
1E72: 23          inc  hl
1E73: 36 03       ld   (hl),$03
1E75: 2A 4D 1F    ld   hl,($1F4D)
1E78: 22 D5 1E    ld   ($1ED5),hl
1E7B: E5          push hl
1E7C: 11 19 00    ld   de,$0019
1E7F: 19          add  hl,de
1E80: CD 61 1F    call $1F61
1E83: 22 4D 1F    ld   ($1F4D),hl
1E86: E1          pop  hl
1E87: D8          ret  c
1E88: 11 0B 00    ld   de,$000B
1E8B: 19          add  hl,de
1E8C: 36 FF       ld   (hl),$FF
1E8E: 23          inc  hl
1E8F: FD E5       push iy
1E91: D1          pop  de
1E92: CD 75 1C    call $1C75
1E95: FD 4E 0B    ld   c,(iy+$0b)
1E98: FD 46 0C    ld   b,(iy+$0c)
1E9B: CB 78       bit  7,b
1E9D: 28 08       jr   z,$1EA7
1E9F: 36 00       ld   (hl),$00
1EA1: 23          inc  hl
1EA2: 36 00       ld   (hl),$00
1EA4: 23          inc  hl
1EA5: 18 04       jr   $1EAB
1EA7: CD 4C 1F    call $1F4C
1EAA: D8          ret  c
1EAB: FD 4E 05    ld   c,(iy+$05)
1EAE: FD 46 06    ld   b,(iy+$06)
1EB1: 03          inc  bc
1EB2: CB 38       srl  b
1EB4: CB 19       rr   c
1EB6: CB 38       srl  b
1EB8: CB 19       rr   c
1EBA: 03          inc  bc
1EBB: CD 4C 1F    call $1F4C
1EBE: D8          ret  c
1EBF: 11 2C 5E    ld   de,$5E2C
1EC2: CD 75 1C    call $1C75
1EC5: 11 88 6A    ld   de,$6A88
1EC8: CD 75 1C    call $1C75
1ECB: 11 FF FF    ld   de,$FFFF
1ECE: CD 75 1C    call $1C75
1ED1: 21 00 5E    ld   hl,$5E00
1ED4: 11 00 00    ld   de,$0000
1ED7: CD 75 1C    call $1C75
1EDA: 22 D2 1E    ld   ($1ED2),hl
1EDD: 3E 00       ld   a,$00
1EDF: 21 20 5E    ld   hl,$5E20
1EE2: 77          ld   (hl),a
1EE3: 23          inc  hl
1EE4: 22 E0 1E    ld   ($1EE0),hl
1EE7: B7          or   a
1EE8: C9          ret
1EE9: 20 00       jr   nz,$1EEB
1EEB: 03          inc  bc
1EEC: 07          rlca
1EED: 00          nop
1EEE: 8B          adc  a,e
1EEF: 00          nop
1EF0: 3F          ccf
1EF1: 00          nop
1EF2: C0          ret  nz
1EF3: 00          nop
1EF4: 10 00       djnz $1EF6
1EF6: 03          inc  bc
1EF7: 00          nop
1EF8: 01 01 3E    ld   bc,$3E01
1EFB: 09          add  hl,bc
1EFC: 0E 00       ld   c,$00
1EFE: 21 02 08    ld   hl,$0802
1F01: CD 86 1F    call $1F86
1F04: 0E 02       ld   c,$02
1F06: 21 0E D0    ld   hl,$D00E
1F09: CD 89 1F    call $1F89
1F0C: 0E 10       ld   c,$10
1F0E: 21 20 11    ld   hl,$1120
1F11: C3 89 1F    jp   $1F89
