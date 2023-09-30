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
;==================================================================
; BIOS Func 16 - SECTRAN
; Translate sector
; Entry
; BC = Logical sector number
; DE = Address of translation table
; Exit
; HL = Physical sector number
;==================================================================
1FC8: 60          SECTRAN ld   h,b  ;Copy BC to HL as we don't translate
1FC9: 69                  ld   l,c
1FCA: C9                  ret
;==================================================================
; BIOS Func 9 - SELDSK
; Select the disc drive in register C 
; Entry
; C = Drive 0=A, 1=B....
; E = 0 or FFFFH, if Bit 0 is 1 disc has been logged before
;                 if Bit 0 is 0 disc is logged as if new
;                 can cause a disc read to figure out DPH from
;                 boot sector.
; Exit
; HL = Disk parameter Header
;==================================================================
1FCB: 3A 20 5E    SELDSK  ld   a,($5E20)
1FCE: 32 84 F3            ld   (DISK_DRV),a
1FD1: 21 A8 6E            ld   hl,$6EA8
1FD4: C9                  ret
;==================================================================
; BIOS Func 8 - HOME
; Move the current to track 0
; Entry
; Exit
;==================================================================
1FD5: 01 00 00    HOME    ld   bc,$0000  ;Set track to zero fall thru
;==================================================================
; BIOS Func 10 - SETTRK
; Set the track
; Entry
; BC = Track to set
; Exit
;==================================================================
1FD8: 79          SETTRK  ld   a,c
1FD9: 32 80 F3            ld   (DISK_TRKL),a
1FDC: 78                  ld   a,b
1FDD: 32 86 F3            ld   (DISK_TRKH),a
1FE0: C9                  ret
;==================================================================
; BIOS Func 12 - SETDMA
; Set the address next disc operation will use
; Entry
; BC = Address to read or write from
; Exit
;==================================================================
1FE1: ED 43 F2 1F SETDMA  ld   (READDST+1),bc ;Save address into read func
1FE5: C9                  ret
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
1FE8: 32 88 F3            ld   (DISK_OP),a
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
;==================================================================
; BIOS Func 11 - SETSEC
; Set the sector next disc operation will use
; Size is from the DPH
; Entry
; BC = Sector number
; Exit
;==================================================================
207F: 79          SETSEC  ld   a,c
2080: 32 81 F3            ld   (DISK_SECT),a
2083: C9                  ret
;==================================================================
; BIOS Func 25 - MOVE
; Copy memory (sadly wrong order for Z80)
; Entry
; BC = Number of bytes to move
; DE = Source address
; HL = Dest addresss
; Exit
;==================================================================
2084: EB          ex   de,hl
2085: ED B0       ldir
2087: EB          ex   de,hl
2088: C9          ret
