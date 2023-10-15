1F3E: 7C          ld   a,h
1F3F: 32 78 1D    ld   ($1D78),a
1F42: E6 0F       and  $0F
1F44: 0F          rrca
1F45: 0F          rrca
1F46: 0F          rrca
1F47: 0F          rrca
1F48: 32 DE 1E    ld   ($1EDE),a
1F4B: C9          ret
1F4C: 11 A8 6E    ld   de,$6EA8
1F4F: 73          ld   (hl),e
1F50: 23          inc  hl
1F51: 72          ld   (hl),d
1F52: 23          inc  hl
1F53: E5          push hl
1F54: EB          ex   de,hl
1F55: 09          add  hl,bc
1F56: CD 61 1F    call $1F61
1F59: EB          ex   de,hl
1F5A: E1          pop  hl
1F5B: D8          ret  c
1F5C: ED 53 4D 1F ld   ($1F4D),de
1F60: C9          ret
1F61: EB          ex   de,hl
1F62: 21 00 74    ld   hl,$7400
1F65: B7          or   a
1F66: ED 52       sbc  hl,de
1F68: EB          ex   de,hl
1F69: C9          ret
1F6A: CD 6F 1F    call $1F6F
1F6D: 50          ld   d,b
1F6E: 59          ld   e,c
1F6F: AF          xor  a
1F70: 6F          ld   l,a
1F71: 06 01       ld   b,$01
1F73: 86          add  a,(hl)
1F74: 30 01       jr   nc,$1F77
1F76: 04          inc  b
1F77: 2C          inc  l
1F78: 20 F9       jr   nz,$1F73
1F7A: 4F          ld   c,a
1F7B: C9          ret
1F7C: 2E 05       ld   l,$05
1F7E: 7E          ld   a,(hl)
1F7F: BA          cp   d
1F80: C0          ret  nz
1F81: 2E 07       ld   l,$07
1F83: 7E          ld   a,(hl)
1F84: BB          cp   e
1F85: C9          ret
1F86: 32 AB 1F    ld   ($1FAB),a
1F89: 7C          ld   a,h
1F8A: 32 B2 1F    ld   ($1FB2),a
1F8D: 7D          ld   a,l
1F8E: 32 B4 1F    ld   ($1FB4),a
1F91: 79          ld   a,c
1F92: 32 B6 1F    ld   ($1FB6),a
1F95: 21 A5 2F    ld   hl,$2FA5
1F98: 3E 04       ld   a,$04
1F9A: 32 48 F0    ld   ($F048),a
1F9D: 22 D0 F3    ld   ($F3D0),hl
1FA0: 2A DE F3    ld   hl,($F3DE)
1FA3: 77          ld   (hl),a
1FA4: C9          ret
1FA5: AD          xor  l
1FA6: 88          adc  a,b
1FA7: C0          ret  nz
1FA8: 20 00       jr   nz,$1FAA
1FAA: 00          nop
1FAB: 09          add  hl,bc
1FAC: AF          xor  a
1FAD: 2F          cpl
1FAE: 60          ld   h,b
1FAF: 04          inc  b
1FB0: 01 00 00    ld   bc,$0000
1FB3: 00          nop
1FB4: 00          nop
1FB5: 00          nop
1FB6: 00          nop
1FB7: 00          nop
1FB8: 79          ld   a,c
1FB9: 32 45 F0    ld   ($F045),a
1FBC: 3A 0F E3    ld   a,($E30F)
1FBF: 21 30 C3    ld   hl,$C330
1FC2: 22 46 F0    ld   ($F046),hl
1FC5: 6F          ld   l,a
1FC6: 18 D0       jr   $1F98
1FC8: 60          ld   h,b
1FC9: 69          ld   l,c
1FCA: C9          ret
1FCB: 3A 20 5E    ld   a,($5E20)
1FCE: 32 84 F3    ld   ($F384),a
1FD1: 21 A8 6E    ld   hl,$6EA8
1FD4: C9          ret
1FD5: 01 00 00    ld   bc,$0000
1FD8: 79          ld   a,c
1FD9: 32 80 F3    ld   ($F380),a
1FDC: 78          ld   a,b
1FDD: 32 86 F3    ld   ($F386),a
1FE0: C9          ret
1FE1: ED 43 F2 1F ld   ($1FF2),bc
1FE5: C9          ret
1FE6: 3E 01       ld   a,$01
1FE8: 32 88 F3    ld   ($F388),a
1FEB: 21 DC 03    ld   hl,$03DC
1FEE: CD 98 1F    call $1F98
1FF1: 11 00 00    ld   de,$0000
1FF4: 21 00 F8    ld   hl,$F800
1FF7: 01 00 02    ld   bc,$0200
1FFA: ED B0       ldir
1FFC: 3A 89 F3    ld   a,($F389)
1FFF: B7          or   a
2000: C8          ret  z
2001: 0E 07       ld   c,$07
2003: CD B8 1F    call $1FB8
2006: 3E 01       ld   a,$01
2008: C9          ret
2009: A9          xor  c
200A: C3 8D 00    jp   $008D
200D: 10 A9       djnz $1FB8
200F: 00          nop
2010: 8D          adc  a,l
2011: 01 10 A9    ld   bc,$A910
2014: 11 8D 02    ld   de,$028D
2017: 10 4C       djnz $2065
2019: C0          ret  nz
201A: 03          inc  bc
201B: 00          nop
201C: F4 80 F4    call p,$F480
201F: 00          nop
2020: F5          push af
2021: 80          add  a,b
2022: F5          push af
2023: 00          nop
2024: F6 80       or   $80
2026: F6 00       or   $00
2028: F7          rst  $30
2029: 80          add  a,b
202A: F7          rst  $30
202B: 28 F4       jr   z,$2021
202D: A8          xor  b
202E: F4 28 F5    call p,$F528
2031: A8          xor  b
2032: F5          push af
2033: 28 F6       jr   z,$202B
2035: A8          xor  b
2036: F6 28       or   $28
2038: F7          rst  $30
2039: A8          xor  b
203A: F7          rst  $30
203B: 50          ld   d,b
203C: F4 D0 F4    call p,$F4D0
