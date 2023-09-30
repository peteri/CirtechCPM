                   ; 6502bench SourceGen v1.8.5
                   SCRLINEL        .eq     $20               ;Address of current line in $400
                   SCRLINEH        .eq     $21               ;Screen address high
                   ESCAPE_STATE    .eq     $22               ;State for ESCAPE leadin
                   CURSOR_STATE    .eq     $23               ;Bit 7 high if cursor on screen
                   CURSORX         .eq     $25               ;Cursor X (80 col)
                   ZP_TEMP1        .eq     $26               ;Zero page temporary
                   MON_GBASH       .eq     $27               ;base address for lo-res drawing (hi)
                   CURSORY         .eq     $29               ;Cursor Y (80 col)
                   MON_H2          .eq     $2c               ;right end of horizontal line drawn by HLINE
                   MON_V2          .eq     $2d               ;bottom of vertical line drawn by VLINE
                   MON_INVFLAG     .eq     $32               ;text mask (255=normal, 127=flash, 63=inv)
                   MON_A1H         .eq     $3d               ;general purpose
                   MON_A2L         .eq     $3e               ;general purpose
                   MON_A2H         .eq     $3f               ;general purpose
                   MON_A3H         .eq     $41               ;general purpose
                   PRODOS_CMD      .eq     $42
                   PRODOS_UNITNUM  .eq     $43
                   PRDOOS_BUFPTRL  .eq     $44
                   PRODOS_BUFPTRH  .eq     $45               ;Prodos buffer pointer high
                   PRODOS_BLKNUM   .eq     $46
                   DISK_TRKL       .eq     $0380             ;Disk track low (From Z80)
                   DISK_SECT       .eq     $0381             ;Disk sector (from Z80)
                   DISK_DRV        .eq     $0384             ;Drive to use from CPM (Slot)
                   DISK_ACTD       .eq     $0385             ;Current active disk ][ drive
                   DISK_TRKH       .eq     $0386             ;Disk track high (from Z80)
                   DISK_OP         .eq     $0388             ;Disk operation
                   DISK_ERR        .eq     $0389             ;Disk Error back
                   SLOT_INFO       .eq     $03b8
                   SCRNHOLE0       .eq     $0478  {addr/8}   ;text page 1 screen holes
                   SCRNHOLE1       .eq     $04f8  {addr/8}   ;text page 1 screen holes
                   SCRNHOLE2       .eq     $0578  {addr/8}   ;text page 1 screen holes
                   DISKSLOTCX      .eq     $05f8             ;Disk slot $60
                   SCRNHOLE4       .eq     $0678  {addr/8}   ;text page 1 screen holes
                   SCRNHOLE5       .eq     $06f8  {addr/8}   ;text page 1 screen holes
                   SET80COL        .eq     $c001             ;W use PAGE2 for aux mem (80STOREON)
                   SET80VID        .eq     $c00d             ;W enable 80-column display mode
                   SETALTCHAR      .eq     $c00f             ;W use alternate char set
                   SPKR            .eq     $c030             ;RW toggle speaker
                   TXTPAGE1        .eq     $c054             ;RW display page 1
                   TXTPAGE2        .eq     $c055             ;RW display page 2 (or read/write aux mem)
                   IWM_PH0_OFF     .eq     $c080             ;IWM phase 0 off
                   IWM_MOTOR_OFF   .eq     $c088             ;IWM motor off
                   IWM_MOTOR_ON    .eq     $c089             ;IWM motor on
                   IWM_DRIVE_1     .eq     $c08a             ;IWM select drive 1
                   IWM_DRIVE_2     .eq     $c08b             ;IWM select drive 2
                   LCBANK1         .eq     $c08b             ;RWx2 read/write RAM bank 1
                   IWM_Q6_OFF      .eq     $c08c             ;IWM read
                   IWM_Q6_ON       .eq     $c08d             ;IWM WP-sense
                   IWM_Q7_OFF      .eq     $c08e             ;IWM WP-sense/read
                   IWM_Q7_ON       .eq     $c08f             ;IWM write
                   CLRROM          .eq     $cfff             ;disable slot C8 ROM

                   ********************************************************************************
                   *                                                                              *
                   * Routines to handle the 80 Column card                                        *
                   *                                                                              *
                   ********************************************************************************
                                   .addrs  $d000
d000: 4c 1a d1     LD000           jmp     POP_TOGGLE_CURSOR

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
d1a9: 85 26                        sta     ZP_TEMP1          ;Save our blank character
d1ab: b0 02                        bcs     SKIP_ODD_CLR      ;Do we need skip the first one?
d1ad: 91 20        CLR_PAGE2_LINE  sta     (SCRLINEL),y      ;Clear the character
d1af: c8           SKIP_ODD_CLR    iny                       ;Next one
d1b0: c0 28                        cpy     #40               ;All Done?
d1b2: d0 f9                        bne     CLR_PAGE2_LINE    ;Nah loop
d1b4: 68                           pla                       ;Restore cursor/2 for page 1 clear
d1b5: a8                           tay
d1b6: a5 26                        lda     ZP_TEMP1          ;Get the character to clear with
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
                   ; Used to convert some televideo 920 escape codes to Ctrl codes
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
d414: c9 07                        cmp     #$07
d416: 90 03                        bcc     BAD_SLOT_ERR
d418: 4c a3 da                     jmp     IDC_CHECK

d41b: a9 01        BAD_SLOT_ERR    lda     #$01
d41d: 8d 89 03                     sta     DISK_ERR
d420: 60                           rts

d421: a0 02        DISKII          ldy     #$02
d423: 8c f8 06                     sty     SCRNHOLE5
d426: a0 04                        ldy     #$04
d428: 8c f8 04                     sty     SCRNHOLE1
d42b: ae f8 05                     ldx     DISKSLOTCX
d42e: bd 8e c0                     lda     IWM_Q7_OFF,x
d431: bd 8c c0                     lda     IWM_Q6_OFF,x
d434: a0 08                        ldy     #$08
d436: bd 8c c0     LD436           lda     IWM_Q6_OFF,x
d439: 48                           pha
d43a: 68                           pla
d43b: 48                           pha
d43c: 68                           pla
d43d: dd 8c c0                     cmp     IWM_Q6_OFF,x
d440: d0 03                        bne     LD445
d442: 88                           dey
d443: d0 f1                        bne     LD436
d445: 08           LD445           php
d446: bd 89 c0                     lda     IWM_MOTOR_ON,x
d449: a9 ef                        lda     #$ef
d44b: 85 46                        sta     PRODOS_BLKNUM
d44d: a9 d8                        lda     #$d8
d44f: 85 47                        sta     $47
d451: ad 84 03                     lda     DISK_DRV
d454: cd 85 03                     cmp     DISK_ACTD
d457: f0 07                        beq     LD460
d459: 8d 85 03                     sta     DISK_ACTD
d45c: 28                           plp
d45d: a0 00                        ldy     #$00
d45f: 08                           php
d460: 2a           LD460           rol     A
d461: b0 05                        bcs     LD468
d463: bd 8a c0                     lda     IWM_DRIVE_1,x
d466: 90 03                        bcc     LD46B

d468: bd 8b c0     LD468           lda     IWM_DRIVE_2,x
d46b: 66 35        LD46B           ror     $35
d46d: 28                           plp
d46e: 08                           php
d46f: d0 0b                        bne     LD47C
d471: a0 07                        ldy     #$07
d473: 20 d9 d6     LD473           jsr     LD6D9
d476: 88                           dey
d477: d0 fa                        bne     LD473
d479: ae f8 05                     ldx     DISKSLOTCX
d47c: ad 88 03     LD47C           lda     DISK_OP
d47f: c9 03                        cmp     #$03
d481: d0 04                        bne     LD487
d483: 28                           plp
d484: 4c b3 d9                     jmp     LD9B3

d487: ad 80 03     LD487           lda     DISK_TRKL
d48a: 20 cb d7                     jsr     LD7CB
d48d: ad 88 03                     lda     DISK_OP
d490: 28                           plp
d491: d0 07                        bne     LD49A
d493: c9 01                        cmp     #$01
d495: f0 03                        beq     LD49A
d497: 20 c4 d8                     jsr     LD8C4
d49a: c9 04        LD49A           cmp     #$04
d49c: d0 03                        bne     LD4A1
d49e: 4c 1a da                     jmp     LDA1A

d4a1: c9 05        LD4A1           cmp     #$05
d4a3: d0 03                        bne     LD4A8
d4a5: 4c 1a da                     jmp     LDA1A

d4a8: 6a           LD4A8           ror     A
d4a9: 08                           php
d4aa: b0 03                        bcs     LD4AF
d4ac: 20 8e d6                     jsr     LD68E
d4af: a0 30        LD4AF           ldy     #$30
d4b1: 8c 78 05                     sty     SCRNHOLE2
d4b4: ae f8 05     LD4B4           ldx     DISKSLOTCX
d4b7: 20 6f d7                     jsr     LD76F
d4ba: 90 22                        bcc     LD4DE
d4bc: ce 78 05     LD4BC           dec     SCRNHOLE2
d4bf: 10 f3                        bpl     LD4B4
d4c1: a9 2a        LD4C1           lda     #$2a
d4c3: 20 ee d6                     jsr     LD6EE
d4c6: ce f8 06                     dec     SCRNHOLE5
d4c9: f0 31                        beq     LD4FC
d4cb: a9 04                        lda     #$04
d4cd: 8d f8 04                     sta     SCRNHOLE1
d4d0: a9 00                        lda     #$00
d4d2: 20 cb d7                     jsr     LD7CB
d4d5: ad 80 03                     lda     DISK_TRKL
d4d8: 20 cb d7     LD4D8           jsr     LD7CB
d4db: 4c af d4                     jmp     LD4AF

d4de: a5 2f        LD4DE           lda     $2f
d4e0: 8d 87 03                     sta     DISK_OP-1
d4e3: 48                           pha
d4e4: 68                           pla
d4e5: a4 2e                        ldy     $2e
d4e7: cc 80 03                     cpy     DISK_TRKL
d4ea: f0 16                        beq     LD502
d4ec: ad 78 04                     lda     SCRNHOLE0
d4ef: 48                           pha
d4f0: 98                           tya
d4f1: 20 ee d6                     jsr     LD6EE
d4f4: 68                           pla
d4f5: ce f8 04                     dec     SCRNHOLE1
d4f8: d0 de                        bne     LD4D8
d4fa: f0 c5                        beq     LD4C1

d4fc: a9 01        LD4FC           lda     #$01
d4fe: 28                           plp
d4ff: 38                           sec
d500: b0 22        LD500           bcs     LD524

d502: ad 81 03     LD502           lda     DISK_SECT
d505: a8                           tay
d506: b9 35 d5     LD506           lda     LD535,y
d509: c5 2d                        cmp     MON_V2
d50b: d0 af                        bne     LD4BC
d50d: 28                           plp
d50e: 90 1b                        bcc     LD52B
d510: 20 07 d7                     jsr     LD707
d513: 08                           php
d514: b0 a6                        bcs     LD4BC
d516: 28                           plp
d517: a2 00                        ldx     #$00
d519: 86 26                        stx     ZP_TEMP1
d51b: 20 be d6                     jsr     LD6BE
d51e: ae f8 05                     ldx     DISKSLOTCX
d521: a9 00        LD521           lda     #$00
d523: 18                           clc
d524: 8d 89 03     LD524           sta     DISK_ERR
d527: bd 88 c0                     lda     IWM_MOTOR_OFF,x
d52a: 60                           rts

d52b: 20 00 d6     LD52B           jsr     LD600
d52e: 90 f1                        bcc     LD521
d530: a9 10                        lda     #$10
d532: 38                           sec
d533: b0 ef                        bcs     LD524

d535: 00           LD535           .dd1    $00
d536: 03                           .dd1    $03
d537: 06                           .dd1    $06
d538: 09                           .dd1    $09
d539: 0c                           .dd1    $0c
d53a: 0f                           .dd1    $0f
d53b: 02                           .dd1    $02
d53c: 05                           .dd1    $05
d53d: 08                           .dd1    $08
d53e: 0b                           .dd1    $0b
d53f: 0e                           .dd1    $0e
d540: 01                           .dd1    $01
d541: 04                           .dd1    $04
d542: 07                           .dd1    $07
d543: 0a                           .dd1    $0a
d544: 0d                           .dd1    $0d
d545: 70           LD545           .dd1    $70
d546: 2c                           .dd1    $2c
d547: 26                           .dd1    $26
d548: 22                           .dd1    $22
d549: 1f                           .dd1    $1f
d54a: 1e                           .dd1    $1e
d54b: 1d                           .dd1    $1d
d54c: 1c 1c 1c 1c+                 .fill   6,$1c
d552: 96           LD552           .dd1    $96
d553: 97                           .dd1    $97
d554: 9a                           .dd1    $9a
d555: 9b                           .dd1    $9b
d556: 9d                           .dd1    $9d
d557: 9e                           .dd1    $9e
d558: 9f                           .dd1    $9f
d559: a6                           .dd1    $a6
d55a: a7                           .dd1    $a7
d55b: ab                           .dd1    $ab
d55c: ac                           .dd1    $ac
d55d: ad                           .dd1    $ad
d55e: ae                           .dd1    $ae
d55f: af                           .dd1    $af
d560: b2                           .dd1    $b2
d561: b3                           .dd1    $b3
d562: b4                           .dd1    $b4
d563: b5                           .dd1    $b5
d564: b6                           .dd1    $b6
d565: b7                           .dd1    $b7
d566: b9                           .dd1    $b9
d567: ba                           .dd1    $ba
d568: bb                           .dd1    $bb
d569: bc                           .dd1    $bc
d56a: bd                           .dd1    $bd
d56b: be                           .dd1    $be
d56c: bf                           .dd1    $bf
d56d: cb                           .dd1    $cb
d56e: cd                           .dd1    $cd
d56f: ce                           .dd1    $ce
d570: cf                           .dd1    $cf
d571: d3                           .dd1    $d3
d572: d6                           .dd1    $d6
d573: d7                           .dd1    $d7
d574: d9                           .dd1    $d9
d575: da                           .dd1    $da
d576: db                           .dd1    $db
d577: dc                           .dd1    $dc
d578: dd                           .dd1    $dd
d579: de                           .dd1    $de
d57a: df                           .dd1    $df
d57b: e5                           .dd1    $e5
d57c: e6                           .dd1    $e6
d57d: e7                           .dd1    $e7
d57e: e9                           .dd1    $e9
d57f: ea                           .dd1    $ea
d580: eb                           .dd1    $eb
d581: ec                           .dd1    $ec
d582: ed                           .dd1    $ed
d583: ee                           .dd1    $ee
d584: ef                           .dd1    $ef
d585: f2                           .dd1    $f2
d586: f3                           .dd1    $f3
d587: f4                           .dd1    $f4
d588: f5                           .dd1    $f5
d589: f6                           .dd1    $f6
d58a: f7                           .dd1    $f7
d58b: f9                           .dd1    $f9
d58c: fa                           .dd1    $fa
d58d: fb                           .dd1    $fb
d58e: fc                           .dd1    $fc
d58f: fd                           .dd1    $fd
d590: fe                           .dd1    $fe
d591: ff                           .dd1    $ff
d592: 00 00 00 00+                 .fill   5,$00
d597: 01                           .dd1    $01
d598: 98                           .dd1    $98
d599: 99                           .dd1    $99
d59a: 02                           .dd1    $02
d59b: 03                           .dd1    $03
d59c: 9c                           .dd1    $9c
d59d: 04                           .dd1    $04
d59e: 05                           .dd1    $05
d59f: 06                           .dd1    $06
d5a0: a0                           .dd1    $a0
d5a1: a1                           .dd1    $a1
d5a2: a2                           .dd1    $a2
d5a3: a3                           .dd1    $a3
d5a4: a4                           .dd1    $a4
d5a5: a5                           .dd1    $a5
d5a6: 07                           .dd1    $07
d5a7: 08                           .dd1    $08
d5a8: a8                           .dd1    $a8
d5a9: a9                           .dd1    $a9
d5aa: aa                           .dd1    $aa
d5ab: 09                           .dd1    $09
d5ac: 0a                           .dd1    $0a
d5ad: 0b                           .dd1    $0b
d5ae: 0c                           .dd1    $0c
d5af: 0d                           .dd1    $0d
d5b0: b0                           .dd1    $b0
d5b1: b1                           .dd1    $b1
d5b2: 0e                           .dd1    $0e
d5b3: 0f                           .dd1    $0f
d5b4: 10                           .dd1    $10
d5b5: 11                           .dd1    $11
d5b6: 12                           .dd1    $12
d5b7: 13                           .dd1    $13
d5b8: b8                           .dd1    $b8
d5b9: 14                           .dd1    $14
d5ba: 15                           .dd1    $15
d5bb: 16                           .dd1    $16
d5bc: 17                           .dd1    $17
d5bd: 18                           .dd1    $18
d5be: 19                           .dd1    $19
d5bf: 1a                           .dd1    $1a
d5c0: c0                           .dd1    $c0
d5c1: c1                           .dd1    $c1
d5c2: c2                           .dd1    $c2
d5c3: c3                           .dd1    $c3
d5c4: c4                           .dd1    $c4
d5c5: c5                           .dd1    $c5
d5c6: c6                           .dd1    $c6
d5c7: c7                           .dd1    $c7
d5c8: c8                           .dd1    $c8
d5c9: c9                           .dd1    $c9
d5ca: ca                           .dd1    $ca
d5cb: 1b                           .dd1    $1b
d5cc: cc                           .dd1    $cc
d5cd: 1c                           .dd1    $1c
d5ce: 1d                           .dd1    $1d
d5cf: 1e                           .dd1    $1e
d5d0: d0                           .dd1    $d0
d5d1: d1                           .dd1    $d1
d5d2: d2                           .dd1    $d2
d5d3: 1f                           .dd1    $1f
d5d4: d4                           .dd1    $d4
d5d5: d5                           .dd1    $d5
d5d6: 20                           .dd1    $20
d5d7: 21                           .dd1    $21
d5d8: d8                           .dd1    $d8
d5d9: 22                           .dd1    $22
d5da: 23                           .dd1    $23
d5db: 24                           .dd1    $24
d5dc: 25                           .dd1    $25
d5dd: 26                           .dd1    $26
d5de: 27                           .dd1    $27
d5df: 28                           .dd1    $28
d5e0: e0                           .dd1    $e0
d5e1: e1                           .dd1    $e1
d5e2: e2                           .dd1    $e2
d5e3: e3                           .dd1    $e3
d5e4: e4                           .dd1    $e4
d5e5: 29                           .dd1    $29
d5e6: 2a                           .dd1    $2a
d5e7: 2b                           .dd1    $2b
d5e8: e8                           .dd1    $e8
d5e9: 2c                           .dd1    $2c
d5ea: 2d                           .dd1    $2d
d5eb: 2e                           .dd1    $2e
d5ec: 2f                           .dd1    $2f
d5ed: 30                           .dd1    $30
d5ee: 31                           .dd1    $31
d5ef: 32                           .dd1    $32
d5f0: f0                           .dd1    $f0
d5f1: f1                           .dd1    $f1
d5f2: 33                           .dd1    $33
d5f3: 34                           .dd1    $34
d5f4: 35                           .dd1    $35
d5f5: 36                           .dd1    $36
d5f6: 37                           .dd1    $37
d5f7: 38                           .dd1    $38
d5f8: f8                           .dd1    $f8
d5f9: 39                           .dd1    $39
d5fa: 3a                           .dd1    $3a
d5fb: 3b                           .dd1    $3b
d5fc: 3c                           .dd1    $3c
d5fd: 3d                           .dd1    $3d
d5fe: 3e                           .dd1    $3e
d5ff: 3f                           .dd1    $3f
d600: 38           LD600           sec
d601: 86 27                        stx     MON_GBASH
d603: 8e 78 06                     stx     SCRNHOLE4
d606: bd 8d c0                     lda     IWM_Q6_ON,x
d609: bd 8e c0                     lda     IWM_Q7_OFF,x
d60c: 30 7c                        bmi     LD68A
d60e: ad 00 df                     lda     $df00
d611: 85 26                        sta     ZP_TEMP1
d613: a9 ff                        lda     #$ff
d615: 9d 8f c0                     sta     IWM_Q7_ON,x
d618: 1d 8c c0                     ora     IWM_Q6_OFF,x
d61b: 48                           pha
d61c: 68                           pla
d61d: ea                           nop
d61e: a0 04                        ldy     #$04
d620: 48           LD620           pha
d621: 68                           pla
d622: 20 b5 d6                     jsr     LD6B5
d625: 88                           dey
d626: d0 f8                        bne     LD620
d628: a9 d5                        lda     #$d5
d62a: 20 b4 d6                     jsr     LD6B4
d62d: a9 aa                        lda     #$aa
d62f: 20 b4 d6                     jsr     LD6B4
d632: a9 ad                        lda     #$ad
d634: 20 b4 d6                     jsr     LD6B4
d637: 98                           tya
d638: a0 56                        ldy     #$56
d63a: d0 03                        bne     LD63F

d63c: b9 00 df     LD63C           lda     $df00,y
d63f: 59 ff de     LD63F           eor     $deff,y
d642: aa                           tax
d643: bd 52 d5                     lda     LD552,x
d646: a6 27                        ldx     MON_GBASH
d648: 9d 8d c0                     sta     IWM_Q6_ON,x
d64b: bd 8c c0                     lda     IWM_Q6_OFF,x
d64e: 88                           dey
d64f: d0 eb                        bne     LD63C
d651: a5 26                        lda     ZP_TEMP1
d653: ea                           nop
d654: 59 00 de     LD654           eor     $de00,y
d657: aa                           tax
d658: bd 52 d5                     lda     LD552,x
d65b: ae 78 06                     ldx     SCRNHOLE4
d65e: 9d 8d c0                     sta     IWM_Q6_ON,x
d661: bd 8c c0                     lda     IWM_Q6_OFF,x
d664: b9 00 de                     lda     $de00,y
d667: c8                           iny
d668: d0 ea                        bne     LD654
d66a: aa                           tax
d66b: bd 52 d5                     lda     LD552,x
d66e: a6 27                        ldx     MON_GBASH
d670: 20 b7 d6                     jsr     LD6B7
d673: a9 de                        lda     #$de
d675: 20 b4 d6                     jsr     LD6B4
d678: a9 aa                        lda     #$aa
d67a: 20 b4 d6                     jsr     LD6B4
d67d: a9 eb                        lda     #$eb
d67f: 20 b4 d6                     jsr     LD6B4
d682: a9 ff                        lda     #$ff
d684: 20 b4 d6                     jsr     LD6B4
d687: bd 8e c0                     lda     IWM_Q7_OFF,x
d68a: bd 8c c0     LD68A           lda     IWM_Q6_OFF,x
d68d: 60                           rts

d68e: a2 55        LD68E           ldx     #$55
d690: a9 00                        lda     #$00
d692: 9d 00 df     LD692           sta     $df00,x
d695: ca                           dex
d696: 10 fa                        bpl     LD692
d698: a8                           tay
d699: a2 ac                        ldx     #$ac
d69b: 2c                           bit ▼   $aaa2
d69c: a2 aa        LD69C           ldx     #$aa
d69e: 88           LD69E           dey
d69f: b9 00 08     LD69F           lda     $0800,y
d6a2: 4a                           lsr     A
d6a3: 3e 56 de                     rol     $de56,x
d6a6: 4a                           lsr     A
d6a7: 3e 56 de                     rol     $de56,x
d6aa: 99 00 de                     sta     $de00,y
d6ad: e8                           inx
d6ae: d0 ee                        bne     LD69E
d6b0: 98                           tya
d6b1: d0 e9                        bne     LD69C
d6b3: 60                           rts

d6b4: 18           LD6B4           clc
d6b5: 48           LD6B5           pha
d6b6: 68                           pla
d6b7: 9d 8d c0     LD6B7           sta     IWM_Q6_ON,x
d6ba: 1d 8c c0                     ora     IWM_Q6_OFF,x
d6bd: 60                           rts

d6be: a0 00        LD6BE           ldy     #$00
d6c0: a2 56        LD6C0           ldx     #$56
d6c2: ca           LD6C2           dex
d6c3: 30 fb                        bmi     LD6C0
d6c5: b9 00 de                     lda     $de00,y
d6c8: 5e 00 df                     lsr     $df00,x
d6cb: 2a                           rol     A
d6cc: 5e 00 df                     lsr     $df00,x
d6cf: 2a                           rol     A
d6d0: 99 00 08     LD6D0           sta     $0800,y
d6d3: c8                           iny
d6d4: c4 26                        cpy     ZP_TEMP1
d6d6: d0 ea                        bne     LD6C2
d6d8: 60                           rts

d6d9: a2 11        LD6D9           ldx     #$11
d6db: ca           LD6DB           dex
d6dc: d0 fd                        bne     LD6DB
d6de: e6 46                        inc     PRODOS_BLKNUM
d6e0: d0 06                        bne     LD6E8
d6e2: e6 47                        inc     $47
d6e4: d0 02                        bne     LD6E8
d6e6: c6 47                        dec     $47
d6e8: 38           LD6E8           sec
d6e9: e9 01                        sbc     #$01
d6eb: d0 ec                        bne     LD6D9
d6ed: 60                           rts

d6ee: 48           LD6EE           pha
d6ef: ad 84 03                     lda     DISK_DRV
d6f2: 2a                           rol     A
d6f3: 66 35                        ror     $35
d6f5: 20 9a da                     jsr     LDA9A
d6f8: 68                           pla
d6f9: 0a                           asl     A
d6fa: 24 35                        bit     $35
d6fc: 30 05                        bmi     LD703
d6fe: 99 f8 04                     sta     SCRNHOLE1,y
d701: 10 03                        bpl     LD706

d703: 99 78 04     LD703           sta     SCRNHOLE0,y
d706: 60           LD706           rts

d707: a0 20        LD707           ldy     #$20
d709: 88           LD709           dey
d70a: f0 61                        beq     LD76D
d70c: bd 8c c0     LD70C           lda     IWM_Q6_OFF,x
d70f: 10 fb                        bpl     LD70C
d711: 49 d5        LD711           eor     #$d5
d713: d0 f4                        bne     LD709
d715: ea                           nop
d716: bd 8c c0     LD716           lda     IWM_Q6_OFF,x
d719: 10 fb                        bpl     LD716
d71b: c9 aa                        cmp     #$aa
d71d: d0 f2                        bne     LD711
d71f: a0 56                        ldy     #$56
d721: bd 8c c0     LD721           lda     IWM_Q6_OFF,x
d724: 10 fb                        bpl     LD721
d726: c9 ad                        cmp     #$ad
d728: d0 e7                        bne     LD711
d72a: a9 00                        lda     #$00
d72c: 88           LD72C           dey
d72d: 84 26                        sty     ZP_TEMP1
d72f: bc 8c c0     LD72F           ldy     IWM_Q6_OFF,x
d732: 10 fb                        bpl     LD72F
d734: 59 00 d5                     eor     LD500,y
d737: a4 26                        ldy     ZP_TEMP1
d739: 99 00 df                     sta     $df00,y
d73c: d0 ee                        bne     LD72C
d73e: 84 26        LD73E           sty     ZP_TEMP1
d740: bc 8c c0     LD740           ldy     IWM_Q6_OFF,x
d743: 10 fb                        bpl     LD740
d745: 59 00 d5                     eor     LD500,y
d748: a4 26                        ldy     ZP_TEMP1
d74a: 99 00 de                     sta     $de00,y
d74d: c8                           iny
d74e: d0 ee                        bne     LD73E
d750: bc 8c c0     LD750           ldy     IWM_Q6_OFF,x
d753: 10 fb                        bpl     LD750
d755: d9 00 d5                     cmp     LD500,y
d758: d0 13                        bne     LD76D
d75a: bd 8c c0     LD75A           lda     IWM_Q6_OFF,x
d75d: 10 fb                        bpl     LD75A
d75f: c9 de                        cmp     #$de
d761: d0 0a                        bne     LD76D
d763: ea                           nop
d764: bd 8c c0     LD764           lda     IWM_Q6_OFF,x
d767: 10 fb                        bpl     LD764
d769: c9 aa                        cmp     #$aa
d76b: f0 5c                        beq     LD7C9
d76d: 38           LD76D           sec
d76e: 60                           rts

d76f: a0 fc        LD76F           ldy     #$fc
d771: 84 26                        sty     ZP_TEMP1
d773: c8           LD773           iny
d774: d0 04                        bne     LD77A
d776: e6 26                        inc     ZP_TEMP1
d778: f0 f3                        beq     LD76D
d77a: bd 8c c0     LD77A           lda     IWM_Q6_OFF,x
d77d: 10 fb                        bpl     LD77A
d77f: c9 d5        LD77F           cmp     #$d5
d781: d0 f0                        bne     LD773
d783: ea                           nop
d784: bd 8c c0     LD784           lda     IWM_Q6_OFF,x
d787: 10 fb                        bpl     LD784
d789: c9 aa                        cmp     #$aa
d78b: d0 f2                        bne     LD77F
d78d: a0 03                        ldy     #$03
d78f: bd 8c c0     LD78F           lda     IWM_Q6_OFF,x
d792: 10 fb                        bpl     LD78F
d794: c9 96                        cmp     #$96
d796: d0 e7                        bne     LD77F
d798: a9 00                        lda     #$00
d79a: 85 27        LD79A           sta     MON_GBASH
d79c: bd 8c c0     LD79C           lda     IWM_Q6_OFF,x
d79f: 10 fb                        bpl     LD79C
d7a1: 2a                           rol     A
d7a2: 85 26                        sta     ZP_TEMP1
d7a4: bd 8c c0     LD7A4           lda     IWM_Q6_OFF,x
d7a7: 10 fb                        bpl     LD7A4
d7a9: 25 26                        and     ZP_TEMP1
d7ab: 99 2c 00                     sta     MON_H2,y
d7ae: 45 27                        eor     MON_GBASH
d7b0: 88                           dey
d7b1: 10 e7                        bpl     LD79A
d7b3: a8                           tay
d7b4: d0 b7                        bne     LD76D
d7b6: bd 8c c0     LD7B6           lda     IWM_Q6_OFF,x
d7b9: 10 fb                        bpl     LD7B6
d7bb: c9 de                        cmp     #$de
d7bd: d0 ae                        bne     LD76D
d7bf: ea                           nop
d7c0: bd 8c c0     LD7C0           lda     IWM_Q6_OFF,x
d7c3: 10 fb                        bpl     LD7C0
d7c5: c9 aa                        cmp     #$aa
d7c7: d0 a4                        bne     LD76D
d7c9: 18           LD7C9           clc
d7ca: 60                           rts

d7cb: 0a           LD7CB           asl     A
d7cc: 20 d3 d7                     jsr     LD7D3
d7cf: 4e 78 04                     lsr     SCRNHOLE0
d7d2: 60                           rts

d7d3: 85 2a        LD7D3           sta     $2a
d7d5: 20 9a da                     jsr     LDA9A
d7d8: b9 78 04                     lda     SCRNHOLE0,y
d7db: 24 35                        bit     $35
d7dd: 30 03                        bmi     LD7E2
d7df: b9 f8 04                     lda     SCRNHOLE1,y
d7e2: 8d 78 04     LD7E2           sta     SCRNHOLE0
d7e5: a5 2a                        lda     $2a
d7e7: 24 35                        bit     $35
d7e9: 30 05                        bmi     LD7F0
d7eb: 99 f8 04                     sta     SCRNHOLE1,y
d7ee: 10 03                        bpl     LD7F3

d7f0: 99 78 04     LD7F0           sta     SCRNHOLE0,y
d7f3: 86 2b        LD7F3           stx     $2b
d7f5: 85 2a                        sta     $2a
d7f7: cd 78 04                     cmp     SCRNHOLE0
d7fa: f0 53                        beq     LD84F
d7fc: a9 00                        lda     #$00
d7fe: 85 26                        sta     ZP_TEMP1
d800: ad 78 04     LD800           lda     SCRNHOLE0
d803: 85 27                        sta     MON_GBASH
d805: 38                           sec
d806: e5 2a                        sbc     $2a
d808: f0 33                        beq     LD83D
d80a: b0 07                        bcs     LD813
d80c: 49 ff                        eor     #$ff
d80e: ee 78 04                     inc     SCRNHOLE0
d811: 90 05                        bcc     LD818

d813: 69 fe        LD813           adc     #$fe
d815: ce 78 04                     dec     SCRNHOLE0
d818: c5 26        LD818           cmp     ZP_TEMP1
d81a: 90 02                        bcc     LD81E
d81c: a5 26                        lda     ZP_TEMP1
d81e: c9 0c        LD81E           cmp     #$0c
d820: b0 01                        bcs     LD823
d822: a8                           tay
d823: 38           LD823           sec
d824: 20 41 d8                     jsr     LD841
d827: b9 8e da                     lda     LDA8E,y
d82a: 20 d9 d6                     jsr     LD6D9
d82d: a5 27                        lda     MON_GBASH
d82f: 18                           clc
d830: 20 44 d8                     jsr     LD844
d833: b9 45 d5                     lda     LD545,y
d836: 20 d9 d6                     jsr     LD6D9
d839: e6 26                        inc     ZP_TEMP1
d83b: d0 c3                        bne     LD800
d83d: 20 d9 d6     LD83D           jsr     LD6D9
d840: 18                           clc
d841: ad 78 04     LD841           lda     SCRNHOLE0
d844: 29 03        LD844           and     #$03
d846: 2a                           rol     A
d847: 05 2b                        ora     $2b
d849: aa                           tax
d84a: bd 80 c0                     lda     IWM_PH0_OFF,x
d84d: a6 2b                        ldx     $2b
d84f: 60           LD84F           rts

d850: bd 8c c0     LD850           lda     IWM_Q6_OFF,x
d853: a9 10                        lda     #$10
d855: 38                           sec
d856: 60                           rts

d857: bd 8d c0     LD857           lda     IWM_Q6_ON,x
d85a: bd 8e c0                     lda     IWM_Q7_OFF,x
d85d: 30 f1                        bmi     LD850
d85f: a9 ff                        lda     #$ff
d861: 9d 8f c0                     sta     IWM_Q7_ON,x
d864: dd 8c c0                     cmp     IWM_Q6_OFF,x
d867: 48                           pha
d868: 68                           pla
d869: 20 c3 d8     LD869           jsr     LD8C3
d86c: 20 c3 d8                     jsr     LD8C3
d86f: 9d 8d c0                     sta     IWM_Q6_ON,x
d872: dd 8c c0                     cmp     IWM_Q6_OFF,x
d875: ea                           nop
d876: 88                           dey
d877: d0 f0                        bne     LD869
d879: a9 d5                        lda     #$d5
d87b: 20 e3 d8                     jsr     LD8E3
d87e: a9 aa                        lda     #$aa
d880: 20 e3 d8                     jsr     LD8E3
d883: a9 96                        lda     #$96
d885: 20 e3 d8                     jsr     LD8E3
d888: a5 41                        lda     MON_A3H
d88a: 20 d2 d8                     jsr     LD8D2
d88d: a5 44                        lda     PRDOOS_BUFPTRL
d88f: 20 d2 d8                     jsr     LD8D2
d892: a5 3f                        lda     MON_A2H
d894: 20 d2 d8                     jsr     LD8D2
d897: a5 41                        lda     MON_A3H
d899: 45 44                        eor     PRDOOS_BUFPTRL
d89b: 45 3f                        eor     MON_A2H
d89d: 48                           pha
d89e: 4a                           lsr     A
d89f: 05 3e                        ora     MON_A2L
d8a1: 9d 8d c0                     sta     IWM_Q6_ON,x
d8a4: bd 8c c0                     lda     IWM_Q6_OFF,x
d8a7: 68                           pla
d8a8: 09 aa                        ora     #$aa
d8aa: 20 e2 d8                     jsr     LD8E2
d8ad: a9 de                        lda     #$de
d8af: 20 e3 d8                     jsr     LD8E3
d8b2: a9 aa                        lda     #$aa
d8b4: 20 e3 d8                     jsr     LD8E3
d8b7: a9 eb                        lda     #$eb
d8b9: 20 e3 d8                     jsr     LD8E3
d8bc: 18                           clc
d8bd: bd 8e c0                     lda     IWM_Q7_OFF,x
d8c0: bd 8c c0                     lda     IWM_Q6_OFF,x
d8c3: 60           LD8C3           rts

d8c4: a0 12        LD8C4           ldy     #$12
d8c6: 88           LD8C6           dey
d8c7: d0 fd                        bne     LD8C6
d8c9: e6 46                        inc     PRODOS_BLKNUM
d8cb: d0 f7                        bne     LD8C4
d8cd: e6 47                        inc     $47
d8cf: d0 f3                        bne     LD8C4
d8d1: 60                           rts

d8d2: 48           LD8D2           pha
d8d3: 4a                           lsr     A
d8d4: 05 3e                        ora     MON_A2L
d8d6: 9d 8d c0                     sta     IWM_Q6_ON,x
d8d9: dd 8c c0                     cmp     IWM_Q6_OFF,x
d8dc: 68                           pla
d8dd: ea                           nop
d8de: ea                           nop
d8df: ea                           nop
d8e0: 09 aa                        ora     #$aa
d8e2: ea           LD8E2           nop
d8e3: ea           LD8E3           nop
d8e4: 48                           pha
d8e5: 68                           pla
d8e6: 9d 8d c0                     sta     IWM_Q6_ON,x
d8e9: dd 8c c0                     cmp     IWM_Q6_OFF,x
d8ec: 60           LD8EC           rts

d8ed: a2                           .dd1    $a2
d8ee: 07                           .dd1    $07
d8ef: e0                           .dd1    $e0
d8f0: 06                           .dd1    $06
d8f1: f0                           .dd1    $f0
d8f2: 05                           .dd1    $05
d8f3: dd                           .dd1    $dd
d8f4: b8                           .dd1    $b8
d8f5: 03                           .dd1    $03
d8f6: f0                           .dd1    $f0
d8f7: 08                           .dd1    $08
d8f8: ca                           .dd1    $ca
d8f9: d0                           .dd1    $d0
d8fa: f4                           .dd1    $f4
d8fb: 68                           .dd1    $68
d8fc: 68                           .dd1    $68
d8fd: 4c                           .dd1    $4c
d8fe: c5                           .dd1    $c5
d8ff: da                           .dd1    $da
d900: 8a                           .dd1    $8a
d901: 0a 0a 0a 0a+                 .str    $0a,$0a,$0a,$0a,“`”
d906: 00                           .dd1    $00
d907: 02                           .dd1    $02
d908: 04                           .dd1    $04
d909: 06                           .dd1    $06
d90a: 08                           .dd1    $08
d90b: 0a                           .dd1    $0a
d90c: 0c                           .dd1    $0c
d90d: 0e                           .dd1    $0e
d90e: 01                           .dd1    $01
d90f: 03                           .dd1    $03
d910: 05                           .dd1    $05
d911: 07                           .dd1    $07
d912: 09                           .dd1    $09
d913: 0b                           .dd1    $0b
d914: 0d                           .dd1    $0d
d915: 0f                           .dd1    $0f

d916: a9 00        LD916           lda     #$00
d918: 85 3f                        sta     MON_A2H
d91a: a0 80                        ldy     #$80
d91c: d0 02                        bne     LD920

d91e: a4 45        LD91E           ldy     PRODOS_BUFPTRH
d920: 20 57 d8     LD920           jsr     LD857
d923: b0 c7                        bcs     LD8EC
d925: 20 00 d6                     jsr     LD600
d928: ea                           nop
d929: ea                           nop
d92a: e6 3f                        inc     MON_A2H
d92c: a5 3f                        lda     MON_A2H
d92e: c9 10                        cmp     #$10
d930: 90 ec                        bcc     LD91E
d932: a0 0f                        ldy     #$0f
d934: 84 3f                        sty     MON_A2H
d936: a9 30                        lda     #$30
d938: 8d 78 05                     sta     SCRNHOLE2
d93b: 99 57 df     LD93B           sta     $df57,y
d93e: 88                           dey
d93f: 10 fa                        bpl     LD93B
d941: a4 45                        ldy     PRODOS_BUFPTRH
d943: 20 91 d9     LD943           jsr     LD991
d946: 20 91 d9                     jsr     LD991
d949: 20 91 d9                     jsr     LD991
d94c: 48                           pha
d94d: 68                           pla
d94e: ea                           nop
d94f: 88                           dey
d950: d0 f1                        bne     LD943
d952: 20 6f d7                     jsr     LD76F
d955: b0 23                        bcs     LD97A
d957: a5 2d                        lda     MON_V2
d959: f0 15                        beq     LD970
d95b: a9 10                        lda     #$10
d95d: c5 45                        cmp     PRODOS_BUFPTRH
d95f: a5 45                        lda     PRODOS_BUFPTRH
d961: e9 01                        sbc     #$01
d963: 85 45                        sta     PRODOS_BUFPTRH
d965: c9 05                        cmp     #$05
d967: b0 11                        bcs     LD97A
d969: 90 24                        bcc     LD98F

d96b: 20 6f d7     LD96B           jsr     LD76F
d96e: b0 05                        bcs     LD975
d970: 20 07 d7     LD970           jsr     LD707
d973: 90 1e                        bcc     LD993
d975: ce 78 05     LD975           dec     SCRNHOLE2
d978: d0 f1                        bne     LD96B
d97a: 20 6f d7     LD97A           jsr     LD76F
d97d: b0 0b                        bcs     LD98A
d97f: a5 2d                        lda     MON_V2
d981: c9 0f                        cmp     #$0f
d983: d0 05                        bne     LD98A
d985: 20 07 d7                     jsr     LD707
d988: 90 8c                        bcc     LD916
d98a: ce 78 05     LD98A           dec     SCRNHOLE2
d98d: d0 eb                        bne     LD97A
d98f: a9 01        LD98F           lda     #$01
d991: 38           LD991           sec
d992: 60           LD992           rts

d993: a4 2d        LD993           ldy     MON_V2
d995: b9 57 df                     lda     $df57,y
d998: 30 db                        bmi     LD975
d99a: a9 ff                        lda     #$ff
d99c: 99 57 df                     sta     $df57,y
d99f: c6 3f                        dec     MON_A2H
d9a1: 10 c8                        bpl     LD96B
d9a3: a5 44                        lda     PRDOOS_BUFPTRL
d9a5: d0 0a                        bne     LD9B1
d9a7: a5 45                        lda     PRODOS_BUFPTRH
d9a9: c9 10                        cmp     #$10
d9ab: 90 e5                        bcc     LD992
d9ad: c6 45                        dec     PRODOS_BUFPTRH
d9af: c6 45                        dec     PRODOS_BUFPTRH
d9b1: 18           LD9B1           clc
d9b2: 60                           rts

d9b3: 20 c4 d8     LD9B3           jsr     LD8C4
d9b6: ad 87 03                     lda     DISK_OP-1
d9b9: 85 41                        sta     MON_A3H
d9bb: a9 aa                        lda     #$aa
d9bd: 85 3e                        sta     MON_A2L
d9bf: a0 56                        ldy     #$56
d9c1: a9 00                        lda     #$00
d9c3: 85 44                        sta     PRDOOS_BUFPTRL
d9c5: a9 2a                        lda     #$2a
d9c7: 99 ff de     LD9C7           sta     $deff,y
d9ca: 88                           dey
d9cb: d0 fa                        bne     LD9C7
d9cd: a9 39                        lda     #$39
d9cf: 99 00 de     LD9CF           sta     $de00,y
d9d2: 88                           dey
d9d3: d0 fa                        bne     LD9CF
d9d5: a9 23                        lda     #$23
d9d7: 85 3d                        sta     MON_A1H
d9d9: a9 2a                        lda     #$2a
d9db: 20 ee d6                     jsr     LD6EE
d9de: a9 28                        lda     #$28
d9e0: 85 45                        sta     PRODOS_BUFPTRH
d9e2: a5 44        LD9E2           lda     PRDOOS_BUFPTRL
d9e4: 20 cb d7                     jsr     LD7CB
d9e7: 20 16 d9                     jsr     LD916
d9ea: b0 27                        bcs     LDA13
d9ec: a9 30                        lda     #$30
d9ee: 8d 78 05                     sta     SCRNHOLE2
d9f1: 38           LD9F1           sec
d9f2: ce 78 05                     dec     SCRNHOLE2
d9f5: f0 1a                        beq     LDA11
d9f7: 20 6f d7                     jsr     LD76F
d9fa: b0 f5                        bcs     LD9F1
d9fc: a5 2d                        lda     MON_V2
d9fe: d0 f1                        bne     LD9F1
da00: 20 07 d7                     jsr     LD707
da03: b0 ec                        bcs     LD9F1
da05: e6 44                        inc     PRDOOS_BUFPTRL
da07: a5 3d                        lda     MON_A1H
da09: c5 44                        cmp     PRDOOS_BUFPTRL
da0b: d0 d5                        bne     LD9E2
da0d: a9 00                        lda     #$00
da0f: f0 02                        beq     LDA13

da11: a9 01        LDA11           lda     #$01
da13: 8d 89 03     LDA13           sta     DISK_ERR
da16: bd 88 c0                     lda     IWM_MOTOR_OFF,x
da19: 60                           rts

da1a: a9 00        LDA1A           lda     #$00
da1c: 8d 81 03                     sta     DISK_SECT
da1f: ad a1 d6                     lda     LD69F+2
da22: 8d 67 df                     sta     $df67
da25: ad d2 d6                     lda     LD6D0+2
da28: 8d 68 df                     sta     $df68
da2b: ad 07 d5                     lda     LD506+1
da2e: 8d 69 df                     sta     $df69
da31: ad 08 d5                     lda     LD506+2
da34: 8d 6a df                     sta     $df6a
da37: a9 d9                        lda     #$d9
da39: 8d 08 d5                     sta     LD506+2
da3c: a9 06                        lda     #$06
da3e: 8d 07 d5                     sta     LD506+1
da41: ad 82 03                     lda     $0382
da44: 8d a1 d6                     sta     LD69F+2
da47: 8d d2 d6                     sta     LD6D0+2
da4a: a9 02        LDA4A           lda     #$02
da4c: 8d f8 06                     sta     SCRNHOLE5
da4f: a9 04                        lda     #$04
da51: 8d f8 04                     sta     SCRNHOLE1
da54: ad 88 03                     lda     DISK_OP
da57: 20 a8 d4                     jsr     LD4A8
da5a: b0 19                        bcs     LDA75
da5c: bd 89 c0                     lda     IWM_MOTOR_ON,x
da5f: ee a1 d6                     inc     LD69F+2
da62: ee d2 d6                     inc     LD6D0+2
da65: ee 81 03                     inc     DISK_SECT
da68: ee 82 03                     inc     $0382
da6b: a9 10                        lda     #$10
da6d: cd 81 03                     cmp     DISK_SECT
da70: d0 d8                        bne     LDA4A
da72: bd 88 c0                     lda     IWM_MOTOR_OFF,x
da75: ad 67 df     LDA75           lda     $df67
da78: 8d a1 d6                     sta     LD69F+2
da7b: ad 68 df                     lda     $df68
da7e: 8d d2 d6                     sta     LD6D0+2
da81: ad 69 df                     lda     $df69
da84: 8d 07 d5                     sta     LD506+1
da87: ad 6a df                     lda     $df6a
da8a: 8d 08 d5                     sta     LD506+2
da8d: 60                           rts

da8e: 01           LDA8E           .dd1    $01
da8f: 30 28 24 20                  .str    “0($ ”
da93: 1e                           .dd1    $1e
da94: 1d                           .dd1    $1d
da95: 1c 1c 1c 1c+                 .fill   5,$1c

da9a: ad f8 05     LDA9A           lda     DISKSLOTCX
da9d: 4a                           lsr     A
da9e: 4a                           lsr     A
da9f: 4a                           lsr     A
daa0: 4a                           lsr     A
daa1: a8                           tay
daa2: 60                           rts

                   ; What sort of not Disk ][ is it?
daa3: c9 07        IDC_CHECK       cmp     #$07              ;What sort of drive?
daa5: f0 03                        beq     SMARTDRV_FOUND
daa7: 4c fe da                     jmp     PRODOS

                   ********************************************************************************
                   * SmartDrive code                                                              *
                   ********************************************************************************
daaa: 8a           SMARTDRV_FOUND  txa                       ;Convert to CX
daab: 09 c0                        ora     #$c0
daad: 8d eb da                     sta     SMARTDRV_CALL+2   ;Save slot rom into call high
dab0: 8d b5 da                     sta     GET_SMARTDRV_ADDR+2 ;Save slot rom to get entry point
                   GET_SMARTDRV_ADDR
dab3: ad ff c7                     lda     $c7ff             ;Get the entry point
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
dae0: 8d aa db                     sta     SMARTDRV_BLOCKNUM+1
dae3: ad 86 03                     lda     DISK_TRKH
dae6: 8d ab db                     sta     SMARTDRV_BLOCKNUM+2
dae9: 20 00 00     SMARTDRV_CALL   jsr     $0000
daec: 08           SMARTDRV_CMD    .dd1    $08
daed: a3 db                        .dd2    SMARTDRV_PARAM

daef: a2 00        LDAEF           ldx     #$00              ;Everything happy
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
db01: 8d 2c db                     sta     PD_CALL_DRIVER+2
db04: 8d 09 db                     sta     PD_GET_ENTRY+2
db07: ad ff c7     PD_GET_ENTRY    lda     $c7ff
db0a: 8d 2b db                     sta     PD_CALL_DRIVER+1
db0d: ad 84 03                     lda     DISK_DRV
db10: 85 43                        sta     PRODOS_UNITNUM
db12: ad 88 03                     lda     DISK_OP           ;Status commmand? Return eror
db15: f0 ae                        beq     SET_DISK_ERR1
db17: c9 04                        cmp     #$04
db19: b0 3c                        bcs     LDB57
db1b: 48                           pha
db1c: 20 8d db                     jsr     LDB8D
db1f: 68                           pla
db20: 85 42        LDB20           sta     PRODOS_CMD
db22: a9 00                        lda     #$00
db24: 85 44                        sta     PRDOOS_BUFPTRL
db26: a9 08                        lda     #$08
db28: 85 45                        sta     PRDOOS_BUFPTRL+1
db2a: 20 00 00     PD_CALL_DRIVER  jsr     $0000
db2d: 20 ef da                     jsr     LDAEF
db30: b0 06                        bcs     LDB38
db32: a5 42                        lda     PRODOS_CMD
db34: c9 03                        cmp     #$03
db36: f0 01                        beq     LDB39
db38: 60           LDB38           rts

db39: a9 18        LDB39           lda     #$18
db3b: 8d 81 03                     sta     DISK_SECT
db3e: a9 00        LDB3E           lda     #$00
db40: 85 47                        sta     PRODOS_BLKNUM+1
db42: ad 81 03                     lda     DISK_SECT
db45: 85 46                        sta     PRODOS_BLKNUM
db47: a9 02                        lda     #$02
db49: 20 20 db                     jsr     LDB20
db4c: b0 ea                        bcs     LDB38
db4e: ee 81 03                     inc     DISK_SECT
db51: ce 80 03                     dec     DISK_TRKL
db54: d0 e8                        bne     LDB3E
db56: 60                           rts

db57: 38           LDB57           sec
db58: e9 03                        sbc     #$03
db5a: 49 03                        eor     #$03
db5c: 85 42                        sta     PRODOS_CMD
db5e: a9 08                        lda     #$08
db60: 8d ac db                     sta     PRODOS_XXX
db63: ad 82 03                     lda     $0382
db66: 85 45                        sta     PRODOS_BUFPTRH
db68: a9 00                        lda     #$00
db6a: 8d 81 03                     sta     DISK_SECT
db6d: 85 44                        sta     PRDOOS_BUFPTRL
db6f: 20 8d db                     jsr     LDB8D
db72: 20 2a db     LDB72           jsr     PD_CALL_DRIVER
db75: b0 c1                        bcs     LDB38
db77: ee 82 03                     inc     $0382
db7a: ee 82 03                     inc     $0382
db7d: e6 46                        inc     PRODOS_BLKNUM
db7f: d0 02                        bne     LDB83
db81: e6 47                        inc     $47
db83: e6 45        LDB83           inc     PRODOS_BUFPTRH
db85: e6 45                        inc     PRODOS_BUFPTRH
db87: ce ac db                     dec     PRODOS_XXX
db8a: d0 e6                        bne     LDB72
db8c: 60                           rts

db8d: ad 86 03     LDB8D           lda     DISK_TRKH
db90: 85 47                        sta     $47
db92: ad 80 03                     lda     DISK_TRKL
db95: a2 03                        ldx     #$03
db97: 0a           LDB97           asl     A
db98: 26 47                        rol     $47
db9a: ca                           dex
db9b: d0 fa                        bne     LDB97
db9d: 0d 81 03                     ora     DISK_SECT
dba0: 85 46                        sta     PRODOS_BLKNUM
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
dbac: 00           PRODOS_XXX      .dd1    $00
dbad: 00                           .dd1    $00
dbae: 00                           .dd1    $00
dbaf: 00                           .dd1    $00
dbb0: 00                           .dd1    $00
dbb1: 00                           .dd1    $00
dbb2: 00                           .dd1    $00
dbb3: 00                           .dd1    $00
dbb4: 00                           .dd1    $00
dbb5: 00                           .dd1    $00
dbb6: 00                           .dd1    $00
dbb7: 00                           .dd1    $00
dbb8: 00                           .dd1    $00
dbb9: 00                           .dd1    $00
dbba: 00                           .dd1    $00
dbbb: 00                           .dd1    $00
dbbc: 00                           .dd1    $00
dbbd: 00                           .dd1    $00
dbbe: 00                           .dd1    $00
dbbf: 00                           .dd1    $00
dbc0: 00                           .dd1    $00
dbc1: 00                           .dd1    $00
dbc2: 00                           .dd1    $00
dbc3: 00                           .dd1    $00
dbc4: 00                           .dd1    $00
dbc5: 00                           .dd1    $00
dbc6: 00                           .dd1    $00
dbc7: 00                           .dd1    $00
dbc8: 00                           .dd1    $00
dbc9: 00                           .dd1    $00
dbca: 00                           .dd1    $00
dbcb: 00                           .dd1    $00
dbcc: 00                           .dd1    $00
dbcd: 00                           .dd1    $00
dbce: 00                           .dd1    $00
dbcf: 00                           .dd1    $00
dbd0: 00                           .dd1    $00
dbd1: 00                           .dd1    $00
dbd2: 00                           .dd1    $00
dbd3: 00                           .dd1    $00
dbd4: 00                           .dd1    $00
dbd5: 00                           .dd1    $00
dbd6: 00                           .dd1    $00
dbd7: 00                           .dd1    $00
dbd8: 00                           .dd1    $00
dbd9: 00                           .dd1    $00
dbda: 00                           .dd1    $00
dbdb: 00                           .dd1    $00
dbdc: 00                           .dd1    $00
dbdd: 00                           .dd1    $00
dbde: 00                           .dd1    $00
dbdf: 00                           .dd1    $00
dbe0: 00                           .dd1    $00
dbe1: 00                           .dd1    $00
dbe2: 00                           .dd1    $00
dbe3: 00                           .dd1    $00
dbe4: 00                           .dd1    $00
dbe5: 00                           .dd1    $00
dbe6: 00                           .dd1    $00
dbe7: 00                           .dd1    $00
dbe8: 00                           .dd1    $00
dbe9: 00                           .dd1    $00
dbea: 00                           .dd1    $00
dbeb: 00                           .dd1    $00
dbec: 00                           .dd1    $00
dbed: 00                           .dd1    $00
dbee: 00                           .dd1    $00
dbef: 00                           .dd1    $00
dbf0: 00                           .dd1    $00
dbf1: 00                           .dd1    $00
dbf2: 00                           .dd1    $00
dbf3: 00                           .dd1    $00
dbf4: 00                           .dd1    $00
dbf5: 00                           .dd1    $00
dbf6: 00                           .dd1    $00
dbf7: 00                           .dd1    $00
dbf8: 00                           .dd1    $00
dbf9: 00                           .dd1    $00
dbfa: 00                           .dd1    $00
dbfb: 00                           .dd1    $00
dbfc: 00                           .dd1    $00
dbfd: 00                           .dd1    $00
dbfe: 00                           .dd1    $00
dbff: 00                           .dd1    $00

                   ********************************************************************************
                   * Various routines                                                             *
                   * These get copied out of $DC00 into $0A00                                     *
                   * They also get copied into the other bank of memory                           *
                   * So probably have some banking code in there.                                 *
                   ********************************************************************************
                                   .addrs  $0a00
0a00: d8                           cld
0a01: 48                           pha
0a02: 8a                           txa
0a03: d0 09                        bne     L0A0E
0a05: 2c 8b c0                     bit     LCBANK1
0a08: 2c 8b c0                     bit     LCBANK1
0a0b: 4c 03 d0                     jmp     PRINT_STACK_CHAR

0a0e: 10 09        L0A0E           bpl     L0A19
0a10: 2c 8b c0                     bit     LCBANK1
0a13: 2c 8b c0                     bit     LCBANK1
0a16: 4c 00 d0                     jmp     LD000

0a19: 8e 0c 0b     L0A19           stx     L0B0B+1
0a1c: bd b8 03                     lda     SLOT_INFO,x
0a1f: 29 0f                        and     #$0f
0a21: 48                           pha
0a22: 8a                           txa
0a23: 0a                           asl     A
0a24: 0a                           asl     A
0a25: 0a                           asl     A
0a26: 0a                           asl     A
0a27: aa                           tax
0a28: 68                           pla
0a29: c9 03                        cmp     #$03              ;Possibly serial card
0a2b: f0 78                        beq     L0AA5
0a2d: c9 04                        cmp     #$04              ;High speed serial
0a2f: f0 60                        beq     L0A91
0a31: c9 05                        cmp     #$05              ;Parallel printer
0a33: f0 36                        beq     CARD5
0a35: c9 06                        cmp     #$06              ;Dunno Softcard manual is silent
0a37: f0 03                        beq     CARD6
0a39: 68                           pla
0a3a: d0 66                        bne     L0AA2
0a3c: 68           CARD6           pla
0a3d: c0 0e                        cpy     #$0e
0a3f: f0 13                        beq     L0A54
0a41: c0 0f                        cpy     #$0f
0a43: f0 0f                        beq     L0A54
0a45: c0 0d                        cpy     #$0d
0a47: f0 0b                        beq     L0A54
0a49: c0 10                        cpy     #$10
0a4b: d0 55                        bne     L0AA2
0a4d: 20 54 0a                     jsr     L0A54
0a50: b0 3c                        bcs     L0A8E
0a52: 90 4e                        bcc     L0AA2

0a54: 8c 62 0a     L0A54           sty     L0A61+1
0a57: 48                           pha
0a58: 20 06 0b                     jsr     L0B06
0a5b: 8e 63 0a                     stx     L0A61+2
0a5e: 8e 6a 0a                     stx     L0A68+2
0a61: ad 00 c1     L0A61           lda     $c100
0a64: 8d 69 0a                     sta     L0A68+1
0a67: 68                           pla
0a68: 4c 00 c1     L0A68           jmp     $c100

0a6b: 68           CARD5           pla
0a6c: c0 0d                        cpy     #$0d
0a6e: f0 1e                        beq     L0A8E
0a70: c0 10                        cpy     #$10
0a72: f0 0f                        beq     L0A83
0a74: c0 0f                        cpy     #$0f
0a76: d0 2a                        bne     L0AA2
0a78: 48                           pha
0a79: 20 83 0a     L0A79           jsr     L0A83
0a7c: f0 fb                        beq     L0A79
0a7e: 68                           pla
0a7f: 99 80 c0                     sta     IWM_PH0_OFF,y
0a82: 60                           rts

0a83: 20 06 0b     L0A83           jsr     L0B06
0a86: 8e 8b 0a                     stx     L0A89+2
0a89: ad c1 c0     L0A89           lda     $c0c1
0a8c: 30 14                        bmi     L0AA2
0a8e: a9 ff        L0A8E           lda     #$ff
0a90: 60                           rts

0a91: 68           L0A91           pla
0a92: c0 10                        cpy     #$10
0a94: f0 f8                        beq     L0A8E
0a96: c0 0d                        cpy     #$0d
0a98: f0 66                        beq     L0B00
0a9a: c0 0f                        cpy     #$0f
0a9c: f0 57                        beq     L0AF5
0a9e: c0 0e                        cpy     #$0e
0aa0: f0 49                        beq     L0AEB
0aa2: a9 00        L0AA2           lda     #$00
0aa4: 60                           rts

0aa5: 68           L0AA5           pla
0aa6: c0 10                        cpy     #$10
0aa8: f0 28                        beq     L0AD2
0aaa: c0 0f                        cpy     #$0f
0aac: f0 15                        beq     L0AC3
0aae: c0 0d                        cpy     #$0d
0ab0: f0 2d                        beq     L0ADF
0ab2: c0 0e                        cpy     #$0e
0ab4: d0 ec                        bne     L0AA2
0ab6: a9 01        L0AB6           lda     #$01
0ab8: 20 d2 0a                     jsr     L0AD2
0abb: f0 f9                        beq     L0AB6
0abd: bd 8f c0                     lda     IWM_Q7_ON,x
0ac0: a9 ff                        lda     #$ff
0ac2: 60                           rts

0ac3: 48           L0AC3           pha
0ac4: a9 00        L0AC4           lda     #$00
0ac6: 20 d2 0a                     jsr     L0AD2
0ac9: f0 f9                        beq     L0AC4
0acb: 68                           pla
0acc: 9d 8f c0                     sta     IWM_Q7_ON,x
0acf: a9 ff                        lda     #$ff
0ad1: 60                           rts

0ad2: a8           L0AD2           tay
0ad3: bd 8e c0                     lda     IWM_Q7_OFF,x
0ad6: 4a                           lsr     A
0ad7: 88                           dey
0ad8: f0 01                        beq     L0ADB
0ada: 4a                           lsr     A
0adb: 90 c5        L0ADB           bcc     L0AA2
0add: b0 af                        bcs     L0A8E

0adf: a9 03        L0ADF           lda     #$03
0ae1: 9d 8e c0                     sta     IWM_Q7_OFF,x
0ae4: a9 15                        lda     #$15
0ae6: 9d 8e c0                     sta     IWM_Q7_OFF,x
0ae9: d0 a3                        bne     L0A8E

0aeb: 20 06 0b     L0AEB           jsr     L0B06
0aee: 20 4d c8                     jsr     $c84d
0af1: bd b8 05                     lda     $05b8,x
0af4: 60                           rts

0af5: 48           L0AF5           pha
0af6: 20 06 0b                     jsr     L0B06
0af9: 68                           pla
0afa: 9d b8 05                     sta     $05b8,x
0afd: 4c aa c9                     jmp     $c9aa

0b00: 20 06 0b     L0B00           jsr     L0B06
0b03: 4c 00 c8                     jmp     $c800

0b06: 8e f8 06     L0B06           stx     SCRNHOLE5
0b09: 8a                           txa
0b0a: a8                           tay
0b0b: a9 00        L0B0B           lda     #$00
0b0d: 09 c0                        ora     #$c0
0b0f: aa                           tax
0b10: 8e 18 0b                     stx     L0B1A-2
0b13: 2c ff cf                     bit     CLRROM
0b16: ad 00 c1                     lda     $c100
0b19: 60                           rts

0b1a: 1a 1a 1a 1a+ L0B1A           .fill   230,$1a
                                   .adrend ↑ ~$0a00
                                   .adrend ↑ $d000
