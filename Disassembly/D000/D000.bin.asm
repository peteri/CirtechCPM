                   ****************************************************************
                   * Disassembly of the D000 code loaded from disk                *
                   * by Cirtech CP/M plus for the Apple //e.                      *
                   *                                                              *
                   * Binary   (C) Copyright 1985 Cirtech                          *
                   * Comments (C) Copyright 2023 Peter Ibbotson                   *
                   * RWTS     (C) Copyright 1983 Apple                            *
                   *                                                              *
                   * Note for RWTS routine comments and labels from the Apple     *
                   * DOS3.3C source code PDF file has been used where the code    *
                   * matches.                                                     *
                   *                                                              *
                   * Disassembled using 6502bench SourceGen v1.8.5                *
                   ****************************************************************
                   DSKOP_RD        .eq     1      {const}    ;Disk operation read
                   DSKOP_FMT       .eq     3      {const}    ;Disk operation format
                   DSKOP_WRTRK     .eq     4      {const}    ;Disk operation write track
                   DSKOP_RDTRK     .eq     5      {const}    ;Disk operation read track
                   CHAR_OP_INI     .eq     $0d    {const}    ;Character IO Init (same as pascal offset)
                   CHAR_OP_RD      .eq     $0e    {const}    ;Character IO Read (same as pascal offset)
                   CHAR_OP_WR      .eq     $0f    {const}    ;Character IO Write (same as pascal offset)
                   CHAR_OP_ST      .eq     $10    {const}    ;Character IO Status (same as pascal offset)
                   SCRLINEL        .eq     $20               ;Address of current line in $400
                   SCRLINEH        .eq     $21               ;Screen address high
                   ESCAPE_STATE    .eq     $22               ;State for ESCAPE leadin
                   CURSOR_STATE    .eq     $23               ;Bit 7 high if cursor on screen
                   CURSORX         .eq     $25               ;Cursor X (80 col)
                   BLANKCH         .eq     $26               ;Blank character.
                   IDX             .eq     $26               ;READ16 - Index into (BUF).
                   LAST            .eq     $26               ;RDADR16 - 'Odd bit' nibls.
                   T0              .eq     $26               ;Temp for POSTNBL16
                   TRKCNT          .eq     $26               ;SEEK - Halftrks moved count.
                   WTEMP           .eq     $26               ;WRITE16 - Temp for data at Nbuf2,0.
                   CSUM            .eq     $27               ;RDADR16 - Checksum byte.
                   PRIOR           .eq     $27               ;SEEK - Prior halftrack.
                   SLOTZ           .eq     $27               ;WRITE16 - Slot num z-pag loc.
                   CURSORY         .eq     $29               ;Cursor Y (80 col)
                   TRKN            .eq     $2a               ;SEEK - desired track.
                   SLOTTEMP        .eq     $2b               ;SEEK - Slot num times $10
                   HEADER_CHECKSUM .eq     $2c               ;Checksum for the sector header
                   SECTOR          .eq     $2d               ;Sector from sector header
                   TRACK           .eq     $2e               ;Track from sector header
                   VOLUME          .eq     $2f               ;Volume from sector header
                   MON_INVFLAG     .eq     $32               ;text mask (255=normal, 127=flash, 63=inv)
                   DRIVNO          .eq     $35               ;Hi bit set if drive 2 for Disk II
                   MAXTRK          .eq     $3d               ;Maximum track for format
                   AA              .eq     $3e               ;WRADR16 - Timing constant
                   NSECT           .eq     $3f               ;WRADR16 - Sector number
                   NVOL            .eq     $41               ;WRADR16 - Volume number
                   PRODOS_CMD      .eq     $42               ;PRODOS - Command
                   PRODOS_UNITNUM  .eq     $43               ;PRODOS - Unit number
                   PRDOOS_BUFPTRL  .eq     $44               ;PRODOS - Buffer pointer low
                   TRK             .eq     $44               ;WRADR16 - Track number
                   NSYNC           .eq     $45               ;FORMAT - Num gap self-sync nibls.
                   MONTIMEL        .eq     $46               ;MSWAIT - Motor on time counter low
                   PRODOS_BLKNUM   .eq     $46               ;PRODOS - Block number
                   MONTIMEH        .eq     $47               ;MSWAIT - Motor on time counter high
                   DISK_TRKL       .eq     $0380             ;Disk track low (From Z80)
                   DISK_SECT       .eq     $0381             ;Disk sector (from Z80)
                   DISK_TRK_ADDR   .eq     $0382             ;While track read/write page
                   DISK_DRV        .eq     $0384             ;Drive to use from CPM (Slot)
                   DISK_ACTD       .eq     $0385             ;Current active disk ][ drive
                   DISK_TRKH       .eq     $0386             ;Disk track high (from Z80)
                   DISK_VOL        .eq     $0387             ;Disk volume
                   DISK_OP         .eq     $0388             ;Disk operation
                   DISK_ERR        .eq     $0389             ;Disk Error back
                   SLOT_INFO       .eq     $03b8             ;Map of slot to card type
                   CURTRK          .eq     $0478             ;SEEK - Current track on entry
                   DRV1TRK         .eq     $0478             ;Drive 1 track
                   DRV2TRK         .eq     $04f8             ;Drive 2 track
                   SEEKCNT         .eq     $04f8             ;# Reseeks before recalibrate
                   RETRYCNT        .eq     $0578             ;Retry counter
                   STSBYTE         .eq     $05b8             ;SSC Char
                   DISKSLOTCX      .eq     $05f8             ;Disk slot $60
                   SLOTABS         .eq     $0678             ;WRITE16 - Slot num non-z-pag loc.
                   RECALCNT        .eq     $06f8             ;# Recalibrates -1
                   DISK_BUFF       .eq     $0800             ;Disk buffer
                   SET80COL        .eq     $c001             ;W use PAGE2 for aux mem (80STOREON)
                   SET80VID        .eq     $c00d             ;W enable 80-column display mode
                   SETALTCHAR      .eq     $c00f             ;W use alternate char set
                   SPKR            .eq     $c030             ;RW toggle speaker
                   TXTPAGE1        .eq     $c054             ;RW display page 1
                   TXTPAGE2        .eq     $c055             ;RW display page 2 (or read/write aux mem)
                   IWM_PH0_OFF     .eq     $c080             ;IWM phase 0 off
                   PARA_DATAOUT    .eq     $c080             ;Apple parallel card data out.
                   IWM_MOTOR_OFF   .eq     $c088             ;IWM motor off
                   IWM_MOTOR_ON    .eq     $c089             ;IWM motor on
                   IWM_DRIVE_1     .eq     $c08a             ;IWM select drive 1
                   IWM_DRIVE_2     .eq     $c08b             ;IWM select drive 2
                   LCBANK1         .eq     $c08b             ;RWx2 read/write RAM bank 1
                   IWM_Q6_OFF      .eq     $c08c             ;IWM read
                   IWM_Q6_ON       .eq     $c08d             ;IWM WP-sense
                   IWM_Q7_OFF      .eq     $c08e             ;IWM WP-sense/read
                   STATUS6510      .eq     $c08e             ;Status for 6510 based serial card
                   DATA6510        .eq     $c08f             ;Data for 6510 based serial card
                   IWM_Q7_ON       .eq     $c08f             ;IWM write
                   PARA_ACKIN      .eq     $c0c1             ;Apple parallel card acknowledge status
                   SCC_INIT        .eq     $c800             ;Super serial card init
                   SSC_READ        .eq     $c84d             ;Super serial card read routine
                   SSC_WRITE       .eq     $c9aa             ;Super serial card write routine
                   CLRROM          .eq     $cfff             ;disable slot C8 ROM
                   NBUF1           .eq     $de00             ;Six bit data bytes
                   NBUF2           .eq     $df00             ;56 bytes of 2 bit data
                   FOUND           .eq     $df57             ;Table of found sectors during format
                   D2SAVWRDTAPG    .eq     $df67             ;Disk II save write data page
                   D2SAVRDDTAPG    .eq     $df68             ;Disk II save read page
                   D2SAVETRAN      .eq     $df69  {addr/2}   ;Disk II save sector translation

                   ********************************************************************************
                   *                                                                              *
                   * Routines to handle the 80 Column card                                        *
                   *                                                                              *
                   ********************************************************************************
                                   .addrs  $d000
d000: 4c 1a d1     TOG_CURJMP      jmp     POP_TOGGLE_CURSOR

                   PRINT_STACK_CHAR
d003: 68                           pla                       ;Get our character off the stack
d004: 09 80        PRINT_CHAR      ora     #$80              ;Set the high bit
d006: 24 22                        bit     ESCAPE_STATE
d008: 10 2e                        bpl     CHECK_ESC_CHAR1   ;Bit 7 clear check for escape
d00a: 2c a5 d3                     bit     GOTO_Y            ;Goto YX, Y Character set yet?
d00d: 30 04                        bmi     GOTO_YX           ;Must be the X postion now we can move the  cursor
d00f: 8d a5 d3                     sta     GOTO_Y            ;Setting the Y character
d012: 60                           rts

                   ; There is a fairly complicated state machine here
                   ; ESCAPE_STATE 
                   ;   Bit 7 0=no escape seen
                   ;   Bit 6 0=Possible normal character
                   ;   Bit 6 1=Escape seen
                   ;   Bit 7 1=Waiting for Y position
                   ; GOTOY
                   ;   Bit 7 0=Not yet seen Y
                   ;   Bit 7 1=Seen Y coord, other bits are Y character.
                   ; 
                   ; So for a <ESC> C where C is a single character escape state goes through
                   ; |Escape state| GOTOY     | 
                   ; |------------|-----------|
                   ; | 00zz zzzz  | 0yyy yyyy | Waiting for escape
                   ; | 01zz zzzz  | 0yyy yyyy | Escape seen waiting next char
                   ; | 00zz zzzz  | 0yyy yyyy | <Esc> C seen C converted to regular ctrl character
                   ; 
                   ; However for <ESC> = Y X (goto Y X) the states are as follows
                   ; |Escape state| GOTOY     | 
                   ; |------------|-----------|
                   ; | 00zz zzzz  | 0yyy yyyy | Waiting for escape
                   ; | 01zz zzzz  | 0yyy yyyy | Escape seen waiting next char
                   ; | 11zz zzzz  | 0yyy yyyy | <Esc> = seen waiting Y coord
                   ; | 11zz zzzz  | 1yyy yyyy | <Esc> = Y seen waiting X Coord
                   ; | 00zz zzzz  | 0yyy yyyy | <Esc> = Y X seen cursor moved to correct pos
                   ; 
d013: 20 31 d3     GOTO_YX         jsr     HIDE_CURSOR
d016: 38                           sec
d017: e9 a0                        sbc     #$a0              ;Subtract space
d019: c9 50                        cmp     #80               ;Okay are we on screen?
d01b: 90 02                        bcc     CURSORX_OK        ;Bigger than screen
d01d: a9 00                        lda     #$00              ;Zero cursor
d01f: 85 25        CURSORX_OK      sta     CURSORX           ;Save away X position
d021: ad a5 d3                     lda     GOTO_Y            ;Get the Y Coord
d024: 38                           sec
d025: e9 a0                        sbc     #$a0
d027: c9 18                        cmp     #24
d029: 90 02                        bcc     CURSORY_OK
d02b: a9 00                        lda     #$00
d02d: 85 29        CURSORY_OK      sta     CURSORY
d02f: 20 0d d1                     jsr     SET_LINE_PTR
d032: a0 00                        ldy     #$00
d034: 84 22                        sty     ESCAPE_STATE
d036: f0 55                        beq     SHOW_CURSOR

d038: 50 03        CHECK_ESC_CHAR1 bvc     CHECK_FOR_ESC
d03a: 4c d9 d0                     jmp     ESCAPE_CHAR1

d03d: c9 9b        CHECK_FOR_ESC   cmp     #$9b
d03f: d0 05                        bne     CTRL_WRITE_SCR
d041: a9 40                        lda     #$40
d043: 85 22                        sta     ESCAPE_STATE
d045: 60                           rts

                   ; Come here to write a character to screen
                   ; and handle control characters
d046: c9 a0        CTRL_WRITE_SCR  cmp     #$a0
d048: 90 6c                        bcc     TEST_CONTROL_CHAR ;Go off and deal with a control character
d04a: aa                           tax                       ;Save A for later
d04b: a5 25                        lda     CURSORX           ;Get the current cursor
d04d: 4a                           lsr     A                 ;Divide by two
d04e: b0 03                        bcs     WRITE_ODD         ;Was it odd
d050: 2c 55 c0                     bit     TXTPAGE2          ;If so write to the odd columns
d053: a8           WRITE_ODD       tay                       ;Save CursorX/2 -> Y
d054: 8a                           txa                       ;Get back our character
d055: 25 32                        and     MON_INVFLAG       ;Are we in inverse mode?
d057: 30 0a                        bmi     STORE_TO_SCREEN
d059: c9 60                        cmp     #$60              ;Inverse lowercase?
d05b: b0 06                        bcs     STORE_TO_SCREEN   ;No change needed
d05d: c9 40                        cmp     #$40              ;Inverse Numbers or punctuation?
d05f: 90 02                        bcc     STORE_TO_SCREEN   ;No Change needed
d061: 29 bf                        and     #$bf              ;Convert uppercase out of mouse text
d063: 91 20        STORE_TO_SCREEN sta     (SCRLINEL),y      ;Write character to screen
d065: 2c 54 c0                     bit     TXTPAGE1          ;Back to main text page
d068: e6 25                        inc     CURSORX           ;Move cursor to right
d06a: a5 25                        lda     CURSORX
d06c: c9 50                        cmp     #80               ;Cursor still on screen?
d06e: 90 1d                        bcc     SHOW_CURSOR       ;Go show it.
d070: a9 00                        lda     #$00              ;Set us to back to column zero
d072: 85 25                        sta     CURSORX
d074: e6 29                        inc     CURSORY           ;Move down a line
d076: a4 29                        ldy     CURSORY
d078: c0 18                        cpy     #24               ;Still on screen?
d07a: 90 05                        bcc     NO_SCROLL         ;Yep don't scroll
d07c: c6 29                        dec     CURSORY           ;Correct us
d07e: 20 f4 d1                     jsr     SCROLL_UP         ;Scroll the screen up
d081: a4 29        NO_SCROLL       ldy     CURSORY
d083: b9 69 d3                     lda     LINE_STARTH,y     ;Set up the current screen line pointer
d086: 85 21                        sta     SCRLINEH
d088: b9 81 d3                     lda     LINE_STARTL,y
d08b: 85 20                        sta     SCRLINEL
d08d: a9 80        SHOW_CURSOR     lda     #$80
d08f: 85 23                        sta     CURSOR_STATE      ;Set the cursor to on
d091: a5 25        FLIP_INVERTED   lda     CURSORX           ;Get cursor position
d093: 4a                           lsr     A
d094: b0 03                        bcs     CURSOR_PAGE1      ;Which page?
d096: 2c 55 c0                     bit     TXTPAGE2
d099: a8           CURSOR_PAGE1    tay                       ;Cursor divided by two to Y
d09a: b1 20                        lda     (SCRLINEL),y      ;Get the current character on screen
d09c: c9 20                        cmp     #$20              ;Is it an inverse Uppercase
d09e: b0 02                        bcs     INVERT_CHAR       ;If not just go and do invert
d0a0: 09 40                        ora     #$40              ;Put back bit 6 so it's a proper Uppercase
d0a2: 49 80        INVERT_CHAR     eor     #$80              ;Invert the character
d0a4: 30 0a                        bmi     STORE_CURSOR      ;Store if it's normal
d0a6: c9 60                        cmp     #$60              ;Lower case inverted
d0a8: b0 06                        bcs     STORE_CURSOR      ;Store it
d0aa: c9 40                        cmp     #$40              ;Inverse Numbers or punctuation?
d0ac: 90 02                        bcc     STORE_CURSOR      ;We're good store it
d0ae: 29 bf                        and     #$bf              ;Upper case letters, kill bit 6
d0b0: 91 20        STORE_CURSOR    sta     (SCRLINEL),y      ;Store on screen
d0b2: 2c 54 c0                     bit     TXTPAGE1          ;Back to text page 1
d0b5: 60           IGNORE_CHAR     rts                       ;Also used in jump table

                   ; Handle a possible control character
                   TEST_CONTROL_CHAR
d0b6: c9 9e                        cmp     #$9e              ;Off the end of the table
d0b8: b0 fb                        bcs     IGNORE_CHAR       ;Ignore it
d0ba: c9 87                        cmp     #$87              ;Off the front of the table
d0bc: 90 f7                        bcc     IGNORE_CHAR       ;Ignore it
                   HANDLE_CONTROL_CHAR
d0be: 20 31 d3                     jsr     HIDE_CURSOR
d0c1: 38                           sec
d0c2: e9 87                        sbc     #$87              ;Subtract Bell character
d0c4: 0a                           asl     A                 ;Mult by 2 for table index
d0c5: a8                           tay
d0c6: b9 3b d3                     lda     CTRL_CHAR_TAB,y   ;Lookup the entry and modify jump
d0c9: 8d d4 d0                     sta     CTRL_CHAR_JSR+1
d0cc: c8                           iny
d0cd: b9 3b d3                     lda     CTRL_CHAR_TAB,y
d0d0: 8d d5 d0                     sta     CTRL_CHAR_JSR+2
d0d3: 20 00 00     CTRL_CHAR_JSR   jsr     $0000             ;Jump to control handler
d0d6: 4c 8d d0                     jmp     SHOW_CURSOR

d0d9: a0 00        ESCAPE_CHAR1    ldy     #$00              ;First character in escape sequence
d0db: 84 22                        sty     ESCAPE_STATE
d0dd: c9 bd                        cmp     #‘=’ | $80        ;Goto YX command?
d0df: f0 0d                        beq     GOTO_YX_CMD       ;Yes it is
                   ; Convert any of the single character escape codes
d0e1: a0 05                        ldy     #$05
                   FIND_ESC_CHAR_LOOP
d0e3: d9 99 d3                     cmp     ESC_CTRL_CODES,y  ;Is it in the table?
d0e6: f0 0e                        beq     FOUND_ESC_CHAR    ;Yes it is do something
d0e8: 88                           dey
d0e9: 10 f8                        bpl     FIND_ESC_CHAR_LOOP
d0eb: 4c 04 d0                     jmp     PRINT_CHAR

d0ee: 38           GOTO_YX_CMD     sec                       ;Set the high bit so say we're waiting for Y
d0ef: 66 22                        ror     ESCAPE_STATE
d0f1: 18                           clc
d0f2: 6e a5 d3                     ror     GOTO_Y            ;Clear bit 7 (Seen Y coord)
d0f5: 60                           rts

d0f6: b9 9f d3     FOUND_ESC_CHAR  lda     ESC_CHAR_TRANS,y  ;Get the regular Ctrl code
d0f9: d0 c3                        bne     HANDLE_CONTROL_CHAR
                   ; Carriage return
d0fb: a9 00        CARRIAGE_RET    lda     #$00
d0fd: 85 25                        sta     CURSORX
d0ff: 60                           rts

                   ; Line feed for 80 column
d100: e6 29        LINEFEED        inc     CURSORY
d102: a4 29                        ldy     CURSORY
d104: c0 18                        cpy     #24               ;Last line?
d106: 90 05                        bcc     SET_LINE_PTR      ;Nope just set the line pointer
d108: c6 29                        dec     CURSORY           ;Backup the cursor
d10a: 20 f4 d1                     jsr     SCROLL_UP         ;Scroll up
d10d: a4 29        SET_LINE_PTR    ldy     CURSORY           ;Lookup new line pointer
d10f: b9 69 d3                     lda     LINE_STARTH,y
d112: 85 21                        sta     SCRLINEH          ;And save it away
d114: b9 81 d3                     lda     LINE_STARTL,y
d117: 85 20                        sta     SCRLINEL
d119: 60                           rts

                   POP_TOGGLE_CURSOR
d11a: 68                           pla                       ;Pop unwanted parameter
d11b: a5 23        TOGGLE_CURSOR   lda     CURSOR_STATE      ;Flip the cursor state
d11d: 49 80                        eor     #$80
d11f: 85 23                        sta     CURSOR_STATE
d121: 4c 91 d0                     jmp     FLIP_INVERTED     ;Flip the character on screen inverse state

                   ; Backspace
d124: c6 25        BACKSPACE       dec     CURSORX           ;Decrement the cursor position
d126: 30 01                        bmi     OFF_LEFT          ;Off left hand of screen?
d128: 60                           rts                       ;Go Home still on screen

d129: a9 4f        OFF_LEFT        lda     #79               ;Right hand edge of screen
d12b: 85 25                        sta     CURSORX
d12d: c6 29                        dec     CURSORY           ;Back up a line
d12f: 10 dc                        bpl     SET_LINE_PTR      ;Still on screen set pointer
d131: a9 00                        lda     #$00
d133: 85 29                        sta     CURSORY           ;Top line of screen
d135: 20 f5 d1                     jsr     SCROLL_CARRY_FLAG ;Scroll depending on state of carry flage
d138: 4c 0d d1                     jmp     SET_LINE_PTR

                   ; Cursor Right
d13b: e6 25        CURSOR_RIGHT    inc     CURSORX           ;Add one to cursor position
d13d: a5 25                        lda     CURSORX
d13f: c9 50                        cmp     #80               ;Off right hand edge
d141: b0 01                        bcs     OFF_RIGHT
d143: 60                           rts                       ;Nope go home

d144: 20 fb d0     OFF_RIGHT       jsr     CARRIAGE_RET      ;Off right hand edge Set to 0
d147: 4c 00 d1                     jmp     LINEFEED          ;and down a line

                   ; Clear line
d14a: a9 00        CLR_LINE        lda     #$00              ;Set us to be at the beginning of the line
d14c: 85 25                        sta     CURSORX
d14e: 4c 9c d1                     jmp     CLR_EOL           ;Now clear to EOL

                   ; Home
d151: a0 00        HOME            ldy     #$00              ;Set Cursor X,Y to 0,0
d153: 84 25                        sty     CURSORX
d155: 84 29                        sty     CURSORY
d157: 4c 0d d1                     jmp     SET_LINE_PTR      ;Set the current line pointer

                   ; Clear to end of screen
d15a: 20 9c d1     CLR_TO_ENDSCR   jsr     CLR_EOL
d15d: a5 20                        lda     SCRLINEL          ;Save away current screen position
d15f: 48                           pha
d160: a5 21                        lda     SCRLINEH
d162: 48                           pha
d163: a6 29                        ldx     CURSORY           ;Get line number
d165: e8           CLR_NEXT_LINE   inx
d166: e0 18                        cpx     #24
d168: d0 07                        bne     CLR_LINE_X        ;Go and clear this line
d16a: 68                           pla
d16b: 85 21                        sta     SCRLINEH
d16d: 68                           pla
d16e: 85 20                        sta     SCRLINEL
d170: 60                           rts

d171: bd 69 d3     CLR_LINE_X      lda     LINE_STARTH,x
d174: 85 21                        sta     SCRLINEH
d176: bd 81 d3                     lda     LINE_STARTL,x
d179: 85 20                        sta     SCRLINEL
d17b: a0 00                        ldy     #$00
d17d: 20 9e d1                     jsr     CLR_FROM_YREG
d180: f0 e3                        beq     CLR_NEXT_LINE     ;Zero flag always set back into loop
                   ; Clear the screen and initialise the 
                   ; video system
d182: 8d 54 c0     CLEAR_SCREEN    sta     TXTPAGE1          ;Setup the //e hardware
d185: 8d 0f c0                     sta     SETALTCHAR
d188: 8d 0d c0                     sta     SET80VID
d18b: 8d 01 c0                     sta     SET80COL
d18e: a9 00                        lda     #$00              ;Set X,Y to zero
d190: 85 25                        sta     CURSORX
d192: 85 29                        sta     CURSORY
d194: 85 20                        sta     SCRLINEL          ;Set the screen ptr up
d196: a9 04                        lda     #$04
d198: 85 21                        sta     SCRLINEH
d19a: d0 be                        bne     CLR_TO_ENDSCR

                   ; Clear to end of line
d19c: a4 25        CLR_EOL         ldy     CURSORX           ;Clear to EOL
d19e: 2c 55 c0     CLR_FROM_YREG   bit     TXTPAGE2
d1a1: 98                           tya                       ;Divide cursor by two
d1a2: 4a                           lsr     A
d1a3: 48                           pha                       ;Save cursor/2 for Page 1 clear
d1a4: a8                           tay
d1a5: a9 a0                        lda     #$a0              ;Sort out if blank is inverse or not
d1a7: 25 32                        and     MON_INVFLAG
d1a9: 85 26                        sta     BLANKCH           ;Save our blank character
d1ab: b0 02                        bcs     SKIP_ODD_CLR      ;Do we need skip the first one?
d1ad: 91 20        CLR_PAGE2_LINE  sta     (SCRLINEL),y      ;Clear the character
d1af: c8           SKIP_ODD_CLR    iny                       ;Next one
d1b0: c0 28                        cpy     #40               ;All Done?
d1b2: d0 f9                        bne     CLR_PAGE2_LINE    ;Nah loop
d1b4: 68                           pla                       ;Restore cursor/2 for page 1 clear
d1b5: a8                           tay
d1b6: a5 26                        lda     BLANKCH           ;Get the character to clear with
d1b8: 2c 54 c0                     bit     TXTPAGE1          ;Setup for main text page
d1bb: 91 20        CLR_PAGE1_LINE  sta     (SCRLINEL),y      ;Clear the character
d1bd: c8                           iny                       ;Next one
d1be: c0 28                        cpy     #40               ;All done?
d1c0: d0 f9                        bne     CLR_PAGE1_LINE    ;Nope do the next one
d1c2: 60                           rts

                   ; Ring the bell
d1c3: a9 35        BELL            lda     #$35
d1c5: 8d ea d1                     sta     BELL_COUNT
d1c8: a9 05        BELL_LOOP       lda     #$05
d1ca: 20 de d1                     jsr     DELAY
d1cd: 8d 30 c0                     sta     SPKR
d1d0: a9 20                        lda     #$20
d1d2: 20 de d1                     jsr     DELAY
d1d5: 8d 30 c0                     sta     SPKR
d1d8: ce ea d1                     dec     BELL_COUNT
d1db: d0 eb                        bne     BELL_LOOP
d1dd: 60                           rts

d1de: 38           DELAY           sec
d1df: 48           DELAY1          pha                       ;Save counter
d1e0: e9 01        DELAY2          sbc     #$01              ;Decrement our counter
d1e2: d0 fc                        bne     DELAY2            ;Inner loop
d1e4: 68                           pla                       ;Get counter back for the outer loop
d1e5: e9 01                        sbc     #$01
d1e7: d0 f6                        bne     DELAY1            ;All done yet?
d1e9: 60                           rts

d1ea: 00           BELL_COUNT      .dd1    $00

d1eb: a9 7f        SET_INVERSE     lda     #$7f
d1ed: d0 02                        bne     STORE_INVFLAG

d1ef: a9 ff        SET_NORMAL      lda     #$ff
d1f1: 85 32        STORE_INVFLAG   sta     MON_INVFLAG
d1f3: 60                           rts

d1f4: 38           SCROLL_UP       sec
                   ; Come in here with carry flag set to scroll up
                   ; carry flag clear to scroll down
                   SCROLL_CARRY_FLAG
d1f5: 24                           .dd1    $24               ;BIT Zero page
d1f6: 18           SCROLL_DOWN     clc
d1f7: a9 a0                        lda     #$a0              ;Space character
d1f9: 25 32                        and     MON_INVFLAG       ;Should it be inverted?
d1fb: a8                           tay
d1fc: a2 27                        ldx     #39               ;Bytes to move
d1fe: 8d 55 c0     SCROLL_LOOP     sta     TXTPAGE2          ;Do half the 80 columns
d201: 20 0e d2                     jsr     SCROLL_COLUMN
d204: 8d 54 c0                     sta     TXTPAGE1
d207: 20 0e d2                     jsr     SCROLL_COLUMN     ;Do the other half
d20a: ca                           dex
d20b: 10 f1                        bpl     SCROLL_LOOP       ;Done all 40?
d20d: 60                           rts

d20e: b0 03        SCROLL_COLUMN   bcs     SCROLL_COL_UP     ;Scroll a single column
d210: 4c a2 d2                     jmp     SCROLL_COL_DOWN

d213: bd 80 04     SCROLL_COL_UP   lda     $0480,x           ;Copy line by line
d216: 9d 00 04                     sta     $0400,x
d219: bd 00 05                     lda     $0500,x
d21c: 9d 80 04                     sta     $0480,x
d21f: bd 80 05                     lda     $0580,x
d222: 9d 00 05                     sta     $0500,x
d225: bd 00 06                     lda     $0600,x
d228: 9d 80 05                     sta     $0580,x
d22b: bd 80 06                     lda     $0680,x
d22e: 9d 00 06                     sta     $0600,x
d231: bd 00 07                     lda     $0700,x
d234: 9d 80 06                     sta     $0680,x
d237: bd 80 07                     lda     $0780,x
d23a: 9d 00 07                     sta     $0700,x
d23d: bd 28 04                     lda     $0428,x
d240: 9d 80 07                     sta     $0780,x
d243: bd a8 04                     lda     $04a8,x
d246: 9d 28 04                     sta     $0428,x
d249: bd 28 05                     lda     $0528,x
d24c: 9d a8 04                     sta     $04a8,x
d24f: bd a8 05                     lda     $05a8,x
d252: 9d 28 05                     sta     $0528,x
d255: bd 28 06                     lda     $0628,x
d258: 9d a8 05                     sta     $05a8,x
d25b: bd a8 06                     lda     $06a8,x
d25e: 9d 28 06                     sta     $0628,x
d261: bd 28 07                     lda     $0728,x
d264: 9d a8 06                     sta     $06a8,x
d267: bd a8 07                     lda     $07a8,x
d26a: 9d 28 07                     sta     $0728,x
d26d: bd 50 04                     lda     $0450,x
d270: 9d a8 07                     sta     $07a8,x
d273: bd d0 04                     lda     $04d0,x
d276: 9d 50 04                     sta     $0450,x
d279: bd 50 05                     lda     $0550,x
d27c: 9d d0 04                     sta     $04d0,x
d27f: bd d0 05                     lda     $05d0,x
d282: 9d 50 05                     sta     $0550,x
d285: bd 50 06                     lda     $0650,x
d288: 9d d0 05                     sta     $05d0,x
d28b: bd d0 06                     lda     $06d0,x
d28e: 9d 50 06                     sta     $0650,x
d291: bd 50 07                     lda     $0750,x
d294: 9d d0 06                     sta     $06d0,x
d297: bd d0 07                     lda     $07d0,x
d29a: 9d 50 07                     sta     $0750,x
d29d: 98                           tya                       ;Blank character in Y
d29e: 9d d0 07                     sta     $07d0,x
d2a1: 60                           rts

d2a2: bd 50 07     SCROLL_COL_DOWN lda     $0750,x           ;copy lines up
d2a5: 9d d0 07                     sta     $07d0,x
d2a8: bd d0 06                     lda     $06d0,x
d2ab: 9d 50 07                     sta     $0750,x
d2ae: bd 50 06                     lda     $0650,x
d2b1: 9d d0 06                     sta     $06d0,x
d2b4: bd d0 05                     lda     $05d0,x
d2b7: 9d 50 06                     sta     $0650,x
d2ba: bd 50 05                     lda     $0550,x
d2bd: 9d d0 05                     sta     $05d0,x
d2c0: bd d0 04                     lda     $04d0,x
d2c3: 9d 50 05                     sta     $0550,x
d2c6: bd 50 04                     lda     $0450,x
d2c9: 9d d0 04                     sta     $04d0,x
d2cc: bd a8 07                     lda     $07a8,x
d2cf: 9d 50 04                     sta     $0450,x
d2d2: bd 28 07                     lda     $0728,x
d2d5: 9d a8 07                     sta     $07a8,x
d2d8: bd a8 06                     lda     $06a8,x
d2db: 9d 28 07                     sta     $0728,x
d2de: bd 28 06                     lda     $0628,x
d2e1: 9d a8 06                     sta     $06a8,x
d2e4: bd a8 05                     lda     $05a8,x
d2e7: 9d 28 06                     sta     $0628,x
d2ea: bd 28 05                     lda     $0528,x
d2ed: 9d a8 05                     sta     $05a8,x
d2f0: bd a8 04                     lda     $04a8,x
d2f3: 9d 28 05                     sta     $0528,x
d2f6: bd 28 04                     lda     $0428,x
d2f9: 9d a8 04                     sta     $04a8,x
d2fc: bd 80 07                     lda     $0780,x
d2ff: 9d 28 04                     sta     $0428,x
d302: bd 00 07                     lda     $0700,x
d305: 9d 80 07                     sta     $0780,x
d308: bd 80 06                     lda     $0680,x
d30b: 9d 00 07                     sta     $0700,x
d30e: bd 00 06                     lda     $0600,x
d311: 9d 80 06                     sta     $0680,x
d314: bd 80 05                     lda     $0580,x
d317: 9d 00 06                     sta     $0600,x
d31a: bd 00 05                     lda     $0500,x
d31d: 9d 80 05                     sta     $0580,x
d320: bd 80 04                     lda     $0480,x
d323: 9d 00 05                     sta     $0500,x
d326: bd 00 04                     lda     $0400,x
d329: 9d 80 04                     sta     $0480,x
d32c: 98                           tya
d32d: 9d 00 04                     sta     $0400,x
d330: 60                           rts

d331: 24 23        HIDE_CURSOR     bit     CURSOR_STATE      ;Get the current cursor state
d333: 10 05                        bpl     CURSOR_IS_OFF     ;Is it off
d335: 48                           pha                       ;Nope save the accumulator
d336: 20 1b d1                     jsr     TOGGLE_CURSOR     ;Toggle the cursor
d339: 68                           pla                       ;Restore acc
d33a: 60           CURSOR_IS_OFF   rts

d33b: c3 d1        CTRL_CHAR_TAB   .dd2    BELL              ;Ctrl-G
d33d: 24 d1                        .dd2    BACKSPACE         ;Ctrl-H
d33f: b5 d0                        .dd2    IGNORE_CHAR       ;Ctrl-I
d341: 00 d1                        .dd2    LINEFEED          ;Ctrl-J
d343: 5a d1                        .dd2    CLR_TO_ENDSCR     ;Ctrl-K
d345: 82 d1                        .dd2    CLEAR_SCREEN      ;Ctrl-L
d347: fb d0                        .dd2    CARRIAGE_RET      ;Ctrl-M
d349: ef d1                        .dd2    SET_NORMAL        ;Ctrl-N
d34b: eb d1                        .dd2    SET_INVERSE       ;Ctrl-O
d34d: b5 d0                        .dd2    IGNORE_CHAR       ;Ctrl-P
d34f: b5 d0                        .dd2    IGNORE_CHAR       ;Ctrl-Q
d351: b5 d0                        .dd2    IGNORE_CHAR       ;Ctrl-R
d353: b5 d0                        .dd2    IGNORE_CHAR       ;Ctrl-S
d355: b5 d0                        .dd2    IGNORE_CHAR       ;Ctrl-T
d357: b5 d0                        .dd2    IGNORE_CHAR       ;Ctrl-U
d359: f6 d1                        .dd2    SCROLL_DOWN       ;Ctrl-V
d35b: f4 d1                        .dd2    SCROLL_UP         ;Ctrl-W
d35d: b5 d0                        .dd2    IGNORE_CHAR       ;Ctrl-X
d35f: 51 d1                        .dd2    HOME              ;Ctrl-Y
d361: 4a d1                        .dd2    CLR_LINE          ;Ctrl-Z
d363: b5 d0                        .dd2    IGNORE_CHAR       ;Ctrl-[ aka Esc
d365: 3b d1                        .dd2    CURSOR_RIGHT      ;Ctrl-\
d367: 9c d1                        .dd2    CLR_EOL           ;Ctrl-]
d369: 04 04 05 05+ LINE_STARTH     .bulk   $04,$04,$05,$05,$06,$06,$07,$07 ;Start of video line high
d371: 04 04 05 05+                 .bulk   $04,$04,$05,$05,$06,$06,$07,$07
d379: 04 04 05 05+                 .bulk   $04,$04,$05,$05,$06,$06,$07,$07
d381: 00 80 00 80+ LINE_STARTL     .bulk   $00,$80,$00,$80,$00,$80,$00,$80 ;Start of video line low
d389: 28 a8 28 a8+                 .bulk   $28,$a8,$28,$a8,$28,$a8,$28,$a8
d391: 50 d0 50 d0+                 .bulk   $50,$d0,$50,$d0,$50,$d0,$50,$d0
                   ; Used to convert some televideo 920(maybe?) escape codes to Ctrl codes
d399: 8c           ESC_CTRL_CODES  .dd1    $8c               ;<ESC><FF> - Form feed
d39a: a9                           .dd1    ‘)’ | $80         ;<ESC> ) - Start half intensity
d39b: a8                           .dd1    ‘(’ | $80         ;<ESC> ( - End half intesity
d39c: aa                           .dd1    ‘*’ | $80         ;<ESC> * - Clear all to null
d39d: d9                           .dd1    ‘Y’ | $80         ;<ESC> Y - Page erase to space
d39e: d4                           .dd1    ‘T’ | $80         ;<ESC> T - Line erase to space
d39f: 8c           ESC_CHAR_TRANS  .dd1    $8c               ;Ctrl-L - Form feed
d3a0: 8e                           .dd1    $8e               ;Ctrl-N - set normal
d3a1: 8f                           .dd1    $8f               ;Ctrl-O - Set Inverse
d3a2: 8c                           .dd1    $8c               ;Ctrl-L - Form feed
d3a3: 8b                           .dd1    $8b               ;Ctrl-K - Clear to end of screen
d3a4: 9d                           .dd1    $9d               ;Ctrl-] - Clear to end of line
d3a5: 00           GOTO_Y          .dd1    $00               ;Goto YX cursor Y
d3a6: 1a 1a 1a 1a+                 .fill   90,$1a

                   ********************************************************************************
                   *                                                                              *
                   * Routines to handle Disk drives                                               *
                   *                                                                              *
                   ********************************************************************************
                                   .addrs  $d400
d400: ad 84 03                     lda     DISK_DRV          ;Get the drive ($60 for S6,D1)
d403: 29 7f                        and     #$7f              ;Mask off drive (ProDOS style)
d405: 8d f8 05                     sta     DISKSLOTCX
d408: 4a                           lsr     A
d409: 4a                           lsr     A
d40a: 4a                           lsr     A
d40b: 4a                           lsr     A
d40c: aa                           tax
d40d: bd b8 03                     lda     SLOT_INFO,x       ;Get Disk type? Might be card in slot
d410: c9 02                        cmp     #$02              ;DISK ][ ?
d412: f0 0d                        beq     DISKII
d414: c9 07                        cmp     #$07              ;Ram drive or Prodos?
d416: 90 03                        bcc     BAD_SLOT_ERR
d418: 4c a3 da                     jmp     IDC_CHECK         ;Go do IDC check

d41b: a9 01        BAD_SLOT_ERR    lda     #$01
d41d: 8d 89 03                     sta     DISK_ERR
d420: 60                           rts

                   ********************************************************************************
                   *                                                                              *
                   * Disk II driver code                                                          *
                   *                                                                              *
                   * Code that is the same as the RWTS routines in the DOS3.3C source code from   *
                   * https://www.brutaldeluxe.fr/documentation/dos33/apple2_SRC_DOS33C_1983.pdf   *
                   * has the same comments, although some of the long comments have been edited   *
                   * and the short comments have been converted to lower case.                    *
                   *                                                                              *
                   * Addresses for the Woz Disk II card have used the IWM conventions from the    *
                   * sourcegen symbol table. Other symbols match those in the RWTS routines in    *
                   * the DOS 3.3C source code.                                                    *
                   *                                                                              *
                   * Code has large chunks that are copies of the RWTS routines from DOS, but     *
                   * some bits are different (PRENIB16 for example) along with the RWTS calling   *
                   * mechanism which means a one to one match doesn't work.                       *
                   *                                                                              *
                   ********************************************************************************
d421: a0 02        DISKII          ldy     #$02              ;Set Recalibrate
d423: 8c f8 06                     sty     RECALCNT          ;Count
d426: a0 04                        ldy     #$04              ;Set reseek
d428: 8c f8 04                     sty     SEEKCNT           ;count
d42b: ae f8 05                     ldx     DISKSLOTCX        ;Get slot # for this operation
                   ; Now check if the motor is on, then start it.
d42e: bd 8e c0                     lda     IWM_Q7_OFF,x      ;Make sure in read mode
d431: bd 8c c0                     lda     IWM_Q6_OFF,x
d434: a0 08                        ldy     #$08              ;We may hafta check several times to be sure
d436: bd 8c c0     CHKIFON         lda     IWM_Q6_OFF,x      ;Get the data
d439: 48                           pha                       ;Delay for disk data to change
d43a: 68                           pla
d43b: 48                           pha
d43c: 68                           pla
d43d: dd 8c c0                     cmp     IWM_Q6_OFF,x      ;Check running here
d440: d0 03                        bne     ITISON            ;=> it's on
d442: 88                           dey                       ;Maybe we didn't catch it
d443: d0 f1                        bne     CHKIFON           ;So we'll try again
d445: 08           ITISON          php                       ;Save test results
d446: bd 89 c0                     lda     IWM_MOTOR_ON,x    ;Turn on motor regardless
d449: a9 ef                        lda     #$ef              ;Set up the
d44b: 85 46                        sta     MONTIMEL          ;motor-on time
d44d: a9 d8                        lda     #$d8              ;Note value is complemented
d44f: 85 47                        sta     MONTIMEH
d451: ad 84 03                     lda     DISK_DRV          ;Determine drive one or two
d454: cd 85 03                     cmp     DISK_ACTD         ;same drive used before?
d457: f0 07                        beq     OK
d459: 8d 85 03                     sta     DISK_ACTD         ;Now using this drive
d45c: 28                           plp                       ;Tell him motor was off
d45d: a0 00                        ldy     #$00              ;Set zero flag
d45f: 08                           php
d460: 2a           OK              rol     A                 ;By going into the carry
d461: b0 05                        bcs     SD1               ;Select drive 2!
d463: bd 8a c0                     lda     IWM_DRIVE_1,x     ;Assume drive 1 to hit
d466: 90 03                        bcc     DRVSEL            ;If wrong, enable drive 2 instead

d468: bd 8b c0     SD1             lda     IWM_DRIVE_2,x     ;Nope drive 2
d46b: 66 35        DRVSEL          ror     DRIVNO            ;Save selected drive
                   ; Drive selected. If motoring up,
                   ; wait before seeking...
d46d: 28                           plp                       ;Was the motor
d46e: 08                           php                       ;Previously off?
d46f: d0 0b                        bne     NOWAIT            ;=> No, forget waiting
d471: a0 07                        ldy     #$07              ;Yes, delay 150mS
d473: 20 d9 d6     SEEKW           jsr     MSWAIT
d476: 88                           dey
d477: d0 fa                        bne     SEEKW
d479: ae f8 05                     ldx     DISKSLOTCX        ;Restore slot number
d47c: ad 88 03     NOWAIT          lda     DISK_OP           ;Examine disk operation
d47f: c9 03                        cmp     #DSKOP_FMT
d481: d0 04                        bne     NOTFORMAT         ;Not format
d483: 28                           plp                       ;Get back motor status
d484: 4c b3 d9                     jmp     DSKFORM           ;Do the format

d487: ad 80 03     NOTFORMAT       lda     DISK_TRKL         ;Goto the track
d48a: 20 cb d7                     jsr     MYSEEK
d48d: ad 88 03                     lda     DISK_OP           ;Get disk operation
d490: 28                           plp                       ;Get back if we have some data incoming?
d491: d0 07                        bne     MOTORREADY        ;Drive running so skip
d493: c9 01                        cmp     #DSKOP_RD         ;Read?
d495: f0 03                        beq     MOTORREADY        ;Can skip waiting for rest of motor
d497: 20 c4 d8                     jsr     MOTOF             ;Time for a read
d49a: c9 04        MOTORREADY      cmp     #DSKOP_WRTRK      ;Write a whole track?
d49c: d0 03                        bne     CHECKRDTRKOP      ;Nope, check for read
d49e: 4c 1a da                     jmp     D2TRACKOPER       ;Go do full track operation

d4a1: c9 05        CHECKRDTRKOP    cmp     #DSKOP_RDTRK      ;Read track operation?
d4a3: d0 03                        bne     TRYTRK            ;Nope,do a single sector
d4a5: 4c 1a da                     jmp     D2TRACKOPER       ;Go do full track operation

d4a8: 6a           TRYTRK          ror     A                 ;Set carry=1 for read, 0 for write
d4a9: 08                           php                       ;and save that
d4aa: b0 03                        bcs     TRYTRK2           ;Must prenibblize for write
d4ac: 20 8e d6                     jsr     PRENIB16
d4af: a0 30        TRYTRK2         ldy     #$30              ;Only 48 retries of any kind.
d4b1: 8c 78 05                     sty     RETRYCNT
d4b4: ae f8 05     TRYADR          ldx     DISKSLOTCX        ;Get slot num into x-reg
d4b7: 20 6f d7                     jsr     RDADR16           ;Read next address field
d4ba: 90 22                        bcc     RDRIGHT           ;If it read right, hurrah!
d4bc: ce 78 05     TRYADR2         dec     RETRYCNT          ;Another mistaek!!
d4bf: 10 f3                        bpl     TRYADR
                   ; *
                   ; * RRRRRECALIBRATE !!!!
                   ; *
d4c1: a9 2a        RECAL           lda     #$2a              ;Recalibrate all over again
d4c3: 20 ee d6                     jsr     SETTRK            ;Pretend to be on track 42 (DOS uses 96)
d4c6: ce f8 06                     dec     RECALCNT          ;Once too many?
d4c9: f0 31                        beq     DRVERR            ;Tried to recalibrate too many times error!
d4cb: a9 04                        lda     #$04              ;Reset the
d4cd: 8d f8 04                     sta     SEEKCNT           ;seek counter
d4d0: a9 00                        lda     #$00
d4d2: 20 cb d7                     jsr     MYSEEK            ;Move to track 00
d4d5: ad 80 03                     lda     DISK_TRKL
d4d8: 20 cb d7     RESEEK          jsr     MYSEEK            ;Go to correct track this time!
d4db: 4c af d4                     jmp     TRYTRK2           ;Loop back, tray again on this track

d4de: a5 2f        RDRIGHT         lda     VOLUME            ;Check volume isn't very interesting for CP/M
d4e0: 8d 87 03                     sta     DISK_VOL          ;So just copy it
d4e3: 48                           pha                       ;Left over from RWTS volume check code?
d4e4: 68                           pla
d4e5: a4 2e                        ldy     TRACK             ;On the right track
d4e7: cc 80 03                     cpy     DISK_TRKL
d4ea: f0 16                        beq     RTTRK             ;If so good
d4ec: ad 78 04                     lda     CURTRK            ;Preserve destination track
d4ef: 48                           pha
d4f0: 98                           tya
d4f1: 20 ee d6                     jsr     SETTRK
d4f4: 68                           pla
d4f5: ce f8 04                     dec     SEEKCNT           ;Should we reseek?
d4f8: d0 de                        bne     RESEEK            ;=> Yes, reseek
d4fa: f0 c5                        beq     RECAL             ;=> No, Recalibrate!

d4fc: a9 01        DRVERR          lda     #$01              ;Bad drive error
d4fe: 28                           plp                       ;Pop disk operation
d4ff: 38                           sec
d500: b0 22                        bcs     DISKII_ERR

d502: ad 81 03     RTTRK           lda     DISK_SECT         ;Get requested (logical) sector
d505: a8                           tay                       ;Move to index reg
d506: b9 35 d5     DOSECTTRAN      lda     CPM_TRAN_SECT,y   ;Compute physical sector
d509: c5 2d                        cmp     SECTOR            ;Did we get the sector?
d50b: d0 af                        bne     TRYADR2           ;No, keep trying
                   ; *
                   ; * Hooray! We got the right sector!
                   ; *
d50d: 28                           plp
d50e: 90 1b                        bcc     WRIT              ;Carry was set for read operation
d510: 20 07 d7                     jsr     READ16
d513: 08                           php                       ;Save status of read operation
d514: b0 a6                        bcs     TRYADR2           ;Retry on error
d516: 28                           plp                       ;Careful of stack
d517: a2 00                        ldx     #$00              ;Setup to postnibilize
d519: 86 26                        stx     T0
d51b: 20 be d6                     jsr     POSTNB16
d51e: ae f8 05                     ldx     DISKSLOTCX        ;Restore slotnum into X
d521: a9 00        DISKII_OK       lda     #$00              ;Clear error
d523: 18                           clc
d524: 8d 89 03     DISKII_ERR      sta     DISK_ERR          ;Setup disk error
d527: bd 88 c0                     lda     IWM_MOTOR_OFF,x   ;Turn off motor
d52a: 60                           rts

d52b: 20 00 d6     WRIT            jsr     WRITE16           ;Write nybbles now
d52e: 90 f1                        bcc     DISKII_OK         ;If no errors
d530: a9 10                        lda     #$10              ;Disk is write protected.
d532: 38                           sec
d533: b0 ef                        bcs     DISKII_ERR        ;Always taken

                   ; CPM logical sector to physical disk sector number
d535: 00 03 06 09+ CPM_TRAN_SECT   .bulk   $00,$03,$06,$09,$0c,$0f,$02,$05
d53d: 08 0b 0e 01+                 .bulk   $08,$0b,$0e,$01,$04,$07,$0a,$0d
                   ; Table of off timings for the stepper motor
d545: 70 2c 26 22+ OFFTABLE        .bulk   $70,$2c,$26,$22,$1f,$1e,$1d,$1c
d54d: 1c 1c 1c 1c+                 .bulk   $1c,$1c,$1c,$1c,$1c
                   ; Table for nibble conversion to disk
d552: 96 97 9a 9b+ NIBL            .bulk   $96,$97,$9a,$9b,$9d,$9e,$9f,$a6
d55a: a7 ab ac ad+                 .bulk   $a7,$ab,$ac,$ad,$ae,$af,$b2,$b3
d562: b4 b5 b6 b7+                 .bulk   $b4,$b5,$b6,$b7,$b9,$ba,$bb,$bc
d56a: bd be bf cb+                 .bulk   $bd,$be,$bf,$cb,$cd,$ce,$cf,$d3
d572: d6 d7 d9 da+                 .bulk   $d6,$d7,$d9,$da,$db,$dc,$dd,$de
d57a: df e5 e6 e7+                 .bulk   $df,$e5,$e6,$e7,$e9,$ea,$eb,$ec
d582: ed ee ef f2+                 .bulk   $ed,$ee,$ef,$f2,$f3,$f4,$f5,$f6
d58a: f7 f9 fa fb+                 .bulk   $f7,$f9,$fa,$fb,$fc,$fd,$fe,$ff
d592: 00 00 00 00+                 .bulk   $00,$00,$00,$00,$00,$01
d598: 98 99 02 03+                 .bulk   $98,$99,$02,$03,$9c,$04,$05,$06
d5a0: a0 a1 a2 a3+                 .bulk   $a0,$a1,$a2,$a3,$a4,$a5,$07,$08
d5a8: a8 a9 aa 09+                 .bulk   $a8,$a9,$aa,$09,$0a,$0b,$0c,$0d
d5b0: b0 b1 0e 0f+                 .bulk   $b0,$b1,$0e,$0f,$10,$11,$12,$13
d5b8: b8 14 15 16+                 .bulk   $b8,$14,$15,$16,$17,$18,$19,$1a
d5c0: c0 c1 c2 c3+                 .bulk   $c0,$c1,$c2,$c3,$c4,$c5,$c6,$c7
d5c8: c8 c9 ca 1b+                 .bulk   $c8,$c9,$ca,$1b,$cc,$1c,$1d,$1e
d5d0: d0 d1 d2 1f+                 .bulk   $d0,$d1,$d2,$1f,$d4,$d5,$20,$21
d5d8: d8 22 23 24+                 .bulk   $d8,$22,$23,$24,$25,$26,$27,$28
d5e0: e0 e1 e2 e3+                 .bulk   $e0,$e1,$e2,$e3,$e4,$29,$2a,$2b
d5e8: e8 2c 2d 2e+                 .bulk   $e8,$2c,$2d,$2e,$2f,$30,$31,$32
d5f0: f0 f1 33 34+                 .bulk   $f0,$f1,$33,$34,$35,$36,$37,$38
d5f8: f8 39 3a 3b+                 .bulk   $f8,$39,$3a,$3b,$3c,$3d,$3e,$3f
                   ; ************************************
                   ; * WRITE SUBR (16-SECTOR FORMAT)    *
                   ; ************************************
                   ; * WRITES DATA FROM NBUF1 AND NBUF2 *
                   ; * CONVERTING 6-BIT TO 7-BIT NIBLS  *
                   ; * VIA 'NIBL' TABLE.                *
                   ; * FIRST NBUF2, HIGH TO LOW. THEN   *
                   ; * NBUF1,  LOW TO HIGH.             *
                   ; * ---- ON ENTRY ----               *
                   ; * X-REG: SLOTNUM TIMES $10.        *
                   ; * NBUF1 AND NBUF2 HOLD NIBLS       *
                   ; * FROM  PRENIBL SUBR. (00ABCDEF)   *
                   ; * ---- ON EXIT -----               *
                   ; * CARRY SET IF ERROR.              *
                   ; *  (W PROT VIOLATION)              *
                   ; * IF NO ERROR:                     *
                   ; * A-REG UNCERTAIN X-REG UNCHANGED. *
                   ; * Y-REG HOLDS $00. CARRY CLEAR.    *
                   ; * SLOTABS, SLOTZ, AND WTEMP USED.  *
                   ; * ---- ASSUMES ----                *
                   ; * 1 USEC CYCLE TIME                *
                   ; ************************************
d600: 38           WRITE16         sec                       ;Anticipate wrpot err.
d601: 86 27                        stx     SLOTZ             ;For zero page access.
d603: 8e 78 06                     stx     SLOTABS           ;For non-zero page.
d606: bd 8d c0                     lda     IWM_Q6_ON,x
d609: bd 8e c0                     lda     IWM_Q7_OFF,x      ;Sense wprot flag.
d60c: 30 7c                        bmi     WEXIT             ;If high, then err.
d60e: ad 00 df                     lda     NBUF2
d611: 85 26                        sta     WTEMP             ;For zero-page access
d613: a9 ff                        lda     #$ff              ;sync data.
d615: 9d 8f c0                     sta     IWM_Q7_ON,x       ;(5) Write 1st nibl.
d618: 1d 8c c0                     ora     IWM_Q6_OFF,x      ;(4)
d61b: 48                           pha                       ;(3)
d61c: 68                           pla                       ;(4) Critical timing!
d61d: ea                           nop                       ;(2)
d61e: a0 04                        ldy     #$04              ;(2) for 5 nibls.
d620: 48           WSYNC           pha                       ;(3) Exact timing.
d621: 68                           pla                       ;(4) Exact timing.
d622: 20 b5 d6                     jsr     WNIBL7            ;(13,9,6) Write SYNC
d625: 88                           dey                       ;(2)
d626: d0 f8                        bne     WSYNC             ;(2*) MUST NOT cross page!
d628: a9 d5                        lda     #$d5              ;(2) 1st data mark.
d62a: 20 b4 d6                     jsr     WNIBL9            ;(15,9,6)
d62d: a9 aa                        lda     #$aa              ;(2) 2nd data mark.
d62f: 20 b4 d6                     jsr     WNIBL9            ;(15,9,6)
d632: a9 ad                        lda     #$ad              ;(2) 3rd data mark.
d634: 20 b4 d6                     jsr     WNIBL9            ;(15,9,6)
d637: 98                           tya                       ;(2) Clear checksum
d638: a0 56                        ldy     #$56              ;(2) NBUF2 index
d63a: d0 03                        bne     WDATA1            ;(3) Always. No Page Cross!!

d63c: b9 00 df     WDATA0          lda     NBUF2,y           ;(4) Prior 6=bit nibl.
d63f: 59 ff de     WDATA1          eor     NBUF2-1,y         ;(5) XOR with current
                   ; (NBUF2 MUST be on page boundary for timing!!)
d642: aa                           tax                       ;(2) index to 7-bit nibl
d643: bd 52 d5                     lda     NIBL,x            ;(4) Must not cross page!
d646: a6 27                        ldx     SLOTZ             ;(3) Critical timing!
d648: 9d 8d c0                     sta     IWM_Q6_ON,x       ;(5) Write nibl.
d64b: bd 8c c0                     lda     IWM_Q6_OFF,x      ;(4)
d64e: 88                           dey                       ;(2) Next nibl.
d64f: d0 eb                        bne     WDATA0            ;(2*) Must not cross page!
d651: a5 26                        lda     WTEMP             ;(3) Prior nibl from buf6.
d653: ea                           nop                       ;(2) Critical timing.
d654: 59 00 de     WDATA2          eor     NBUF1,y           ;(4) XOR NBUF1 nibl.
d657: aa                           tax                       ;(2) Index to 7-bit nibl.
d658: bd 52 d5                     lda     NIBL,x            ;(4)
d65b: ae 78 06                     ldx     SLOTABS           ;(4) Timing critical
d65e: 9d 8d c0                     sta     IWM_Q6_ON,x       ;(5) Write nibl.
d661: bd 8c c0                     lda     IWM_Q6_OFF,x      ;(4)
d664: b9 00 de                     lda     NBUF1,y           ;(4) Prior 6-bit nibl.
d667: c8                           iny                       ;(2) Next NBUF1 nibl.
d668: d0 ea                        bne     WDATA2            ;(2*) Must not cross page!
d66a: aa                           tax                       ;(2) Last nibl as chksum
d66b: bd 52 d5                     lda     NIBL,x            ;(4) Index to 7-bit nibl.
d66e: a6 27                        ldx     SLOTZ             ;(3)
d670: 20 b7 d6                     jsr     WNIBL             ;(6,9,6) Write checksum
d673: a9 de                        lda     #$de              ;(2) DM4, bit slip mark.
d675: 20 b4 d6                     jsr     WNIBL9            ;(15,9,6) Write it
d678: a9 aa                        lda     #$aa              ;(2) DM5, bit slip mark.
d67a: 20 b4 d6                     jsr     WNIBL9            ;(15,9,6) Write it
d67d: a9 eb                        lda     #$eb              ;(2) DM6, bit slip mark.
d67f: 20 b4 d6                     jsr     WNIBL9            ;(15,9,6) Write it
d682: a9 ff                        lda     #$ff              ;(2) Turn-off byte.
d684: 20 b4 d6                     jsr     WNIBL9            ;(15,9,6) Write it
d687: bd 8e c0                     lda     IWM_Q7_OFF,x      ;Out of write mode
d68a: bd 8c c0     WEXIT           lda     IWM_Q6_OFF,x      ;to read mode
d68d: 60                           rts                       ;Return from write

                   ; ***************************************
                   ; * PRENIBLIZE SUBR (16-SECTOR FORMAT)  *
                   ; ***************************************
                   ; * CONVERTS 256 BYTES OF USER DATA IN  *
                   ; * DISK_BUF INTO 342 6-BIT NIBLS       *
                   ; * (00ABCDEF) IN NBUF1 AND NBUF2.      * 
                   ; * ---- ON ENTRY ----                  *
                   ; * DISK_BUF IS 256 BYTES OF USER DATA. *
                   ; * ---- ON EXIT -----                  *
                   ; * A-REG UNCERTAIN. X-REG HOLDS $FF.   *
                   ; * Y-REG HOLDS $FF. CARRY SET.         *
                   ; * NBUF1 AND NBUF2 CONTAIN             *
                   ; * 6-BIT NIBLS OF FORM 00ABCDEF.       *
                   ; ***************************************
                   ; * NOTE: Code is different to RWTS     *
                   ; ***************************************
d68e: a2 55        PRENIB16        ldx     #$55              ;Clear out the two bit table
d690: a9 00                        lda     #$00
d692: 9d 00 df     PRENIB1         sta     NBUF2,x           ;Clear it
d695: ca                           dex
d696: 10 fa                        bpl     PRENIB1           ;Loop until done
d698: a8                           tay                       ;Zero counter
d699: a2 ac                        ldx     #$ac              ;First time thru we need to more bits
d69b: 2c                           .dd1    $2c               ;BIT instruction

d69c: a2 aa        PRENIB2         ldx     #$aa              ;First time X is AC, Second time AA
d69e: 88           PRENIB3         dey
d69f: b9 00 08     PRENIBPAGE      lda     DISK_BUFF,y       ;Get data byte
d6a2: 4a                           lsr     A
d6a3: 3e 56 de                     rol     NBUF1+86,x        ;Rotate into two bit data
d6a6: 4a                           lsr     A
d6a7: 3e 56 de                     rol     NBUF1+86,x
d6aa: 99 00 de                     sta     NBUF1,y           ;Put left overs into six bit data
d6ad: e8                           inx
d6ae: d0 ee                        bne     PRENIB3           ;Out of two bit data?
d6b0: 98                           tya
d6b1: d0 e9                        bne     PRENIB2           ;Done all 256 bytes?
d6b3: 60                           rts

                   ; **************************************
                   ; * 7-BIT NIBL WRITE SUBRS  A-REG OR'D *
                   ; * PRIOR EXIT CARRY CLEARED           *
                   ; **************************************
d6b4: 18           WNIBL9          clc                       ;(2) 9 cycles, then write.
d6b5: 48           WNIBL7          pha                       ;(3) 7 cycles, then write.
d6b6: 68                           pla                       ;(4)
d6b7: 9d 8d c0     WNIBL           sta     IWM_Q6_ON,x       ;(5) Nibl write sub.
d6ba: 1d 8c c0                     ora     IWM_Q6_OFF,x      ;(4) Clobbers acc, not carry.
d6bd: 60                           rts

                   ; ******************************************
                   ; * POSTNIBLIZE SUBR 16-SECTOR FORMAT      *
                   ; ******************************************
                   ; * CONVERTS 6-BIT NIBLS OF FORM 00ABCDEF  *
                   ; * IN NBUF1 AND NBUF2 INTO 256 BYTES OF   *
                   ; * USER DATA IN DISK_BUF.                 *
                   ; ******************************************
                   ; * Note comments in DOS 3.3C source don't *
                   ; * make sense here so have been removed.  *
                   ; ******************************************
d6be: a0 00        POSTNB16        ldy     #$00              ;User data buf IDX.
d6c0: a2 56        POST1           ldx     #$56              ;Init NBUF2 Index.
d6c2: ca           POST2           dex                       ;NBUF IDX $55 to $0
d6c3: 30 fb                        bmi     POST1             ;Wrap around if neg.
d6c5: b9 00 de                     lda     NBUF1,y
d6c8: 5e 00 df                     lsr     NBUF2,x           ;Shift 2 bits from
d6cb: 2a                           rol     A                 ;Current NBUF2 nibl
d6cc: 5e 00 df                     lsr     NBUF2,x           ;into current NUBF1
d6cf: 2a                           rol     A                 ;nibl.
d6d0: 99 00 08     POSTNBPAGE      sta     DISK_BUFF,y       ;Byte of user data.
d6d3: c8                           iny                       ;Next user byte.
d6d4: c4 26                        cpy     T0                ;Done if equal T0
d6d6: d0 ea                        bne     POST2             ;Return.
d6d8: 60                           rts

                   ; **********************************************
                   ; * MSWAIT SUBROUTINE                          *
                   ; **********************************************
                   ; * DELAYS A SPECIFIED NUMBER OF 100 USEC      *
                   ; * INTERVALS FOR MOTOR ON TIMING.             *
                   ; * ---- ON ENTRY ----                         *
                   ; * A-REG: HOLDS NUMBER OF 100 USEC INTERVALS  *
                   ; * TO DELAY.                                  *
                   ; * ---- ON EXIT -----                         * 
                   ; * A-REG: HOLDS $00. X-REG: HOLDS $00.        *
                   ; * Y-REG: UNCHANGED. CARRY: SET.              *
                   ; * MONTIMEL, MONTIMEH ARE INCREMENTED ONCE    *
                   ; * PER 100 USEC INTERVAL FOR MOTON ON TIMING. *
                   ; * ---- ASSUMES ----                          *
                   ; * 1 USEC CYCLE TIME                          *
                   ; **********************************************
d6d9: a2 11        MSWAIT          ldx     #$11
d6db: ca           MSW1            dex                       ;Delay 86 uSec.
d6dc: d0 fd                        bne     MSW1
d6de: e6 46                        inc     MONTIMEL
d6e0: d0 06                        bne     MSW2              ;Double-byte
d6e2: e6 47                        inc     MONTIMEH          ;increment.
d6e4: d0 02                        bne     MSW2
d6e6: c6 47                        dec     MONTIMEH          ;NOT SAME AS RWTS
d6e8: 38           MSW2            sec
d6e9: e9 01                        sbc     #$01              ;Done 'N' intervals?
d6eb: d0 ec                        bne     MSWAIT            ;(A-reg counts)
d6ed: 60                           rts

                   ; This subroutine sets the slot dependent track location.
d6ee: 48           SETTRK          pha                       ;Preserve destination track
d6ef: ad 84 03                     lda     DISK_DRV
d6f2: 2a                           rol     A                 ;Get drive # into carry
d6f3: 66 35                        ror     DRIVNO            ;into (DRIVNO)
d6f5: 20 9a da                     jsr     SLOT_TO_Y         ;Setup Y-reg
d6f8: 68                           pla
d6f9: 0a                           asl     A                 ;Track is held * 2
d6fa: 24 35                        bit     DRIVNO
d6fc: 30 05                        bmi     ONDRV1            ;If on drive 1(1), DRIVNO minus 
d6fe: 99 f8 04                     sta     DRV2TRK,y
d701: 10 03                        bpl     SETRTS

d703: 99 78 04     ONDRV1          sta     DRV1TRK,y
d706: 60           SETRTS          rts

                   ; *****************************************************************
                   ; * READ SUBROUTINE (16-SECTOR FORMAT)                            *
                   ; *****************************************************************
                   ; * READS 6-BIT NIBLS (00ABCDEF) INTO  NBUF1 and NBUF2 CONVERTING *
                   ; * 7-BIT NIBLS TO 7-BIT VIA 'DNIBL' TABLE                        *
                   ; * FIRST READS NBUF2 HIGH TO LOW THEN READS NBUF1 LOW TO HIGH    *
                   ; * ---- ON ENTRY ----                                            *
                   ; * X-REG: SLOTNUM TIMES $10. READ MODE (Q6L, Q7L)                *
                   ; * ---- ON EXIT -----                                            *
                   ; * CARRY SET IF ERROR                                            *
                   ; * IF NO ERROR:  A-REG HOLDS $AA. X-REG UNCHANGED.               *
                   ; * Y-REG HOLDS $00. CARRY CLEAR.                                 *
                   ; * NBUF1 AND NBUF2  HOLD 6-BIT NIBLS (00ABCDEF) USES TEMP 'IDX'. *
                   ; * ---- CAUTION -----                                            *
                   ; * OBSERVE 'NO PAGE CROSS'  WARNINGS ON SOME BRANCHES!!          *
                   ; * ---- ASSUMES -----                                            *
                   ; * 1 USEC CYCLE TIME                                             *
                   ; *****************************************************************
d707: a0 20        READ16          ldy     #$20              ;'Must find' count
d709: 88           RSYNC           dey                       ;If can't find marks
d70a: f0 61                        beq     RDERR             ;Then exit with carry set.
d70c: bd 8c c0     READ1           lda     IWM_Q6_OFF,x      ;Read nibl.
d70f: 10 fb                        bpl     READ1             ;*** NO PAGE CROSS! ***
d711: 49 d5        RSYNC1          eor     #$d5              ;Data mark 1?
d713: d0 f4                        bne     RSYNC             ;Loop if not.
d715: ea                           nop                       ;Delay between nibls
d716: bd 8c c0     READ2           lda     IWM_Q6_OFF,x
d719: 10 fb                        bpl     READ2             ;*** NO PAGE CROSS! ***
d71b: c9 aa                        cmp     #$aa              ;Data mark 2?
d71d: d0 f2                        bne     RSYNC1            ;(If not, is it DM1?)
d71f: a0 56                        ldy     #$56              ;Init NBUF2 index.
                   ; (added nibl delay)
d721: bd 8c c0     READ3           lda     IWM_Q6_OFF,x
d724: 10 fb                        bpl     READ3             ;*** NO PAGE CROSS! ***
d726: c9 ad                        cmp     #$ad              ;Data mark 3?
d728: d0 e7                        bne     RSYNC1            ;(If not, is it DM1?)
                   ; (Carry set if DM3!)
d72a: a9 00                        lda     #$00              ;Init checksum
d72c: 88           RDATA1          dey
d72d: 84 26                        sty     IDX
d72f: bc 8c c0     READ4           ldy     IWM_Q6_OFF,x
d732: 10 fb                        bpl     READ4             ;*** NO PAGE CROSS! ***
d734: 59 00 d5                     eor     NIBL-82,y         ;XOR 6-bit nibl.
d737: a4 26                        ldy     IDX
d739: 99 00 df                     sta     NBUF2,y           ;Store in NBUF2 page
d73c: d0 ee                        bne     RDATA1            ;Taken if Y-reg nonzero.
d73e: 84 26        RDATA2          sty     IDX
d740: bc 8c c0     READ5           ldy     IWM_Q6_OFF,x
d743: 10 fb                        bpl     READ5             ;*** NO PAGE CROSS! ***
d745: 59 00 d5                     eor     NIBL-82,y         ;XOR 6-bit nibl.
d748: a4 26                        ldy     IDX
d74a: 99 00 de                     sta     NBUF1,y           ;Store in NBUF1 page.
d74d: c8                           iny
d74e: d0 ee                        bne     RDATA2
d750: bc 8c c0     READ6           ldy     IWM_Q6_OFF,x      ;Read 7-bit csum nibl.
d753: 10 fb                        bpl     READ6             ;*** NO PAGE CROSS! ***
d755: d9 00 d5                     cmp     NIBL-82,y         ;If last NBUF1 nibl not
d758: d0 13                        bne     RDERR             ;equal chksum nibl then err.
d75a: bd 8c c0     READ7           lda     IWM_Q6_OFF,x
d75d: 10 fb                        bpl     READ7             ;*** NO PAGE CROSS! ***
d75f: c9 de                        cmp     #$de              ;First bit slip mark?
d761: d0 0a                        bne     RDERR             ;(Err if not)
d763: ea                           nop                       ;Delay between nibls.
d764: bd 8c c0     READ8           lda     IWM_Q6_OFF,x
d767: 10 fb                        bpl     READ8             ;*** NO PAGE CROSS! ***
d769: c9 aa                        cmp     #$aa              ;Second bit slip mark?
d76b: f0 5c                        beq     RDEXIT            ;(Done if it is)
d76d: 38           RDERR           sec                       ;Indicate 'Error exit'
d76e: 60                           rts                       ;From READ16 or RDADR16

                   ; ********************************************
                   ; * READ ADDRESS FIELD SUBROUTINE            *
                   ; * (16-SECTOR FORMAT)                       *
                   ; ********************************************
                   ; * READS VOLUME, TRACK AND SECTOR           *
                   ; * ---- ON ENTRY ----                       *
                   ; * XREG: SLOTNUM TIMES                      *
                   ; * $10 READ MODE (Q6L, Q7L)                 *
                   ; * ---- ON EXIT -----                       *
                   ; * CARRY SET IF ERROR.                      *
                   ; * IF NO ERROR: A-REG HOLDS $AA. Y-REG      *
                   ; * HOLDS $00. X-REG UNCHANGED. CARRY CLEAR. *
                   ; * CSSTV HOLDS CHKSUM, SECTOR, TRACK, AND   *
                   ; * VOLUME READ. USES TEMPS COUNT, LAST,     *
                   ; * CSUM, AND 4 BYTES AT CSSTV.              *
                   ; * ---- EXPECTS ----                        *
                   ; * ORIGINAL 10-SECTOR NORMAL DENSITY NIBLS  *
                   ; * (4-BIT), ODD BITS, THEN EVEN.            *
                   ; * ---- CAUTION ----                        *
                   ; * OBSERVE 'NO PAGE CROSS' WARNINGS ON      *
                   ; * SOME BRANCHES!!                          *
                   ; * ---- ASSUMES ----                        *
                   ; * 1 USEC CYCLE TIME                        *
                   ; ********************************************
d76f: a0 fc        RDADR16         ldy     #$fc
d771: 84 26                        sty     BLANKCH           ;'Must find' count
d773: c8           RDASYN          iny
d774: d0 04                        bne     RDA1              ;Low order of count.
d776: e6 26                        inc     BLANKCH           ;(2K nibls to find
d778: f0 f3                        beq     RDERR             ;adr mark, else err)
d77a: bd 8c c0     RDA1            lda     IWM_Q6_OFF,x      ;Read nibl.
d77d: 10 fb                        bpl     RDA1              ;*** NO PAGE CROSS! ***
d77f: c9 d5        RDASN1          cmp     #$d5              ;Adr mark 1?
d781: d0 f0                        bne     RDASYN            ;(Loop if not)
d783: ea                           nop                       ;Nibl delay.
d784: bd 8c c0     RDA2            lda     IWM_Q6_OFF,x
d787: 10 fb                        bpl     RDA2              ;*** NO PAGE CROSS! ***
d789: c9 aa                        cmp     #$aa              ;Adr mark 2?
d78b: d0 f2                        bne     RDASN1            ;(If not, is it AM1?)
d78d: a0 03                        ldy     #$03              ;Index for 4-byte read
                   ; (Added nibl delay)
d78f: bd 8c c0     RDA3            lda     IWM_Q6_OFF,x
d792: 10 fb                        bpl     RDA3              ;*** NO PAGE CROSS! ***
d794: c9 96                        cmp     #$96              ;Adr mark 3?
d796: d0 e7                        bne     RDASN1            ;(If not, is it AM1)
                   ; (Leaves carry set!)
d798: a9 00                        lda     #$00
d79a: 85 27        RDAFLD          sta     CSUM              ;Init checksum
d79c: bd 8c c0     RDA4            lda     IWM_Q6_OFF,x      ;Read 'Odd bit' nibl.
d79f: 10 fb                        bpl     RDA4              ;*** NO PAGE CROSS! ***
d7a1: 2a                           rol     A                 ;Align odd bits, '1' into LSB.
d7a2: 85 26                        sta     LAST              ;Save for later
d7a4: bd 8c c0     RDA5            lda     IWM_Q6_OFF,x      ;Read 'Even bit' nibl.
d7a7: 10 fb                        bpl     RDA5              ;*** NO PAGE CROSS! ***
d7a9: 25 26                        and     LAST              ;Merge odd and even bytes
d7ab: 99 2c 00                     sta     HEADER_CHECKSUM,y ;Store data byte
d7ae: 45 27                        eor     CSUM              ;XOR checksum
d7b0: 88                           dey
d7b1: 10 e7                        bpl     RDAFLD            ;Loop on 4 data bytes
d7b3: a8                           tay                       ;If final checksum
d7b4: d0 b7                        bne     RDERR             ;Nonzero, then error.
d7b6: bd 8c c0     RDA6            lda     IWM_Q6_OFF,x      ;Read trailing byte
d7b9: 10 fb                        bpl     RDA6              ;*** NO PAGE CROSS! ***
d7bb: c9 de                        cmp     #$de
d7bd: d0 ae                        bne     RDERR             ;Wrong, go home with a error
d7bf: ea                           nop
d7c0: bd 8c c0     RDA7            lda     IWM_Q6_OFF,x      ;Error if no match
d7c3: 10 fb                        bpl     RDA7              ;*** NO PAGE CROSS! ***
d7c5: c9 aa                        cmp     #$aa
d7c7: d0 a4                        bne     RDERR             ;Error if nonmatch
d7c9: 18           RDEXIT          clc                       ;Carry on
d7ca: 60                           rts                       ;Normal read exits

                   ****************************************
                   * THIS IS THE 'SEEK' ROUTINE           *
                   * SEEKS TRACK 'N' IN SLOT #X/$10       *
                   * IF DRIVNO IS NEGATIVE, ON DRIVE 1    *
                   * IF DRIVNO IS POSITIVE, ON DRIVE 2    *
                   ****************************************
d7cb: 0a           MYSEEK          asl     A                 ;Two phases per track
d7cc: 20 d3 d7                     jsr     MYSEEK2
d7cf: 4e 78 04                     lsr     CURTRK            ;Divide back down
d7d2: 60                           rts

d7d3: 85 2a        MYSEEK2         sta     TRKN              ;Save destination track(*2)
d7d5: 20 9a da                     jsr     SLOT_TO_Y         ;Set Y=Slot #
d7d8: b9 78 04                     lda     DRV1TRK,y
d7db: 24 35                        bit     DRIVNO
d7dd: 30 03                        bmi     WASD0             ;Is minus, on drive zero
d7df: b9 f8 04                     lda     DRV2TRK,y
d7e2: 8d 78 04     WASD0           sta     CURTRK            ;This is where I am
d7e5: a5 2a                        lda     TRKN              ;and where I'm going to
d7e7: 24 35                        bit     DRIVNO            ;Now update slot dependent
d7e9: 30 05                        bmi     ISDRV1            ;locations with track
d7eb: 99 f8 04                     sta     DRV2TRK,y         ;Information
d7ee: 10 03                        bpl     SEEK              ;Always taken

d7f0: 99 78 04     ISDRV1          sta     DRV1TRK,y
d7f3: 86 2b        SEEK            stx     SLOTTEMP          ;Save X-reg
d7f5: 85 2a                        sta     TRKN              ;Save target track
d7f7: cd 78 04                     cmp     CURTRK            ;On desired track
d7fa: f0 53                        beq     SEEKRTS           ;Yes return
d7fc: a9 00                        lda     #$00
d7fe: 85 26                        sta     TRKCNT            ;Half track count
d800: ad 78 04     SEEK2           lda     CURTRK            ;save CURTRK for 
d803: 85 27                        sta     PRIOR             ;Delayed turnoff
d805: 38                           sec
d806: e5 2a                        sbc     TRKN              ;Delta-tracks
d808: f0 33                        beq     SEEKEND           ;BR if CURTRK=DESTINATION
d80a: b0 07                        bcs     OUT               ;(move out not in)
d80c: 49 ff                        eor     #$ff              ;Calc tracks to go
d80e: ee 78 04                     inc     CURTRK            ;increment current track (IN)
d811: 90 05                        bcc     MINTST            ;(Always taken)

d813: 69 fe        OUT             adc     #$fe              ;Calc tracks to go
d815: ce 78 04                     dec     CURTRK            ;Decr current track (Out)
d818: c5 26        MINTST          cmp     TRKCNT
d81a: 90 02                        bcc     MAXTST            ;And 'trks moved'
d81c: a5 26                        lda     TRKCNT
d81e: c9 0c        MAXTST          cmp     #$0c
d820: b0 01                        bcs     STEP2             ;If TRKCNT>$B leave Y alone (Y=$B).
d822: a8                           tay                       ;Else set acceleration index in Y
d823: 38           STEP2           sec                       ;Carry set=phase on
d824: 20 41 d8                     jsr     SETPHASE          ;Phase on
d827: b9 8e da                     lda     ONTABLE,y         ;For 'on time'
d82a: 20 d9 d6                     jsr     MSWAIT            ;(100 uSec intervals)
d82d: a5 27                        lda     PRIOR
d82f: 18                           clc                       ;carry clear=phase off
d830: 20 44 d8                     jsr     CLRPHASE          ;Phase off
d833: b9 45 d5                     lda     OFFTABLE,y        ;then wait 'off time'
d836: 20 d9 d6                     jsr     MSWAIT            ;(100 uSec intervals)
d839: e6 26                        inc     TRKCNT
d83b: d0 c3                        bne     SEEK2
                   ; End of seeking
d83d: 20 d9 d6     SEEKEND         jsr     MSWAIT            ;A=0: Wait 25 mS settle
d840: 18                           clc                       ;And turn off phase
                   ; Turn head stepper phase on/off
d841: ad 78 04     SETPHASE        lda     CURTRK            ;Get current phase
d844: 29 03        CLRPHASE        and     #$03              ;Mask for 1 of 4 phases
d846: 2a                           rol     A                 ;Double for phase index
d847: 05 2b                        ora     SLOTTEMP
d849: aa                           tax
d84a: bd 80 c0                     lda     IWM_PH0_OFF,x     ;Flip the phase
d84d: a6 2b                        ldx     SLOTTEMP          ;Restore X-reg
d84f: 60           SEEKRTS         rts                       ;And return

d850: bd 8c c0     WRPROTERR       lda     IWM_Q6_OFF,x      ;Motor off
d853: a9 10                        lda     #$10              ;Flag write protect
d855: 38                           sec                       ;Set carry and go home
d856: 60                           rts

                   ; ************************************************************
                   ; * WRITE ADR FIELD SUBROUTINE (16-SECTOR FORMAT)            *
                   ; * WRITES SPECIFIED NUMBER OF 40-USEC (10-BIT) SELF-SYNC    *
                   ; * NIBLS, ADR FIELDS 16-SECTOR START MARKS ($D5,$AA,$96),   *
                   ; * BODY (VOLUME, TRACK, SECTOR, CHECKSUM), END FIELD MARKS, *
                   ; * AND THE WRITE TURN-OFF NIBL.                             *
                   ; ************************************************************
                   ; * ------- ON ENTRY -------                                 *
                   ; * THE LOCATIONS VOLUME, TRK, AND NSECT MUST CONTAIN THE    *
                   ; * DESIRED VOLUME, TRACK, AND SECTOR VALUES DESIRED.        *
                   ; * THE PROPER DRIVE MUST BE ENABLED AND UP TO SPEED IN      *
                   ; * READ MODE (Q7L, Q6L).                                    *
                   ; * X-REG CONTAINS SLOTNUM TIMES 16.                         *
                   ; * Y-REG CONTAINS NUMBER OF SELF-SYNC NIBLS DESIRED MINUS 1.*
                   ; * (0 FOR 256 NIBLS)                                        *
                   ; ************************************************************
                   ; * ------- REQUIRES -------                                 *
                   ; * 1 USEC CYCLE                                             *
                   ; ************************************************************
                   ; * ------- CAUTION --------                                 *
                   ; * MOST OF THIS CODE IS TIME  CRITICAL. OBSERVE ALL         *
                   ; * 'NO PAGE CROSS!' WARNINGS ON BRANCHES.                   *
                   ; ************************************************************
d857: bd 8d c0     WADR16          lda     IWM_Q6_ON,x       ;Into 'Wr prot sense' mode
d85a: bd 8e c0                     lda     IWM_Q7_OFF,x      ;Sense it (NEG=protected)
d85d: 30 f1                        bmi     WRPROTERR         ;Error exit if protected.
d85f: a9 ff                        lda     #$ff              ;Self-sync nibl.
d861: 9d 8f c0                     sta     IWM_Q7_ON,x       ;Write first nibl.
d864: dd 8c c0                     cmp     IWM_Q6_OFF,x      ;(4) back to write mode.
d867: 48                           pha                       ;(3) for delay
d868: 68                           pla                       ;(4)
d869: 20 c3 d8     WSYNC1          jsr     WADRTS1           ;(12) For 40 uSec nibls.
d86c: 20 c3 d8                     jsr     WADRTS1           ;(12)
d86f: 9d 8d c0                     sta     IWM_Q6_ON,x       ;(5) Write nibl.
d872: dd 8c c0                     cmp     IWM_Q6_OFF,x      ;(4) (back to write mode)
d875: ea                           nop                       ;(2) For delay
d876: 88                           dey                       ;(2) Next of 'N' nibls.
d877: d0 f0                        bne     WSYNC1            ;(3) *** NO PAGE CROSS! ***
d879: a9 d5                        lda     #$d5              ;(2) Adr Mark 1.
d87b: 20 e3 d8                     jsr     WNIBL2            ;(15, 9, 6) Write it.
d87e: a9 aa                        lda     #$aa              ;(2) Adr Mark 2.
d880: 20 e3 d8                     jsr     WNIBL2            ;(15, 9, 6) Write it.
d883: a9 96                        lda     #$96              ;(2) 16-sector adr mark 3.
d885: 20 e3 d8                     jsr     WNIBL2            ;(15, 9, 6) Write it.
d888: a5 41                        lda     NVOL              ;(3)
d88a: 20 d2 d8                     jsr     WBYTE             ;(14,9,6) Write NVOL (odd, then even bits.)
d88d: a5 44                        lda     TRK               ;(3) Write track number
d88f: 20 d2 d8                     jsr     WBYTE             ;(14,9,6) (odd, then even bits.)
d892: a5 3f                        lda     NSECT             ;(3) Write sector number.
d894: 20 d2 d8                     jsr     WBYTE             ;(14,9,6) (odd, then even bits.)
d897: a5 41                        lda     NVOL              ;(3)
d899: 45 44                        eor     TRK               ;(3) Form adr field checksum.
d89b: 45 3f                        eor     NSECT             ;(3)
d89d: 48                           pha                       ;(3) Save for even bits
d89e: 4a                           lsr     A                 ;(2) Align odd bits
d89f: 05 3e                        ora     AA                ;(3) Set clock bits.
                   ; (Precise timing, 32 cycles per nibl)
d8a1: 9d 8d c0                     sta     IWM_Q6_ON,x       ;(5) Write checksum odd bits.
d8a4: bd 8c c0                     lda     IWM_Q6_OFF,x      ;(4) back to write mode.
d8a7: 68                           pla
d8a8: 09 aa                        ora     #$aa              ;(2) set clock bits.
d8aa: 20 e2 d8                     jsr     WNIBLA            ;(17, 9, 6) Write them.
d8ad: a9 de                        lda     #$de              ;End mark 1.
d8af: 20 e3 d8                     jsr     WNIBL2            ;(15, 9, 6) Write it.
d8b2: a9 aa                        lda     #$aa              ;End mark 2.
d8b4: 20 e3 d8                     jsr     WNIBL2            ;(15, 9, 6) Write it.
d8b7: a9 eb                        lda     #$eb              ;End mark 3.
d8b9: 20 e3 d8                     jsr     WNIBL2            ;(15, 9, 6) 'Write turn off'
d8bc: 18                           clc                       ;Indicate no Wr Prot Err.
d8bd: bd 8e c0                     lda     IWM_Q7_OFF,x      ;Out of write mode
d8c0: bd 8c c0                     lda     IWM_Q6_OFF,x      ;To read mode.
d8c3: 60           WADRTS1         rts

                   ****************************************
                   *                                      *
                   * Wait time for motor to come up to    *
                   * speed before starting to write to    *
                   * disk, finishing off any time left    *
                   * over.                                *
                   *                                      *
                   ****************************************
d8c4: a0 12        MOTOF           ldy     #$12              ;Delay 100 uSec per count
d8c6: 88           CONWAIT         dey
d8c7: d0 fd                        bne     CONWAIT
d8c9: e6 46                        inc     MONTIMEL
d8cb: d0 f7                        bne     MOTOF
d8cd: e6 47                        inc     MONTIMEH
d8cf: d0 f3                        bne     MOTOF             ;Count up to $0000
d8d1: 60                           rts

                   ; 
                   ; Write a byte routine during formatting in 4-4 format
                   ;  
d8d2: 48           WBYTE           pha                       ;(3) Preserve for even bits.
d8d3: 4a                           lsr     A                 ;(2) align odd bits.
d8d4: 05 3e                        ora     AA                ;(3) Set clock bits
d8d6: 9d 8d c0                     sta     IWM_Q6_ON,x       ;(5) Write nibl.
d8d9: dd 8c c0                     cmp     IWM_Q6_OFF,x      ;(4)
d8dc: 68                           pla                       ;(4) Recover even bits
d8dd: ea                           nop                       ;(2)
d8de: ea                           nop                       ;(2) For delay
d8df: ea                           nop                       ;(2)
d8e0: 09 aa                        ora     #$aa              ;(2) Set clock bits.
d8e2: ea           WNIBLA          nop                       ;(2) (17,9,6) Entry
d8e3: ea           WNIBL2          nop                       ;(2) (15,9,6) Entry
d8e4: 48                           pha                       ;(3) For
d8e5: 68                           pla                       ;(4) delay.
d8e6: 9d 8d c0                     sta     IWM_Q6_ON,x       ;(5) Write nibl.
d8e9: dd 8c c0                     cmp     IWM_Q6_OFF,x      ;(4)
d8ec: 60           WBYTERTS        rts                       ;(6) Return

                   ****************************************
                   *                                      *
                   * Unused code anywhere in this BIOS    *
                   * Looks like it searches for card type *
                   * in the slots, skipping slot 6.       *
                   *                                      *
                   ****************************************
d8ed: a2 07                        ldx     #$07              ;Looks like this searches for a card type in Acc
d8ef: e0 06        D2NXTSLT        cpx     #$06              ;Slot is 6
d8f1: f0 05                        beq     SKIPSL6           ;Skip it
d8f3: dd b8 03                     cmp     SLOT_INFO,x       ;Found the card type we're looking for?
d8f6: f0 08                        beq     FOUNDCARD         ;Yes, rotate left....
d8f8: ca           SKIPSL6         dex
d8f9: d0 f4                        bne     D2NXTSLT          ;Next slot
d8fb: 68                           pla                       ;Remove callers address
d8fc: 68                           pla
d8fd: 4c c5 da                     jmp     SET_DISK_ERR1     ;Exit via error.

d900: 8a           FOUNDCARD       txa                       ;Set acc to Slot * 16
d901: 0a                           asl     A
d902: 0a                           asl     A
d903: 0a                           asl     A
d904: 0a                           asl     A
d905: 60                           rts

                   ; ProDOS logical sector to physical disk translation table
d906: 00 02 04 06+ PD_SECT_TRAN    .bulk   $00,$02,$04,$06,$08,$0a,$0c,$0e
d90e: 01 03 05 07+                 .bulk   $01,$03,$05,$07,$09,$0b,$0d,$0f

                   ; ******************************
                   ; *                            *
                   ; *   WRITE TRACK SUBROUTINE   *
                   ; *                            *
                   ; ******************************
d916: a9 00        WTRACK16        lda     #$00
d918: 85 3f                        sta     NSECT             ;Sector number, 0 to 15
d91a: a0 80                        ldy     #128              ;128 NIBs prior sector 0
d91c: d0 02                        bne     WSECT0            ;To insure no blank spot betw 15 & 0

d91e: a4 45        WSECT           ldy     NSYNC             ;Current num of gap self-sync nibls
d920: 20 57 d8     WSECT0          jsr     WADR16            ;Write gap and adr field
d923: b0 c7                        bcs     WBYTERTS          ;Err if write protected
d925: 20 00 d6                     jsr     WRITE16
d928: ea                           nop                       ;Was branch if write protected
d929: ea                           nop                       ;in original RWTS code
d92a: e6 3f                        inc     NSECT             ;Next of 16 sectors
d92c: a5 3f                        lda     NSECT
d92e: c9 10                        cmp     #$10
d930: 90 ec                        bcc     WSECT             ;Continue if not done
                   ; ****************************************************
                   ; * VERIFY ROUTINE                                   *
                   ; * VERIFIES THAT THE FIRST SECTOR ENCOUNTERED IS    *
                   ; * SECTOR 0, AND THAT ALL 16 SECTORS ARE READABLE   *
                   ; * WITH MINIMAL RETRIES. (2 REVOLUTIONS MAXIMUM)    *
                   ; * IF FIRST SECTOR IS NOT SECTOR 0 THEN THE         *
                   ; * CURRENT NUMBER OF SELF-SYNC NIBLS IS DECR'D BY   *
                   ; * 1 (IF ALREADY LESS THAN 16) OR BY 2. THEN SECTOR *
                   ; * 15 IS LOCATED SO AS TO POSITION THE NEW TRACK    *
                   ; * REWRITE.                                         *
                   ; * IF UNABLE TO READ ANY SECTOR THEN THE ENTIRE     *
                   ; * TRACK IS REWRITTEN.                              *
                   ; * AFTER VERIFYING TRACK 0, THE NUMBER OF SELF-SYNC *
                   ; * NIBLS, NSYNC, IS DECR'D BY 2 (IF STILL 16 OR     *
                   ; * GREATER).                                        *
                   ; ****************************************************
d932: a0 0f                        ldy     #$0f
d934: 84 3f                        sty     NSECT             ;Set 16 bytes of
d936: a9 30                        lda     #$30              ;sector found table
d938: 8d 78 05                     sta     RETRYCNT          ;to $30 (Mark them)
d93b: 99 57 df     CLRFOUND        sta     FOUND,y
d93e: 88                           dey
d93f: 10 fa                        bpl     CLRFOUND
d941: a4 45                        ldy     NSYNC             ;Delay 50 uSec for every
d943: 20 91 d9     S0DELAY         jsr     WEXIT2            ;(12) Self sync nibl
d946: 20 91 d9                     jsr     WEXIT2            ;(12) Expected to insure
d949: 20 91 d9                     jsr     WEXIT2            ;(12) proper gap prior sector 0
d94c: 48                           pha                       ;(3) Note this code is possibly wrong 
d94d: 68                           pla                       ;(4) as the jsr is to the SEC
d94e: ea                           nop                       ;(2) rather the RTS in RWTS source
d94f: 88                           dey                       ;(2)
d950: d0 f1                        bne     S0DELAY           ;(3)
d952: 20 6f d7                     jsr     RDADR16           ;Read next address field
d955: b0 23                        bcs     S15LOC            ;Err, locate sect 15 and rewrite trk.
d957: a5 2d                        lda     SECTOR            ;Was it sector 0
d959: f0 15                        beq     VDATA             ;Yes, now verify data field
d95b: a9 10                        lda     #$10
d95d: c5 45                        cmp     NSYNC             ;Decr NSYNC by 1 if less than
d95f: a5 45                        lda     NSYNC             ;16, by 2 if not less
d961: e9 01                        sbc     #$01
d963: 85 45                        sta     NSYNC
d965: c9 05                        cmp     #$05              ;If less than 5, unrecoverable
d967: b0 11                        bcs     S15LOC            ;err, else rewrite after data fld 15
d969: 90 24                        bcc     VERR              ;Extremely fast or severe error

d96b: 20 6f d7     VSECT           jsr     RDADR16           ;Read an address field
d96e: b0 05                        bcs     VERR1             ;Retry if error
d970: 20 07 d7     VDATA           jsr     READ16            ;Read data field
d973: 90 1e                        bcc     SECTOK            ;(Good)
d975: ce 78 05     VERR1           dec     RETRYCNT          ;Next of 48 sector tries.
d978: d0 f1                        bne     VSECT             ;(Keep trying)
d97a: 20 6f d7     S15LOC          jsr     RDADR16           ;Read address field
d97d: b0 0b                        bcs     NOTS15            ;Err, try up to 128 times.
d97f: a5 2d                        lda     SECTOR            ;Sector that was read.
d981: c9 0f                        cmp     #$0f              ;Sector 15?
d983: d0 05                        bne     NOTS15            ;No, continue searching
d985: 20 07 d7                     jsr     READ16            ;Read data field
d988: 90 8c                        bcc     WTRACK16          ;Write track from here if no err.
d98a: ce 78 05     NOTS15          dec     RETRYCNT          ;$FF to $7F, 128 tries.
d98d: d0 eb                        bne     S15LOC            ;Try for sect 15 again
d98f: a9 01        VERR            lda     #$01
d991: 38           WEXIT2          sec                       ;Set carry to indicate error
d992: 60           WEXIT3          rts                       ;Return to formatter

d993: a4 2d        SECTOK          ldy     SECTOR            ;This is sector read
d995: b9 57 df                     lda     FOUND,y           ;already found?
d998: 30 db                        bmi     VERR1             ;Yes, ignore it.
d99a: a9 ff                        lda     #$ff
d99c: 99 57 df                     sta     FOUND,y           ;Indicate this sect now found
d99f: c6 3f                        dec     NSECT             ;Found 16 sectors?
d9a1: 10 c8                        bpl     VSECT             ;No, look for next.
d9a3: a5 44                        lda     TRK
d9a5: d0 0a                        bne     WEXIT1            ;If track and NSYNC > 16
d9a7: a5 45                        lda     NSYNC             ;(Num gap sync nibls)
d9a9: c9 10                        cmp     #$10              ;Then subtract 2 from NSYBC
d9ab: 90 e5                        bcc     WEXIT3            ;To avoid retries on later trks.
d9ad: c6 45                        dec     NSYNC
d9af: c6 45                        dec     NSYNC
d9b1: 18           WEXIT1          clc                       ;Indicate no error.
d9b2: 60                           rts                       ;Return.

                   ; ****************************
                   ; *                          *
                   ; *  FORMAT DISK AND RETURN  *
                   ; *                          *
                   ; ****************************
d9b3: 20 c4 d8     DSKFORM         jsr     MOTOF             ;Wait for motor to come up to speed
d9b6: ad 87 03                     lda     DISK_VOL          ;Copy volume number
d9b9: 85 41                        sta     NVOL              ;For formatter
d9bb: a9 aa                        lda     #$aa              ;Set z-pag loc to $AA for
d9bd: 85 3e                        sta     AA                ;Time dependent references
d9bf: a0 56                        ldy     #$56
d9c1: a9 00                        lda     #$00              ;Track number, 0 to 34
d9c3: 85 44                        sta     TRK
d9c5: a9 2a                        lda     #$2a              ;Clear NBUFS to write sectors
d9c7: 99 ff de     CLRNBUF2        sta     NBUF2-1,y         ;Different values from RWTS
d9ca: 88                           dey
d9cb: d0 fa                        bne     CLRNBUF2
d9cd: a9 39                        lda     #$39              ;$E5 shr 2 for empty CP/M directory 
d9cf: 99 00 de     CLRNBUF1        sta     NBUF1,y
d9d2: 88                           dey
d9d3: d0 fa                        bne     CLRNBUF1
d9d5: a9 23                        lda     #35               ;Set the max track to format
d9d7: 85 3d                        sta     MAXTRK
d9d9: a9 2a                        lda     #42
d9db: 20 ee d6                     jsr     SETTRK            ;Fake like on track 42
d9de: a9 28                        lda     #$28
d9e0: 85 45                        sta     NSYNC             ;Begin with 40 self-sync nibls.
d9e2: a5 44        FORMTRK         lda     TRK
d9e4: 20 cb d7                     jsr     MYSEEK            ;Goto next track
d9e7: 20 16 d9                     jsr     WTRACK16          ;Write and verify track
d9ea: b0 27                        bcs     FORMDONE          ;Error go home
d9ec: a9 30                        lda     #$30              ;Upto 48 sector retries
d9ee: 8d 78 05                     sta     RETRYCNT          ;to find sector 0
d9f1: 38           FINDS0          sec                       ;Anticpate 'unable to format'
d9f2: ce 78 05                     dec     RETRYCNT          ;Done 48 retries?
d9f5: f0 1a                        beq     FORMERR           ;If so, 'Unable to format' err.
d9f7: 20 6f d7                     jsr     RDADR16           ;Read adr field
d9fa: b0 f5                        bcs     FINDS0            ;Retry if err
d9fc: a5 2d                        lda     SECTOR            ;Check sector that was read.
d9fe: d0 f1                        bne     FINDS0            ;Continue searching if not sect 0
da00: 20 07 d7                     jsr     READ16            ;Now read data field
da03: b0 ec                        bcs     FINDS0            ;Continue search if err.
da05: e6 44                        inc     TRK               ;Increment track number
da07: a5 3d                        lda     MAXTRK
da09: c5 44                        cmp     TRK               ;Continue if less than 25
da0b: d0 d5                        bne     FORMTRK
da0d: a9 00                        lda     #$00              ;Return back success
da0f: f0 02                        beq     FORMDONE

da11: a9 01        FORMERR         lda     #$01
da13: 8d 89 03     FORMDONE        sta     DISK_ERR          ;FORMDONE
da16: bd 88 c0                     lda     IWM_MOTOR_OFF,x
da19: 60                           rts

                   ****************************************
                   *                                      *
                   * Do a read or write on a whole track  *
                   *                                      *
                   ****************************************
da1a: a9 00        D2TRACKOPER     lda     #$00
da1c: 8d 81 03                     sta     DISK_SECT
da1f: ad a1 d6                     lda     PRENIBPAGE+2      ;Save data buffer page value for writes
da22: 8d 67 df                     sta     D2SAVWRDTAPG
da25: ad d2 d6                     lda     POSTNBPAGE+2      ;Save data buffer page value for reads
da28: 8d 68 df                     sta     D2SAVRDDTAPG
da2b: ad 07 d5                     lda     DOSECTTRAN+1      ;Save CPM sector translate
da2e: 8d 69 df                     sta     D2SAVETRAN
da31: ad 08 d5                     lda     DOSECTTRAN+2
da34: 8d 6a df                     sta     D2SAVETRAN+1
da37: a9 d9                        lda     #>PD_SECT_TRAN    ;Swap to Prodos sector translate
da39: 8d 08 d5                     sta     DOSECTTRAN+2
da3c: a9 06                        lda     #<PD_SECT_TRAN
da3e: 8d 07 d5                     sta     DOSECTTRAN+1
da41: ad 82 03                     lda     DISK_TRK_ADDR     ;Set up data pointers
da44: 8d a1 d6                     sta     PRENIBPAGE+2
da47: 8d d2 d6                     sta     POSTNBPAGE+2
da4a: a9 02        D2TRKNXTSECT    lda     #$02
da4c: 8d f8 06                     sta     RECALCNT
da4f: a9 04                        lda     #$04
da51: 8d f8 04                     sta     DRV2TRK
da54: ad 88 03                     lda     DISK_OP
da57: 20 a8 d4                     jsr     TRYTRK
da5a: b0 19                        bcs     D2TRACKOPEX       ;Had an error go home
da5c: bd 89 c0                     lda     IWM_MOTOR_ON,x    ;Leave the motor running
da5f: ee a1 d6                     inc     PRENIBPAGE+2      ;Increment data pointer
da62: ee d2 d6                     inc     POSTNBPAGE+2
da65: ee 81 03                     inc     DISK_SECT         ;Bounce sector
da68: ee 82 03                     inc     DISK_TRK_ADDR     ;And the data pointer
da6b: a9 10                        lda     #$10              ;Done a track?
da6d: cd 81 03                     cmp     DISK_SECT
da70: d0 d8                        bne     D2TRKNXTSECT      ;Nope loop
da72: bd 88 c0                     lda     IWM_MOTOR_OFF,x
da75: ad 67 df     D2TRACKOPEX     lda     D2SAVWRDTAPG      ;Put back data buffer pages for writes
da78: 8d a1 d6                     sta     PRENIBPAGE+2
da7b: ad 68 df                     lda     D2SAVRDDTAPG      ;Put back data buffer pages for reads
da7e: 8d d2 d6                     sta     POSTNBPAGE+2
da81: ad 69 df                     lda     D2SAVETRAN        ;Put back CPM sector translate
da84: 8d 07 d5                     sta     DOSECTTRAN+1
da87: ad 6a df                     lda     D2SAVETRAN+1
da8a: 8d 08 d5                     sta     DOSECTTRAN+2
da8d: 60                           rts

                   ; Table of on timings for the stepper motor
da8e: 01 30 28 24+ ONTABLE         .bulk   $01,$30,$28,$24,$20,$1e,$1d,$1c
da96: 1c 1c 1c 1c                  .bulk   $1c,$1c,$1c,$1c
                   ; Get the current slot number into Y
da9a: ad f8 05     SLOT_TO_Y       lda     DISKSLOTCX        ;Get slot number *16
da9d: 4a                           lsr     A                 ;Divide by 16
da9e: 4a                           lsr     A
da9f: 4a                           lsr     A
daa0: 4a                           lsr     A
daa1: a8                           tay                       ;Put Acc into Y
daa2: 60                           rts

                   ; What sort of not Disk ][ is it?
daa3: c9 07        IDC_CHECK       cmp     #$07              ;What sort of drive?
daa5: f0 03                        beq     SMARTDRV_FOUND    ;Smartdrive is for RAM drives
daa7: 4c fe da                     jmp     PRODOS

                   ********************************************************************************
                   * SmartDrive code                                                              *
                   ********************************************************************************
daaa: 8a           SMARTDRV_FOUND  txa                       ;Convert to CX
daab: 09 c0                        ora     #$c0
daad: 8d eb da                     sta     SMARTDRV_CALL+2   ;Save slot rom into call high
dab0: 8d b5 da                     sta     GET_SMARTDRV_ADDR+2 ;Save slot rom to get entry point
                   GET_SMARTDRV_ADDR
dab3: ad ff c7                     lda     SCC_INIT-1        ;Get the entry point
dab6: 18                           clc
dab7: 69 03                        adc     #$03              ;Add 3 to get smartdrive point
dab9: 8d ea da                     sta     SMARTDRV_CALL+1   ;Update the call low byte
dabc: ad 88 03                     lda     DISK_OP
dabf: f0 04                        beq     SET_DISK_ERR1     ;Status returns error $01
dac1: c9 03                        cmp     #$03              ;Read or write
dac3: 90 04                        bcc     SMART_CMDOK       ;Yep carry on
dac5: a2 01        SET_DISK_ERR1   ldx     #$01              ;Set disk error to 1 (bad cmd)
dac7: d0 31                        bne     SET_DISK_ERRX

dac9: 69 07        SMART_CMDOK     adc     #$07              ;Change from Block to byte command
dacb: 8d ec da                     sta     SMARTDRV_CMD
                   ; For the smart drive address to read is
                   ; (TRACKH*$100+TRACKL) * $10 + SECT*2
dace: 0e 81 03                     asl     DISK_SECT         ;8 sectors per track
dad1: ad 80 03                     lda     DISK_TRKL
dad4: a0 04                        ldy     #$04              ;Shift left 4 times (aka mult by 16)
dad6: 0a           SMART_MUL       asl     A
dad7: 2e 86 03                     rol     DISK_TRKH
dada: 88                           dey
dadb: d0 f9                        bne     SMART_MUL
dadd: 0d 81 03                     ora     DISK_SECT         ;Or in the sector
dae0: 8d aa db                     sta     SMARTDRV_BLOCKNUM+1 ;Save blocknumber into parameters
dae3: ad 86 03                     lda     DISK_TRKH
dae6: 8d ab db                     sta     SMARTDRV_BLOCKNUM+2
dae9: 20 00 00     SMARTDRV_CALL   jsr     $0000
daec: 08           SMARTDRV_CMD    .dd1    $08
daed: a3 db                        .dd2    SMARTDRV_PARAM

daef: a2 00        PD_CHECK_ERR    ldx     #$00              ;Everything happy
daf1: 90 07                        bcc     SET_DISK_ERRX     ;Yeah store success and return
daf3: e8                           inx                       ;Nope setup for a error
daf4: c9 2b                        cmp     #$2b              ;Write protected error?
daf6: d0 02                        bne     SET_DISK_ERRX     ;Lets say it's generic error
daf8: a2 10                        ldx     #$10              ;Write protect error
dafa: 8e 89 03     SET_DISK_ERRX   stx     DISK_ERR
dafd: 60                           rts

                   ********************************************************************************
                   * Prodos driver code                                                           *
                   ********************************************************************************
dafe: 8a           PRODOS          txa
daff: 09 c0                        ora     #$c0
db01: 8d 2c db                     sta     PD_CALL_DRIVER+2  ;Patch up the driver call
db04: 8d 09 db                     sta     PD_GET_ENTRY+2    ;Patch the call to find the driver entry
db07: ad ff c7     PD_GET_ENTRY    lda     SCC_INIT-1        ;Get the entry point
db0a: 8d 2b db                     sta     PD_CALL_DRIVER+1  ;Patch the call
db0d: ad 84 03                     lda     DISK_DRV
db10: 85 43                        sta     PRODOS_UNITNUM
db12: ad 88 03                     lda     DISK_OP           ;Status commmand? Return eror
db15: f0 ae                        beq     SET_DISK_ERR1
db17: c9 04                        cmp     #$04              ;Greater than 3 not simple.
db19: b0 3c                        bcs     PD_MULT_SECT_OP
db1b: 48                           pha
db1c: 20 8d db                     jsr     TRKSEC2PD_BLK     ;Convert track / sector to ProDosBloc
db1f: 68                           pla
db20: 85 42        PD_ALT_CALL     sta     PRODOS_CMD        ;Copy the command over
db22: a9 00                        lda     #$00
db24: 85 44                        sta     PRDOOS_BUFPTRL    ;Buffer is at $800
db26: a9 08                        lda     #$08
db28: 85 45                        sta     PRDOOS_BUFPTRL+1
db2a: 20 00 00     PD_CALL_DRIVER  jsr     $0000
db2d: 20 ef da                     jsr     PD_CHECK_ERR
db30: b0 06                        bcs     PD_EXIT           ;Did we have an error?
db32: a5 42                        lda     PRODOS_CMD
db34: c9 03                        cmp     #$03              ;Was it initialise?
db36: f0 01                        beq     PD_INIT_DATA      ;Do the rest of the track
db38: 60           PD_EXIT         rts

db39: a9 18        PD_INIT_DATA    lda     #$18              ;Looks like this skips the first three tracks
db3b: 8d 81 03                     sta     DISK_SECT
db3e: a9 00        PD_INIT_WR      lda     #$00              ;Zero the high block
db40: 85 47                        sta     PRODOS_BLKNUM+1
db42: ad 81 03                     lda     DISK_SECT         ;Which block to write
db45: 85 46                        sta     PRODOS_BLKNUM
db47: a9 02                        lda     #$02              ;Setup for a write
db49: 20 20 db                     jsr     PD_ALT_CALL       ;Write out sector
db4c: b0 ea                        bcs     PD_EXIT           ;Error go home
db4e: ee 81 03                     inc     DISK_SECT         ;Next sector
db51: ce 80 03                     dec     DISK_TRKL         ;Until the counter =0
db54: d0 e8                        bne     PD_INIT_WR
db56: 60                           rts

                   ********************************************************************************
                   * We get here if the command is greater than or equal to four.                 *
                   * Normal ProDOS commands are                                                   *
                   * 0 - Status                                                                   *
                   * 1 - Read                                                                     *
                   * 2 - Write                                                                    *
                   * 3 - Init                                                                     *
                   * Extended commands (read / write a whole track)                               *
                   * 4 - gets translated as (4-3)^3 so to a 2 - Write                             *
                   * 5 - gets translated as (5-3)^3 so to a 1 - Read                              *
                   * 6 - gets translated as (6-3)^3 so to a 0 - status                            *
                   ********************************************************************************
db57: 38           PD_MULT_SECT_OP sec                       ;Do the conversion
db58: e9 03                        sbc     #$03
db5a: 49 03                        eor     #$03
db5c: 85 42                        sta     PRODOS_CMD        ;Set the command
db5e: a9 08                        lda     #$08              ;Whole track?
db60: 8d ac db                     sta     PD_TRACK_OP_CNT
db63: ad 82 03                     lda     DISK_TRK_ADDR     ;Get disk data pointer
db66: 85 45                        sta     NSYNC
db68: a9 00                        lda     #$00
db6a: 8d 81 03                     sta     DISK_SECT         ;We're doing the whole track
db6d: 85 44                        sta     PRDOOS_BUFPTRL
db6f: 20 8d db                     jsr     TRKSEC2PD_BLK     ;Convert to PD block
                   PD_TRACK_OP_LOOP
db72: 20 2a db                     jsr     PD_CALL_DRIVER
db75: b0 c1                        bcs     PD_EXIT           ;Flag we had an error
db77: ee 82 03                     inc     DISK_TRK_ADDR     ;Add 512 bytes to destination / source
db7a: ee 82 03                     inc     DISK_TRK_ADDR
db7d: e6 46                        inc     MONTIMEL          ;Bounce the block number along
db7f: d0 02                        bne     PD_BLK_NO_WRAP
db81: e6 47                        inc     PRODOS_BLKNUM+1
db83: e6 45        PD_BLK_NO_WRAP  inc     NSYNC             ;Do the ProDOS address
db85: e6 45                        inc     NSYNC
db87: ce ac db                     dec     PD_TRACK_OP_CNT   ;Do the loop
db8a: d0 e6                        bne     PD_TRACK_OP_LOOP
db8c: 60                           rts

db8d: ad 86 03     TRKSEC2PD_BLK   lda     DISK_TRKH         ;Prodos block is TRACK*8 + SECT
db90: 85 47                        sta     PRODOS_BLKNUM+1
db92: ad 80 03                     lda     DISK_TRKL
db95: a2 03                        ldx     #$03
db97: 0a           BLK_MULT_2      asl     A                 ;Multiply by two
db98: 26 47                        rol     MONTIMEH
db9a: ca                           dex
db9b: d0 fa                        bne     BLK_MULT_2
db9d: 0d 81 03                     ora     DISK_SECT         ;Add sector
dba0: 85 46                        sta     MONTIMEL
dba2: 60                           rts

dba3: 04           SMARTDRV_PARAM  .dd1    $04
                   SMARTDRV_UNITNUM
dba4: 01                           .dd1    $01
dba5: 00 08        SMARTDRV_BUFPTR .dd2    $0800
                   SMARTDRV_NUMBYTES
dba7: 00 02                        .dd2    $0200
                   SMARTDRV_BLOCKNUM
dba9: 00                           .dd1    $00
dbaa: 00                           .dd1    $00
dbab: 00                           .dd1    $00
dbac: 00           PD_TRACK_OP_CNT .dd1    $00
dbad: 00 00 00 00+                 .fill   83,$00
                                   .adrend ↑ ~$d400

                   ********************************************************************************
                   * Character mode device BIOS.                                                  *
                   * These get copied out of $DC00 into $0A00                                     *
                   * They also get copied into the other bank of memory                           *
                   * On entry:                                                                    *
                   * A  = Character to read / write OR                                            *
                   *      0 = Output status check                                                 *
                   *      1 = Input status check                                                  *
                   * X  = Device slot                                                             *
                   *  0  = Console                                                                *
                   *  1..7 Slot number                                                            *
                   *  $80   Toggle cursor on off                                                  *
                   * Y  = operation                                                               *
                   *  $0D = Init                                                                  *
                   *  $0E = Read character                                                        *
                   *  $0F = Write character                                                       *
                   *  $10 = Get status                                                            *
                   ********************************************************************************
                                   .addrs  $0a00
0a00: d8                           cld                       ;Clear decimal mode
0a01: 48                           pha                       ;Put acc on stack
0a02: 8a                           txa                       ;Which slot / what are doing?
0a03: d0 09                        bne     CHECK_CUR_TOG     ;Output to console?
0a05: 2c 8b c0                     bit     LCBANK1           ;Yes, page in video BIOS in language card
0a08: 2c 8b c0                     bit     LCBANK1
0a0b: 4c 03 d0                     jmp     PRINT_STACK_CHAR  ;Put top of stack onto screen

0a0e: 10 09        CHECK_CUR_TOG   bpl     DO_SLOT_IO        ;Slot number positive
0a10: 2c 8b c0                     bit     LCBANK1           ;Nope, so page in video BIOS
0a13: 2c 8b c0                     bit     LCBANK1
0a16: 4c 00 d0                     jmp     TOG_CURJMP        ;And toggle the cursor

                   ; See what sort of card is in the slot
0a19: 8e 0c 0b     DO_SLOT_IO      stx     PAGEINROM2+1      ;Setup for paging in rom
0a1c: bd b8 03                     lda     SLOT_INFO,x       ;Get the card type
0a1f: 29 0f                        and     #$0f              ;Mask to low nybble
0a21: 48                           pha                       ;Save it for later
0a22: 8a                           txa                       ;Multiply slot number by 8
0a23: 0a                           asl     A
0a24: 0a                           asl     A
0a25: 0a                           asl     A
0a26: 0a                           asl     A
0a27: aa                           tax                       ;X = Slot number * 8
0a28: 68                           pla
0a29: c9 03                        cmp     #$03              ;Apple Comms or CCS7710A
0a2b: f0 78                        beq     COMMS6550
0a2d: c9 04                        cmp     #$04              ;High speed serial
0a2f: f0 60                        beq     SSC
0a31: c9 05                        cmp     #$05              ;Parallel printer
0a33: f0 36                        beq     APPLEPARA
0a35: c9 06                        cmp     #$06              ;Pascal based card
0a37: f0 03                        beq     PASCALCARD
0a39: 68                           pla                       ;Remove actual character
0a3a: d0 66                        bne     CHAR_RET_0        ;Go home
                   ; 
                   ; Pascal card
                   ;  
0a3c: 68           PASCALCARD      pla                       ;Get back the character
0a3d: c0 0e                        cpy     #CHAR_OP_RD       ;Read operation?
0a3f: f0 13                        beq     DOPASCAL_OP       ;Go Do it
0a41: c0 0f                        cpy     #CHAR_OP_WR       ;Write operation
0a43: f0 0f                        beq     DOPASCAL_OP       ;Go Do it
0a45: c0 0d                        cpy     #CHAR_OP_INI      ;Init operation?
0a47: f0 0b                        beq     DOPASCAL_OP       ;Go Do it
0a49: c0 10                        cpy     #CHAR_OP_ST       ;Status operation?
0a4b: d0 55                        bne     CHAR_RET_0        ;Lie and return OK
0a4d: 20 54 0a                     jsr     DOPASCAL_OP       ;Go do our operation
0a50: b0 3c                        bcs     CARDRETFF         ;Result is No
0a52: 90 4e                        bcc     CHAR_RET_0        ;Result is Yes

0a54: 8c 62 0a     DOPASCAL_OP     sty     GETPASENTRY+1     ;Save offset of pascal entry
0a57: 48                           pha                       ;Save Acc
0a58: 20 06 0b                     jsr     PAGEINROM         ;Page in $C800 ROM 
0a5b: 8e 63 0a                     stx     GETPASENTRY+2     ;Save Cx00 into get offset instruction
0a5e: 8e 6a 0a                     stx     JMPPASENTRY+2     ;Save Cx00 into call to card
0a61: ad 00 c1     GETPASENTRY     lda     $c100             ;Get the offset of the operation
0a64: 8d 69 0a                     sta     JMPPASENTRY+1     ;Save it into jump to pascal operation
0a67: 68                           pla                       ;Get back character
0a68: 4c 00 c1     JMPPASENTRY     jmp     $c100             ;Go call card routine

                   ; 
                   ; Apple Parallel card code
                   ;  
0a6b: 68           APPLEPARA       pla                       ;Get back the character
0a6c: c0 0d                        cpy     #CHAR_OP_INI      ;No initialise routine
0a6e: f0 1e                        beq     CARDRETFF         ;So go home
0a70: c0 10                        cpy     #CHAR_OP_ST       ;Get status
0a72: f0 0f                        beq     PARA_STATUS       ;Go do it
0a74: c0 0f                        cpy     #CHAR_OP_WR       ;CHAR_OP_WR
0a76: d0 2a                        bne     CHAR_RET_0        ;Do the write
0a78: 48                           pha                       ;Save character
0a79: 20 83 0a     PARASTLOOP      jsr     PARA_STATUS       ;Check status
0a7c: f0 fb                        beq     PARASTLOOP        ;Wait until clear
0a7e: 68                           pla                       ;Get back character
0a7f: 99 80 c0                     sta     PARA_DATAOUT,y    ;Output the character to card
0a82: 60                           rts                       ;Go home

0a83: 20 06 0b     PARA_STATUS     jsr     PAGEINROM         ;Page in the rom (sets X)
0a86: 8e 8b 0a                     stx     GETPARASTAT+2
0a89: ad c1 c0     GETPARASTAT     lda     PARA_ACKIN        ;Get the status
0a8c: 30 14                        bmi     CHAR_RET_0        ;Busy?
0a8e: a9 ff        CARDRETFF       lda     #$ff              ;Nope
0a90: 60                           rts

                   ; 
                   ; Super serial card code, calls pascal entry points directly
                   ;  
0a91: 68           SSC             pla                       ;Get back character
0a92: c0 10                        cpy     #CHAR_OP_ST       ;Status
0a94: f0 f8                        beq     CARDRETFF         ;Return good always
0a96: c0 0d                        cpy     #CHAR_OP_INI      ;Init?
0a98: f0 66                        beq     JSRSCCINIT        ;Go do it
0a9a: c0 0f                        cpy     #CHAR_OP_WR       ;Write?
0a9c: f0 57                        beq     JSRSCCWRITE       ;Go do it
0a9e: c0 0e                        cpy     #CHAR_OP_RD       ;Read a character
0aa0: f0 49                        beq     JSRSSCREAD        ;Go do it
0aa2: a9 00        CHAR_RET_0      lda     #$00
0aa4: 60                           rts

                   ; 
                   ; 6650 based serial comms card
                   ; CCS7710 or Apple Communications
                   ;  
0aa5: 68           COMMS6550       pla
0aa6: c0 10                        cpy     #CHAR_OP_ST       ;Status operation
0aa8: f0 28                        beq     STATUS6550
0aaa: c0 0f                        cpy     #CHAR_OP_WR       ;Write operation
0aac: f0 15                        beq     WRITE6550
0aae: c0 0d                        cpy     #CHAR_OP_INI      ;Initialise
0ab0: f0 2d                        beq     INIT6550
0ab2: c0 0e                        cpy     #CHAR_OP_RD       ;Read operation
0ab4: d0 ec                        bne     CHAR_RET_0
0ab6: a9 01        RD6550WAIT      lda     #$01              ;Wait for read data
0ab8: 20 d2 0a                     jsr     STATUS6550
0abb: f0 f9                        beq     RD6550WAIT        ;Nothing yet
0abd: bd 8f c0                     lda     DATA6510,x        ;Get our data
0ac0: a9 ff                        lda     #$ff              ;And over write it!!!!
0ac2: 60                           rts

0ac3: 48           WRITE6550       pha                       ;Save character
0ac4: a9 00        WR6550WAIT      lda     #$00              ;Check write status
0ac6: 20 d2 0a                     jsr     STATUS6550
0ac9: f0 f9                        beq     WR6550WAIT        ;Wait until we can write
0acb: 68                           pla                       ;Get character back
0acc: 9d 8f c0                     sta     DATA6510,x        ;Send it
0acf: a9 ff                        lda     #$ff
0ad1: 60                           rts

0ad2: a8           STATUS6550      tay                       ;Read or write status
0ad3: bd 8e c0                     lda     STATUS6510,x      ;Get status reg
0ad6: 4a                           lsr     A                 ;Shift into carry
0ad7: 88                           dey                       ;Read data?
0ad8: f0 01                        beq     ST6550FLAG        ;Yep, use bit 0
0ada: 4a                           lsr     A                 ;Check bit 1 for write
0adb: 90 c5        ST6550FLAG      bcc     CHAR_RET_0        ;Set flag depending on carry
0add: b0 af                        bcs     CARDRETFF

0adf: a9 03        INIT6550        lda     #$03              ;ACIA master reset
0ae1: 9d 8e c0                     sta     STATUS6510,x
0ae4: a9 15                        lda     #$15              ;8 bit data, no parity, 1 stop, clock is 16x
0ae6: 9d 8e c0                     sta     STATUS6510,x
0ae9: d0 a3                        bne     CARDRETFF

0aeb: 20 06 0b     JSRSSCREAD      jsr     PAGEINROM         ;Bring in the SSC ROM
0aee: 20 4d c8                     jsr     SSC_READ          ;Read a character
0af1: bd b8 05                     lda     STSBYTE,x         ;Get the character
0af4: 60                           rts

0af5: 48           JSRSCCWRITE     pha
0af6: 20 06 0b                     jsr     PAGEINROM         ;Bring in the SSC ROM
0af9: 68                           pla
0afa: 9d b8 05                     sta     STSBYTE,x         ;Save character to write
0afd: 4c aa c9                     jmp     SSC_WRITE         ;Call write routine

0b00: 20 06 0b     JSRSCCINIT      jsr     PAGEINROM         ;Bring in the SSC ROM
0b03: 4c 00 c8                     jmp     SCC_INIT          ;Call the init routine

0b06: 8e f8 06     PAGEINROM       stx     RECALCNT          ;Mark us as using rom space
0b09: 8a                           txa
0b0a: a8                           tay
0b0b: a9 00        PAGEINROM2      lda     #$00              ;Value over written by other code
0b0d: 09 c0                        ora     #$c0              ;Put into correct IO space
0b0f: aa                           tax
0b10: 8e 18 0b                     stx     READROMSLOT+2     ;Set up for a read from the ROM
0b13: 2c ff cf                     bit     CLRROM            ;Clear any other ROMS in $C800
0b16: ad 00 c1     READROMSLOT     lda     $c100             ;Read from our rom to bring in $C800
0b19: 60                           rts

0b1a: 1a 1a 1a 1a+                 .fill   230,$1a
                                   .adrend ↑ ~$0a00
                                   .adrend ↑ $d000
