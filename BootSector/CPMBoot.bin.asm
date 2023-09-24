                   ********************************************************************************
                   * Cirtech Apple //e CP/M Plus boot sector disassembly                          *
                   *                                                                              *
                   * Disassembled by Peter Ibbotson.                                              *
                   *                                                                              *
                   * Boots from Disk ][, ProDOS driver and a Smart Port                           *
                   *                                                                              *
                   * Generated using 6502bench SourceGen v1.8.5                                   *
                   ********************************************************************************
                   SLOTX16         .eq     $01    {addr/1}   ;Boot slot times sixteen
                   SLOTX           .eq     $04    {addr/1}   ;SLOTX
                   ZP_PRODOS_CMD   .eq     $42               ;ProDOS command in zeropage
                   PD_DATA_BUFH    .eq     $45               ;Prodos Data buffer high byte
                   PD_BLOCK_NUM    .eq     $46               ;Prodos block number
                   DISKREADSECT    .eq     $c05c             ;ROM Disk read sector routine
                   IWM_PH0_OFF     .eq     $c080             ;IWM phase 0 off
                   ROMIN           .eq     $c081             ;RWx2 read ROM, write RAM bank 2
                   IWM_PH1_OFF     .eq     $c082             ;IWM phase 1 off
                   IWM_PH1_ON      .eq     $c083             ;IWM phase 1 on
                   LCBANK2         .eq     $c083             ;RWx2 read/write RAM bank 2
                   IWM_PH2_ON      .eq     $c085             ;IWM phase 2 on
                   LCBANK1         .eq     $c08b             ;RWx2 read/write RAM bank 1
                   MON_INIT        .eq     $fb2f             ;screen initialization
                   MON_PRERR       .eq     $ff2d             ;print "ERR" and sound bell
                   MON_SAVE        .eq     $ff4a             ;save 6502 registers to $45-49
                   MON_MONZ        .eq     $ff69             ;reset and enter monitor

                                   .addrs  $0800
0800: 01                           .dd1    $01               ;Disk II boot sector count to read
                   sect_to_read    .var    $00    {addr/1}   ;sector we're going to read
                   data_ptr        .var    $26    {addr/2}   ;Pointer to BOOT1 databuffer
                   rom_sect_to_read .var   $3d    {addr/1}   ;Disk II sector to read
                   track           .var    $41    {addr/1}   ;track to read

0801: 86 01                        stx     SLOTX16           ;Slot ($60 for disk ii in slot 6)
0803: 8a                           txa
0804: 4a                           lsr     A                 ;Divide by 16
0805: 4a                           lsr     A
0806: 4a                           lsr     A
0807: 4a                           lsr     A
0808: 85 04                        sta     SLOTX             ;Now we have slot number
080a: 09 c0                        ora     #$c0
080c: 8d 11 08                     sta     READCXFF+2
080f: ad ff c0     READCXFF        lda     $c0ff             ;Check for Disk II 16 sector?
0812: f0 03        DISKII_TEST     beq     DISKII_FOUND_INIT
0814: 4c 34 09                     jmp     IDCFOUND          ;Found Intelligent Disk Controller

                   ; This code runs on the first boot sector, we read in the second sector to $900
                   ; Presumably to mimic a Intelligent Disk Controller aka Smart Drive, which has 
                   ; a sector size of 512 bytes. We skip this code on future reads.
                   DISKII_FOUND_INIT
0817: 8a                           txa
0818: 18                           clc
0819: 69 04                        adc     #$04
081b: 8d b5 08                     sta     SLOTXPLUS4
081e: 38                           sec
081f: e9 08                        sbc     #$08
0821: 8d b6 08                     sta     SLOTXMINUS4
0824: ad 11 08                     lda     READCXFF+2        ;Get back CX slot
0827: 8d 91 08                     sta     JSRDISKIIREAD+2   ;Update rom address we want to call
                   ; This constant is SKIP_DISKII_INIT - (DISKII_TEST+2)
082a: a9 22                        lda     #$22              ;Alter jump to skip next time we run
082c: 8d 13 08                     sta     DISKII_TEST+1
082f: 20 a2 08                     jsr     CLRSCR_ENABLELANGCARD
0832: a9 00                        lda     #$00              ;We've read sector 0
0834: 85 00                        sta     sect_to_read
                   ; Future reads skip the code above and jump to here.
                   SKIP_DISKII_INIT
0836: e6 00                        inc     sect_to_read      ;Add one to our sect to read
0838: a5 00                        lda     sect_to_read
083a: a6 41                        ldx     track             ;Still on track 0?
083c: d0 0a                        bne     TRACK_READ_YET    ;Nope see if we've read the whole track
083e: c9 02                        cmp     #$02              ;Track 0 still, have read sector 1 yet?
0840: d0 06                        bne     TRACK_READ_YET
0842: 48                           pha                       ;So now we've read in sectors 0 and 1 
0843: a9 d0                        lda     #$d0              ;We can start reading into the language card
0845: 85 27                        sta     data_ptr+1
0847: 68                           pla
0848: c9 10        TRACK_READ_YET  cmp     #$10              ;Done the whole track yet?
084a: d0 3a                        bne     MAP_SECTOR_AND_READ
                   ; Assuming Disk II in slot 6
                   ; First time X=$60
                   ; Write to $C0E0 (C080,X) IWM_PH0_OFF ; left on by C600 ROM
                   ; Write to $C0E3 (C083,X) IWM_PH1_ON  
                   ; Delay
                   ; Write to $C0E2 (C082,X) IWM_PH1_OFF
                   ; Write to $C0E5 (C085,X) IWM_PH2_ON
                   ; Read a whole track
084c: a6 01                        ldx     SLOTX16
084e: a0 11                        ldy     #$11              ;Start loading in CPM stuff at $1100 (6520) 0100H Z80
0850: a5 41                        lda     track
0852: f0 09                        beq     READ_NEXT_TRK
0854: c9 01                        cmp     #$01              ;Track one read in?
0856: d0 78                        bne     COPY_VECTORS_FIND_Z80 ;Done track two, fire up Z80
                   ; Second time X=$64
                   ; Write to $C0E4 (C080,X) IWM_PH2_OFF ; left on by C600 ROM
                   ; Write to $C0E7 (C083,X) IWM_PH3_ON  
                   ; Delay
                   ; Write to $C0E6 (C082,X) IWM_PH3_OFF
0858: ae b5 08                     ldx     SLOTXPLUS4        ;Time to read track 2
085b: a4 27                        ldy     data_ptr+1
085d: 84 27        READ_NEXT_TRK   sty     data_ptr+1
085f: a9 00                        lda     #$00              ;Get sector zero
0861: 85 00                        sta     sect_to_read
0863: e6 41                        inc     track             ;Add one to the track
0865: bd 80 c0                     lda     IWM_PH0_OFF,x
0868: bd 83 c0                     lda     IWM_PH1_ON,x      ;Move the head half track
086b: a9 56                        lda     #$56              ;Sleep for a bit
086d: 38                           sec
086e: 48           DELAY1          pha
086f: e9 01        DELAY2          sbc     #$01
0871: d0 fc                        bne     DELAY2
0873: 68                           pla
0874: e9 01                        sbc     #$01
0876: d0 f6                        bne     DELAY1
0878: bd 82 c0                     lda     IWM_PH1_OFF,x     ;Turn off the stepper motor
087b: ec b5 08                     cpx     SLOTXPLUS4        ;Are we on track 1.5?
087e: d0 03                        bne     READTRK1
                   ; Third time X=$5C
                   ; Write to $C0E1 (C085,X) IWM_PH0_ON
                   ; Read a whole track
0880: ae b6 08                     ldx     SLOTXMINUS4       ;Time to go to track 2
0883: bd 85 c0     READTRK1        lda     IWM_PH2_ON,x      ;Another half track
                   MAP_SECTOR_AND_READ
0886: a4 00                        ldy     sect_to_read      ;Get the prodos(?) style sector
0888: b9 92 08                     lda     SECTORMAP,y       ;Convert it for the ROM
088b: 85 3d                        sta     rom_sect_to_read
088d: a6 01                        ldx     SLOTX16           ;Setup X register for ROM
088f: 4c 5c c0     JSRDISKIIREAD   jmp     DISKREADSECT      ;Read in the sector via ROM, reneter back at $801

0892: 00           SECTORMAP       .dd1    $00
0893: 02                           .dd1    $02
0894: 04                           .dd1    $04
0895: 06                           .dd1    $06
0896: 08                           .dd1    $08
0897: 0a                           .dd1    $0a
0898: 0c                           .dd1    $0c
0899: 0e                           .dd1    $0e
089a: 01                           .dd1    $01
089b: 03                           .dd1    $03
089c: 05                           .dd1    $05
089d: 07                           .dd1    $07
089e: 09                           .dd1    $09
089f: 0b                           .dd1    $0b
08a0: 0d                           .dd1    $0d
08a1: 0f                           .dd1    $0f

                   CLRSCR_ENABLELANGCARD
08a2: 20 2f fb                     jsr     MON_INIT          ;Clear 40 column etc
08a5: ad 0d c3                     lda     $c30d             ;Copy 80 column pascal init offset
08a8: 8d ac 08                     sta     JSR80COLINIT+1    ;Self modify so we can init the 80 column card
08ab: 20 00 c3     JSR80COLINIT    jsr     $c300
08ae: ad 8b c0                     lda     LCBANK1           ;Allow writes to language card
08b1: ad 8b c0                     lda     LCBANK1
08b4: 60                           rts

08b5: 00           SLOTXPLUS4      .dd1    $00
08b6: 00           SLOTXMINUS4     .dd1    $00
08b7: 28 43 29 20+ COPYRIGHT       .str    “(C) CIRTECH 1985 PAT PEND”

                   COPY_VECTORS_FIND_Z80
08d0: a0 1c                        ldy     #$1c
08d2: b9 0c 09     COPY_6502_LOOP  lda     VECTOR6502-1,y
08d5: 99 bf 03                     sta     $03bf,y
08d8: 88                           dey
08d9: d0 f7                        bne     COPY_6502_LOOP
08db: a0 0b                        ldy     #$0b
08dd: b9 28 09     COPY_Z80_LOOP   lda     VECTORZ80-1,y
08e0: 99 ff 0f                     sta     $0fff,y
08e3: 88                           dey
08e4: d0 f7                        bne     COPY_Z80_LOOP
08e6: a2 e7                        ldx     #$e7              ;Z80 card swap from Z80 side
08e8: a0 c7                        ldy     #$c7              ;Z80 card swap from 6502 side
08ea: 8e df 03     PATCH_VECT_LOOP stx     $03df             ;Patch back from Z80
08ed: 8c c8 03                     sty     $03c8             ;Patch go to Z80
08f0: 8c f5 08                     sty     TEST_Z80_CARD+2   ;Patch this test
08f3: 8d 00 c7     TEST_Z80_CARD   sta     $c700
08f6: ca                           dex
08f7: 88                           dey
08f8: 2c 00 10                     bit     $1000             ;Found the card?
08fb: f0 0d                        beq     START_Z80
08fd: c0 c0                        cpy     #$c0              ;Out of card slots?
08ff: d0 e9                        bne     PATCH_VECT_LOOP
0901: ad 81 c0     SHOW_ERROR      lda     ROMIN             ;Show an error message
0904: 20 2d ff                     jsr     MON_PRERR
0907: 4c 69 ff                     jmp     MON_MONZ

090a: 4c c0 03     START_Z80       jmp     $03c0

                   ; Jump code to and from the Z80
                   ; Copy this into $3C0 - $3DB
090d: ad 83 c0     VECTOR6502      lda     LCBANK2           ;$3C0
0910: ad 83 c0                     lda     LCBANK2           ;$3C3
0913: 8d 00 c4                     sta     $c400             ;$3C6 (Patched when Z80 card found)
0916: ad 81 c0                     lda     ROMIN             ;$3C9 Turn on ROM
0919: 20 8a 03                     jsr     $038a             ;$3cc restore 6502 regs (unclear how that gets in place)
091c: 20 00 00                     jsr     $0000             ;$3CF 6502 routine?
091f: 8d 81 c0                     sta     ROMIN             ;$3D2 STA so we don't overwrite it
0922: 78                           sei                       ;$3D5
0923: 20 4a ff                     jsr     MON_SAVE          ;$3D6 Save away the registers
0926: 4c c0 03                     jmp     $03c0             ;$3D9 Back to z80 land

0929: af           VECTORZ80       .dd1    $af               ;xor a
092a: 32                           .dd1    $32               ;xor ($0000),a
092b: 00                           .dd1    $00
092c: 00                           .dd1    $00
092d: 2a                           .dd1    $2a               ;ld hl,($F3DE) Card return address to 6502
092e: de                           .dd1    $de
092f: f3                           .dd1    $f3
0930: 77                           .dd1    $77               ;ld (hl),a
0931: c3                           .dd1    $c3               ;jp $1100
0932: 00                           .dd1    $00
0933: 11                           .dd1    $11

0934: 20 a2 08     IDCFOUND        jsr     CLRSCR_ENABLELANGCARD
0937: ad 11 08                     lda     READCXFF+2        ;Get back Cx00 slot
093a: 8d 7b 09                     sta     SMARTDRV_CALL+2   ;Patch up various things
093d: 8d 48 09                     sta     PD_ENTRY_PTR+2    ;Get the prodos driver entry point
0940: 8d 4b 09                     sta     SMART_DRV_CHK+2
0943: 8d bb 09                     sta     PD_CALL_DRIVER+2
0946: ac ff c0     PD_ENTRY_PTR    ldy     $c0ff             ;Get Prodos entry point
                   ; Can't quite figure this out Apple //c tech ref second edition
                   ; says this is for a ram card. ProDOS tech ref doesn't help either.
                   ; Possible large ram cards don't have ProDOS drivers so use a Smart
                   ; Drive interface instead?
0949: ad fb c0     SMART_DRV_CHK   lda     $c0fb             ;Check for smartdrv?
094c: 4a                           lsr     A
094d: 90 3a                        bcc     PRODOS_READ       ;Call via the ProDOS driver
                   ; Okay we've decided to use a smart port
094f: c8                           iny
0950: c8                           iny
0951: c8                           iny
0952: 8c 7a 09                     sty     SMARTDRV_CALL+1
0955: a9 d0                        lda     #$d0              ;Read in rest of track zero to $D000
0957: a2 0e                        ldx     #$0e
0959: a0 02                        ldy     #$02
095b: 20 70 09                     jsr     SMARTDRV_READ
095e: a9 11                        lda     #$11              ;Read in Tracks one and two to $1100
0960: a2 20                        ldx     #$20
0962: a0 10                        ldy     #$10
0964: 20 70 09                     jsr     SMARTDRV_READ
0967: a5 01                        lda     SLOTX16           ;Possibly used by BIOS code later on?
0969: 09 01                        ora     #$01              ;Some sort of flag?
096b: 85 01                        sta     SLOTX16
096d: 4c d0 08                     jmp     COPY_VECTORS_FIND_Z80

0970: 8d 83 09     SMARTDRV_READ   sta     SMART_BUF_PTR+1
0973: 8e 85 09                     stx     SMART_NUM_BYTES+1
0976: 8c 87 09                     sty     SMART_BLOCK_NUM+1
0979: 20 00 00     SMARTDRV_CALL   jsr     $0000
097c: 08                           .dd1    $08               ;Read command
097d: 80 09                        .dd2    SMARTDRV_PARAM
097f: 60                           rts

0980: 04           SMARTDRV_PARAM  .dd1    $04               ;Number of parameters
0981: 01                           .dd1    $01               ;Unit number 1
0982: 00 00        SMART_BUF_PTR   .dd2    $0000
0984: 00 00        SMART_NUM_BYTES .dd2    $0000
0986: 00           SMART_BLOCK_NUM .dd1    $00               ;Three bytes for the address
0987: 00                           .dd1    $00
0988: 00                           .dd1    $00

                   ; Read via ProDOS device driver
0989: 8c ba 09     PRODOS_READ     sty     PD_CALL_DRIVER+1
098c: a5 01                        lda     SLOTX16
098e: 8d d5 09                     sta     PRODOS_UNITNUM
0991: 09 0f                        ora     #$0f              ;Possibly used by BIOS code later on?
0993: 85 01                        sta     SLOTX16           ;Some sort of flags?
0995: a2 06                        ldx     #$06
0997: bd d4 09     PD_ZP_COPY      lda     PRODOS_CMD,x      ;Copy prodos command to zero page
099a: 95 42                        sta     ZP_PRODOS_CMD,x
099c: ca                           dex
099d: 10 f8                        bpl     PD_ZP_COPY
099f: a2 07                        ldx     #$07              ;Read in 7 ProDOS blocks
09a1: 8e cb 09                     stx     PD_ERR_COUNT
09a4: 8e ca 09                     stx     PD_BLOCK_COUNT
09a7: 20 b9 09                     jsr     PD_CALL_DRIVER
09aa: a9 11                        lda     #$11
09ac: 85 45                        sta     PD_DATA_BUFH
09ae: a9 10                        lda     #$10              ;Read in tracks one and two
09b0: 8d ca 09                     sta     PD_BLOCK_COUNT
09b3: 20 b9 09                     jsr     PD_CALL_DRIVER
09b6: 4c d0 08                     jmp     COPY_VECTORS_FIND_Z80

09b9: 20 00 00     PD_CALL_DRIVER  jsr     $0000             ;Call the prodos driver
09bc: b0 0e                        bcs     PD_ERROR_HANDLER
09be: e6 45                        inc     PD_DATA_BUFH      ;Increment the store address by 512
09c0: e6 45                        inc     PD_DATA_BUFH
09c2: e6 46                        inc     PD_BLOCK_NUM      ;Add one to the block number
09c4: ce ca 09                     dec     PD_BLOCK_COUNT
09c7: d0 f0                        bne     PD_CALL_DRIVER    ;Repeat until done
09c9: 60                           rts

09ca: 00           PD_BLOCK_COUNT  .dd1    $00
09cb: 00           PD_ERR_COUNT    .dd1    $00

                   PD_ERROR_HANDLER
09cc: ce cb 09                     dec     PD_ERR_COUNT
09cf: d0 e8                        bne     PD_CALL_DRIVER
09d1: 4c 01 09                     jmp     SHOW_ERROR

09d4: 01           PRODOS_CMD      .dd1    $01               ;Prodos command copied $42
09d5: 00           PRODOS_UNITNUM  .dd1    $00               ;Prodos unit number copied $43
09d6: 00 d0        PRODOS_BUFPTR   .dd2    $d000
09d8: 01 00        PRODOS_BLKNUM   .dd2    $0001
09da: 1a 1a 1a 1a+                 .fill   38,$1a
                                   .adrend ↑ $0800
