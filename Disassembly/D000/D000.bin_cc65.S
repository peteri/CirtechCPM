; Target assembler: cc65 v2.18.0 [--target none -C D000.bin_cc65.cfg]
;***************************************************************
;* Disassembly of the D000 code loaded from disk               *
;* by Cirtech CP/M plus for the Apple //e.                     *
;*                                                             *
;* Binary   (C) Copyright 1985 Cirtech                         *
;* Comments (C) Copyright 2023 Peter Ibbotson                  *
;* RWTS     (C) Copyright 1983 Apple                           *
;*                                                             *
;* Note for RWTS routine comments and labels from the Apple    *
;* DOS3.3C source code PDF file has been used where the code   *
;* matches.                                                    *
;*                                                             *
;* Disassembled using 6502bench SourceGen v1.8.5               *
;***************************************************************
                .setcpu "65C02"
DSKOP_RD       EQU       1          ;Disk operation read
DSKOP_FMT      EQU       3          ;Disk operation format
DSKOP_WRTRK    EQU       4          ;Disk operation write track
DSKOP_RDTRK    EQU       5          ;Disk operation read track
CHAR_OP_INI    EQU       $0d        ;Character IO Init (same as pascal offset)
CHAR_OP_RD     EQU       $0e        ;Character IO Read (same as pascal offset)
CHAR_OP_WR     EQU       $0f        ;Character IO Write (same as pascal offset)
CHAR_OP_ST     EQU       $10        ;Character IO Status (same as pascal offset)

SCRLINEL       EQU       $20        ;Address of current line in $400
SCRLINEH       EQU       $21        ;Screen address high
ESCAPE_STATE   EQU       $22        ;State for ESCAPE leadin
CURSOR_STATE   EQU       $23        ;Bit 7 high if cursor on screen
CURSORX        EQU       $25        ;Cursor X (80 col)
BLANKCH        EQU       $26        ;Blank character.
COUNT          EQU       $26        ;RDADR16 - 'Must find' count
IDX            EQU       $26        ;READ16 - Index into (BUF).
LAST           EQU       $26        ;RDADR16 - 'Odd bit' nibls.
T0             EQU       $26        ;Temp for POSTNBL16
TRKCNT         EQU       $26        ;SEEK - Halftrks moved count.
WTEMP          EQU       $26        ;WRITE16 - Temp for data at Nbuf2,0.
CSUM           EQU       $27        ;RDADR16 - Checksum byte.
PRIOR          EQU       $27        ;SEEK - Prior halftrack.
SLOTZ          EQU       $27        ;WRITE16 - Slot num z-pag loc.
CURSORY        EQU       $29        ;Cursor Y (80 col)
TRKN           EQU       $2a        ;SEEK - desired track.
SLOTTEMP       EQU       $2b        ;SEEK - Slot num times $10
CSSTV          EQU       $2c        ;RDADR16 - Four bytes.
SECTOR         EQU       $2d        ;RDADR16 - Sector from sector header
TRACK          EQU       $2e        ;RDADR16 - Track from sector header
VOLUME         EQU       $2f        ;RDADR16 - Volume from sector header
MON_INVFLAG    EQU       $32        ;text mask (255=normal, 127=flash, 63=inv)
DRIVNO         EQU       $35        ;Hi bit set if drive 2 for Disk II
MAXTRK         EQU       $3d        ;Maximum track for format
AA             EQU       $3e        ;WRADR16 - Timing constant
NSECT          EQU       $3f        ;WRADR16 - Sector number
NVOL           EQU       $41        ;WRADR16 - Volume number
PRODOS_CMD     EQU       $42        ;PRODOS - Command
PRODOS_UNITNUM EQU       $43        ;PRODOS - Unit number
PRDOOS_BUFPTRL EQU       $44        ;PRODOS - Buffer pointer low
TRK            EQU       $44        ;WRADR16 - Track number
NSYNC          EQU       $45        ;FORMAT - Num gap self-sync nibls.
PRODOS_BUFPTRH EQU       $45        ;PRODOS - buffer pointer high
MONTIMEL       EQU       $46        ;MSWAIT - Motor on time counter low
PRODOS_BLKNUM  EQU       $46        ;PRODOS - Block number
MONTIMEH       EQU       $47        ;MSWAIT - Motor on time counter high
DISK_TRKL      EQU       $0380      ;Disk track low (From Z80)
DISK_SECT      EQU       $0381      ;Disk sector (from Z80)
DISK_TRK_ADDR  EQU       $0382      ;While track read/write page
DISK_DRV       EQU       $0384      ;Drive to use from CPM (Slot)
DISK_ACTD      EQU       $0385      ;Current active disk ][ drive
DISK_TRKH      EQU       $0386      ;Disk track high (from Z80)
DISK_VOL       EQU       $0387      ;Disk volume
DISK_OP        EQU       $0388      ;Disk operation
DISK_ERR       EQU       $0389      ;Disk Error back
SLOT_INFO      EQU       $03b8      ;Map of slot to card type
CURTRK         EQU       $0478      ;SEEK - Current track on entry
DRV1TRK        EQU       $0478      ;Drive 1 track
DRV2TRK        EQU       $04f8      ;Drive 2 track
SEEKCNT        EQU       $04f8      ;# Reseeks before recalibrate
RETRYCNT       EQU       $0578      ;Retry counter
STSBYTE        EQU       $05b8      ;SSC Char
DISKSLOTCX     EQU       $05f8      ;Disk slot $60
SLOTABS        EQU       $0678      ;WRITE16 - Slot num non-z-pag loc.
SCRNHOLE5      EQU       $06f8      ;text page 1 screen holes
RECALCNT       EQU       $06f8      ;# Recalibrates -1
DISK_BUFF      EQU       $0800      ;Disk buffer
SET80COL       EQU       $c001      ;W use PAGE2 for aux mem (80STOREON)
SET80VID       EQU       $c00d      ;W enable 80-column display mode
SETALTCHAR     EQU       $c00f      ;W use alternate char set
SPKR           EQU       $c030      ;RW toggle speaker
TXTPAGE1       EQU       $c054      ;RW display page 1
TXTPAGE2       EQU       $c055      ;RW display page 2 (or read/write aux mem)
IWM_PH0_OFF    EQU       $c080      ;IWM phase 0 off
PARA_DATAOUT   EQU       $c080      ;Apple parallel card data out.
IWM_MOTOR_OFF  EQU       $c088      ;IWM motor off
IWM_MOTOR_ON   EQU       $c089      ;IWM motor on
IWM_DRIVE_1    EQU       $c08a      ;IWM select drive 1
IWM_DRIVE_2    EQU       $c08b      ;IWM select drive 2
LCBANK1        EQU       $c08b      ;RWx2 read/write RAM bank 1
IWM_Q6_OFF     EQU       $c08c      ;IWM read
IWM_Q6_ON      EQU       $c08d      ;IWM WP-sense
IWM_Q7_OFF     EQU       $c08e      ;IWM WP-sense/read
STATUS6510     EQU       $c08e      ;Status for 6510 based serial card
DATA6510       EQU       $c08f      ;Data for 6510 based serial card
IWM_Q7_ON      EQU       $c08f      ;IWM write
PARA_ACKIN     EQU       $c0c1      ;Apple parallel card acknowledge status
SCC_INIT       EQU       $c800      ;Super serial card init
SSC_READ       EQU       $c84d      ;Super serial card read routine
SSC_WRITE      EQU       $c9aa      ;Super serial card write routine
CLRROM         EQU       $cfff      ;disable slot C8 ROM
NBUF1          EQU       $de00      ;Six bit data bytes
NBUF2          EQU       $df00      ;56 bytes of 2 bit data
FOUND          EQU       $df57      ;Table of found sectors during format
D2SAVWRDTAPG   EQU       $df67      ;Disk II save write data page
D2SAVRDDTAPG   EQU       $df68      ;Disk II save read page
D2SAVETRAN     EQU       $df69      ;Disk II save sector translation

;*******************************************************************************
;*                                                                             *
;* Routines to handle the 80 Column card                                       *
;*                                                                             *
;*******************************************************************************
                .org    $d000
TOG_CURJMP:     jmp     POP_TOGGLE_CURSOR

PRINT_STACK_CHAR:
                pla                ;Get our character off the stack
PRINT_CHAR:     ora     #$80       ;Set the high bit
                bit     ESCAPE_STATE
                bpl     CHECK_ESC_CHAR1 ;Bit 7 clear check for escape
                bit     GOTO_Y     ;Goto YX, Y Character set yet?
                bmi     GOTO_YX    ;Must be the X postion now we can move the  cursor
                sta     GOTO_Y     ;Setting the Y character
                rts

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
; However for <ESC>EQU Y X (goto Y X) the states are as follows
; |Escape state| GOTOY     | 
; |------------|-----------|
; | 00zz zzzz  | 0yyy yyyy | Waiting for escape
; | 01zz zzzz  | 0yyy yyyy | Escape seen waiting next char
; | 11zz zzzz  | 0yyy yyyy | <Esc>EQU seen waiting Y coord
; | 11zz zzzz  | 1yyy yyyy | <Esc>EQU Y seen waiting X Coord
; | 00zz zzzz  | 0yyy yyyy | <Esc>EQU Y X seen cursor moved to correct pos
; 
GOTO_YX:        jsr     HIDE_CURSOR
                sec
                sbc     #$a0       ;Subtract space
                cmp     #80        ;Okay are we on screen?
                bcc     CURSORX_OK ;Bigger than screen
                lda     #$00       ;Zero cursor
CURSORX_OK:     sta     CURSORX    ;Save away X position
                lda     GOTO_Y     ;Get the Y Coord
                sec
                sbc     #$a0
                cmp     #24
                bcc     CURSORY_OK
                lda     #$00
CURSORY_OK:     sta     CURSORY
                jsr     SET_LINE_PTR
                ldy     #$00
                sty     ESCAPE_STATE
                beq     SHOW_CURSOR

CHECK_ESC_CHAR1:
                bvc     CHECK_FOR_ESC
                jmp     ESCAPE_CHAR1

CHECK_FOR_ESC:  cmp     #$9b
                bne     CTRL_WRITE_SCR
                lda     #$40
                sta     ESCAPE_STATE
                rts

; Come here to write a character to screen
; and handle control characters
CTRL_WRITE_SCR: cmp     #$a0
                bcc     TEST_CONTROL_CHAR ;Go off and deal with a control character
                tax                ;Save A for later
                lda     CURSORX    ;Get the current cursor
                lsr     A          ;Divide by two
                bcs     WRITE_ODD  ;Was it odd
                bit     TXTPAGE2   ;If so write to the odd columns
WRITE_ODD:      tay                ;Save CursorX/2 -> Y
                txa                ;Get back our character
                and     MON_INVFLAG ;Are we in inverse mode?
                bmi     STORE_TO_SCREEN
                cmp     #$60       ;Inverse lowercase?
                bcs     STORE_TO_SCREEN ;No change needed
                cmp     #$40       ;Inverse Numbers or punctuation?
                bcc     STORE_TO_SCREEN ;No Change needed
                and     #$bf       ;Convert uppercase out of mouse text
STORE_TO_SCREEN:
                sta     (SCRLINEL),y ;Write character to screen
                bit     TXTPAGE1   ;Back to main text page
                inc     CURSORX    ;Move cursor to right
                lda     CURSORX
                cmp     #80        ;Cursor still on screen?
                bcc     SHOW_CURSOR ;Go show it.
                lda     #$00       ;Set us to back to column zero
                sta     CURSORX
                inc     CURSORY    ;Move down a line
                ldy     CURSORY
                cpy     #24        ;Still on screen?
                bcc     NO_SCROLL  ;Yep don't scroll
                dec     CURSORY    ;Correct us
                jsr     SCROLL_UP  ;Scroll the screen up
NO_SCROLL:      ldy     CURSORY
                lda     LINE_STARTH,y ;Set up the current screen line pointer
                sta     SCRLINEH
                lda     LINE_STARTL,y
                sta     SCRLINEL
SHOW_CURSOR:    lda     #$80
                sta     CURSOR_STATE ;Set the cursor to on
FLIP_INVERTED:  lda     CURSORX    ;Get cursor position
                lsr     A
                bcs     CURSOR_PAGE1 ;Which page?
                bit     TXTPAGE2
CURSOR_PAGE1:   tay                ;Cursor divided by two to Y
                lda     (SCRLINEL),y ;Get the current character on screen
                cmp     #$20       ;Is it an inverse Uppercase
                bcs     INVERT_CHAR ;If not just go and do invert
                ora     #$40       ;Put back bit 6 so it's a proper Uppercase
INVERT_CHAR:    eor     #$80       ;Invert the character
                bmi     STORE_CURSOR ;Store if it's normal
                cmp     #$60       ;Lower case inverted
                bcs     STORE_CURSOR ;Store it
                cmp     #$40       ;Inverse Numbers or punctuation?
                bcc     STORE_CURSOR ;We're good store it
                and     #$bf       ;Upper case letters, kill bit 6
STORE_CURSOR:   sta     (SCRLINEL),y ;Store on screen
                bit     TXTPAGE1   ;Back to text page 1
IGNORE_CHAR:    rts                ;Also used in jump table

; Handle a possible control character
TEST_CONTROL_CHAR:
                cmp     #$9e       ;Off the end of the table
                bcs     IGNORE_CHAR ;Ignore it
                cmp     #$87       ;Off the front of the table
                bcc     IGNORE_CHAR ;Ignore it
HANDLE_CONTROL_CHAR:
                jsr     HIDE_CURSOR
                sec
                sbc     #$87       ;Subtract Bell character
                asl     A          ;Mult by 2 for table index
                tay
                lda     CTRL_CHAR_TAB,y ;Lookup the entry and modify jump
                sta     CTRL_CHAR_JSR+1
                iny
                lda     CTRL_CHAR_TAB,y
                sta     CTRL_CHAR_JSR+2
CTRL_CHAR_JSR:  jsr     $0000      ;Jump to control handler
                jmp     SHOW_CURSOR

ESCAPE_CHAR1:   ldy     #$00       ;First character in escape sequence
                sty     ESCAPE_STATE
                cmp     #'=' | $80 ;Goto YX command?
                beq     GOTO_YX_CMD ;Yes it is
; Convert any of the single character escape codes
                ldy     #$05
FIND_ESC_CHAR_LOOP:
                cmp     ESC_CTRL_CODES,y ;Is it in the table?
                beq     FOUND_ESC_CHAR ;Yes it is do something
                dey
                bpl     FIND_ESC_CHAR_LOOP
                jmp     PRINT_CHAR

GOTO_YX_CMD:    sec                ;Set the high bit so say we're waiting for Y
                ror     ESCAPE_STATE
                clc
                ror     GOTO_Y     ;Clear bit 7 (Seen Y coord)
                rts

FOUND_ESC_CHAR: lda     ESC_CHAR_TRANS,y ;Get the regular Ctrl code
                bne     HANDLE_CONTROL_CHAR
; Carriage return
CARRIAGE_RET:   lda     #$00
                sta     CURSORX
                rts

; Line feed for 80 column
LINEFEED:       inc     CURSORY
                ldy     CURSORY
                cpy     #24        ;Last line?
                bcc     SET_LINE_PTR ;Nope just set the line pointer
                dec     CURSORY    ;Backup the cursor
                jsr     SCROLL_UP  ;Scroll up
SET_LINE_PTR:   ldy     CURSORY    ;Lookup new line pointer
                lda     LINE_STARTH,y
                sta     SCRLINEH   ;And save it away
                lda     LINE_STARTL,y
                sta     SCRLINEL
                rts

POP_TOGGLE_CURSOR:
                pla                ;Pop unwanted parameter
TOGGLE_CURSOR:  lda     CURSOR_STATE ;Flip the cursor state
                eor     #$80
                sta     CURSOR_STATE
                jmp     FLIP_INVERTED ;Flip the character on screen inverse state

; Backspace
BACKSPACE:      dec     CURSORX    ;Decrement the cursor position
                bmi     OFF_LEFT   ;Off left hand of screen?
                rts                ;Go Home still on screen

OFF_LEFT:       lda     #79        ;Right hand edge of screen
                sta     CURSORX
                dec     CURSORY    ;Back up a line
                bpl     SET_LINE_PTR ;Still on screen set pointer
                lda     #$00
                sta     CURSORY    ;Top line of screen
                jsr     SCROLL_CARRY_FLAG ;Scroll depending on state of carry flage
                jmp     SET_LINE_PTR

; Cursor Right
CURSOR_RIGHT:   inc     CURSORX    ;Add one to cursor position
                lda     CURSORX
                cmp     #80        ;Off right hand edge
                bcs     OFF_RIGHT
                rts                ;Nope go home

OFF_RIGHT:      jsr     CARRIAGE_RET ;Off right hand edge Set to 0
                jmp     LINEFEED   ;and down a line

; Clear line
CLR_LINE:       lda     #$00       ;Set us to be at the beginning of the line
                sta     CURSORX
                jmp     CLR_EOL    ;Now clear to EOL

; Home
HOME:           ldy     #$00       ;Set Cursor X,Y to 0,0
                sty     CURSORX
                sty     CURSORY
                jmp     SET_LINE_PTR ;Set the current line pointer

; Clear to end of screen
CLR_TO_ENDSCR:  jsr     CLR_EOL
                lda     SCRLINEL   ;Save away current screen position
                pha
                lda     SCRLINEH
                pha
                ldx     CURSORY    ;Get line number
CLR_NEXT_LINE:  inx
                cpx     #24
                bne     CLR_LINE_X ;Go and clear this line
                pla
                sta     SCRLINEH
                pla
                sta     SCRLINEL
                rts

CLR_LINE_X:     lda     LINE_STARTH,x
                sta     SCRLINEH
                lda     LINE_STARTL,x
                sta     SCRLINEL
                ldy     #$00
                jsr     CLR_FROM_YREG
                beq     CLR_NEXT_LINE ;Zero flag always set back into loop
; Clear the screen and initialise the 
; video system
CLEAR_SCREEN:   sta     TXTPAGE1   ;Setup the //e hardware
                sta     SETALTCHAR
                sta     SET80VID
                sta     SET80COL
                lda     #$00       ;Set X,Y to zero
                sta     CURSORX
                sta     CURSORY
                sta     SCRLINEL   ;Set the screen ptr up
                lda     #$04
                sta     SCRLINEH
                bne     CLR_TO_ENDSCR

; Clear to end of line
CLR_EOL:        ldy     CURSORX    ;Clear to EOL
CLR_FROM_YREG:  bit     TXTPAGE2
                tya                ;Divide cursor by two
                lsr     A
                pha                ;Save cursor/2 for Page 1 clear
                tay
                lda     #$a0       ;Sort out if blank is inverse or not
                and     MON_INVFLAG
                sta     BLANKCH    ;Save our blank character
                bcs     SKIP_ODD_CLR ;Do we need skip the first one?
CLR_PAGE2_LINE: sta     (SCRLINEL),y ;Clear the character
SKIP_ODD_CLR:   iny                ;Next one
                cpy     #40        ;All Done?
                bne     CLR_PAGE2_LINE ;Nah loop
                pla                ;Restore cursor/2 for page 1 clear
                tay
                lda     BLANKCH    ;Get the character to clear with
                bit     TXTPAGE1   ;Setup for main text page
CLR_PAGE1_LINE: sta     (SCRLINEL),y ;Clear the character
                iny                ;Next one
                cpy     #40        ;All done?
                bne     CLR_PAGE1_LINE ;Nope do the next one
                rts

; Ring the bell
BELL:           lda     #$35
                sta     BELL_COUNT
BELL_LOOP:      lda     #$05
                jsr     DELAY
                sta     SPKR
                lda     #$20
                jsr     DELAY
                sta     SPKR
                dec     BELL_COUNT
                bne     BELL_LOOP
                rts

DELAY:          sec
DELAY1:         pha                ;Save counter
DELAY2:         sbc     #$01       ;Decrement our counter
                bne     DELAY2     ;Inner loop
                pla                ;Get counter back for the outer loop
                sbc     #$01
                bne     DELAY1     ;All done yet?
                rts

BELL_COUNT:     .byte   $00

SET_INVERSE:    lda     #$7f
                bne     STORE_INVFLAG

SET_NORMAL:     lda     #$ff
STORE_INVFLAG:  sta     MON_INVFLAG
                rts

SCROLL_UP:      sec
; Come in here with carry flag set to scroll up
; carry flag clear to scroll down
SCROLL_CARRY_FLAG:
                .byte   $24        ;BIT Zero page
SCROLL_DOWN:    clc
                lda     #$a0       ;Space character
                and     MON_INVFLAG ;Should it be inverted?
                tay
                ldx     #39        ;Bytes to move
SCROLL_LOOP:    sta     TXTPAGE2   ;Do half the 80 columns
                jsr     SCROLL_COLUMN
                sta     TXTPAGE1
                jsr     SCROLL_COLUMN ;Do the other half
                dex
                bpl     SCROLL_LOOP ;Done all 40?
                rts

SCROLL_COLUMN:  bcs     SCROLL_COL_UP ;Scroll a single column
                jmp     SCROLL_COL_DOWN

SCROLL_COL_UP:  lda     $0480,x    ;Copy line by line
                sta     $0400,x
                lda     $0500,x
                sta     $0480,x
                lda     $0580,x
                sta     $0500,x
                lda     $0600,x
                sta     $0580,x
                lda     $0680,x
                sta     $0600,x
                lda     $0700,x
                sta     $0680,x
                lda     $0780,x
                sta     $0700,x
                lda     $0428,x
                sta     $0780,x
                lda     $04a8,x
                sta     $0428,x
                lda     $0528,x
                sta     $04a8,x
                lda     $05a8,x
                sta     $0528,x
                lda     $0628,x
                sta     $05a8,x
                lda     $06a8,x
                sta     $0628,x
                lda     $0728,x
                sta     $06a8,x
                lda     $07a8,x
                sta     $0728,x
                lda     $0450,x
                sta     $07a8,x
                lda     $04d0,x
                sta     $0450,x
                lda     $0550,x
                sta     $04d0,x
                lda     $05d0,x
                sta     $0550,x
                lda     $0650,x
                sta     $05d0,x
                lda     $06d0,x
                sta     $0650,x
                lda     $0750,x
                sta     $06d0,x
                lda     $07d0,x
                sta     $0750,x
                tya                ;Blank character in Y
                sta     $07d0,x
                rts

SCROLL_COL_DOWN:
                lda     $0750,x    ;copy lines up
                sta     $07d0,x
                lda     $06d0,x
                sta     $0750,x
                lda     $0650,x
                sta     $06d0,x
                lda     $05d0,x
                sta     $0650,x
                lda     $0550,x
                sta     $05d0,x
                lda     $04d0,x
                sta     $0550,x
                lda     $0450,x
                sta     $04d0,x
                lda     $07a8,x
                sta     $0450,x
                lda     $0728,x
                sta     $07a8,x
                lda     $06a8,x
                sta     $0728,x
                lda     $0628,x
                sta     $06a8,x
                lda     $05a8,x
                sta     $0628,x
                lda     $0528,x
                sta     $05a8,x
                lda     $04a8,x
                sta     $0528,x
                lda     $0428,x
                sta     $04a8,x
                lda     $0780,x
                sta     $0428,x
                lda     $0700,x
                sta     $0780,x
                lda     $0680,x
                sta     $0700,x
                lda     $0600,x
                sta     $0680,x
                lda     $0580,x
                sta     $0600,x
                lda     $0500,x
                sta     $0580,x
                lda     $0480,x
                sta     $0500,x
                lda     $0400,x
                sta     $0480,x
                tya
                sta     $0400,x
                rts

HIDE_CURSOR:    bit     CURSOR_STATE ;Get the current cursor state
                bpl     CURSOR_IS_OFF ;Is it off
                pha                ;Nope save the accumulator
                jsr     TOGGLE_CURSOR ;Toggle the cursor
                pla                ;Restore acc
CURSOR_IS_OFF:  rts

CTRL_CHAR_TAB:  .word   BELL       ;Ctrl-G
                .word   BACKSPACE  ;Ctrl-H
                .word   IGNORE_CHAR ;Ctrl-I
                .word   LINEFEED   ;Ctrl-J
                .word   CLR_TO_ENDSCR ;Ctrl-K
                .word   CLEAR_SCREEN ;Ctrl-L
                .word   CARRIAGE_RET ;Ctrl-M
                .word   SET_NORMAL ;Ctrl-N
                .word   SET_INVERSE ;Ctrl-O
                .word   IGNORE_CHAR ;Ctrl-P
                .word   IGNORE_CHAR ;Ctrl-Q
                .word   IGNORE_CHAR ;Ctrl-R
                .word   IGNORE_CHAR ;Ctrl-S
                .word   IGNORE_CHAR ;Ctrl-T
                .word   IGNORE_CHAR ;Ctrl-U
                .word   SCROLL_DOWN ;Ctrl-V
                .word   SCROLL_UP  ;Ctrl-W
                .word   IGNORE_CHAR ;Ctrl-X
                .word   HOME       ;Ctrl-Y
                .word   CLR_LINE   ;Ctrl-Z
                .word   IGNORE_CHAR ;Ctrl-[ aka Esc
                .word   CURSOR_RIGHT ;Ctrl-\
                .word   CLR_EOL    ;Ctrl-]
LINE_STARTH:    .byte   $04,$04,$05,$05,$06,$06,$07,$07 ;Start of video line high
                .byte   $04,$04,$05,$05,$06,$06,$07,$07
                .byte   $04,$04,$05,$05,$06,$06,$07,$07
LINE_STARTL:    .byte   $00,$80,$00,$80,$00,$80,$00,$80 ;Start of video line low
                .byte   $28,$a8,$28,$a8,$28,$a8,$28,$a8
                .byte   $50,$d0,$50,$d0,$50,$d0,$50,$d0
; Used to convert some televideo 920(maybe?) escape codes to Ctrl codes
ESC_CTRL_CODES: .byte   $8c        ;<ESC><FF> - Form feed
                .byte   ')' | $80  ;<ESC> ) - Start half intensity
                .byte   '(' | $80  ;<ESC> ( - End half intesity
                .byte   '*' | $80  ;<ESC> * - Clear all to null
                .byte   'Y' | $80  ;<ESC> Y - Page erase to space
                .byte   'T' | $80  ;<ESC> T - Line erase to space
ESC_CHAR_TRANS: .byte   $8c        ;Ctrl-L - Form feed
                .byte   $8e        ;Ctrl-N - set normal
                .byte   $8f        ;Ctrl-O - Set Inverse
                .byte   $8c        ;Ctrl-L - Form feed
                .byte   $8b        ;Ctrl-K - Clear to end of screen
                .byte   $9d        ;Ctrl-] - Clear to end of line
GOTO_Y:         .byte   $00        ;Goto YX cursor Y
                .res    90,$1a

;*******************************************************************************
;*                                                                             *
;* Routines to handle Disk drives                                              *
;*                                                                             *
;*******************************************************************************
                .org    $d400
                lda     DISK_DRV   ;Get the drive ($60 for S6,D1)
                and     #$7f       ;Mask off drive (ProDOS style)
                sta     DISKSLOTCX
                lsr     A
                lsr     A
                lsr     A
                lsr     A
                tax
                lda     SLOT_INFO,x ;Get Disk type? Might be card in slot
                cmp     #$02       ;DISK ][ ?
                beq     DISKII
                cmp     #$07       ;Ram drive or Prodos?
                bcc     BAD_SLOT_ERR
                jmp     IDC_CHECK  ;Go do IDC check

BAD_SLOT_ERR:   lda     #$01
                sta     DISK_ERR
                rts

;*******************************************************************************
;*                                                                             *
;* Disk II driver code                                                         *
;*                                                                             *
;* Code that is the same as the RWTS routines in the DOS3.3C source code from  *
;* https://www.brutaldeluxe.fr/documentation/dos33/apple2_SRC_DOS33C_1983.pdf  *
;* has the same comments, although some of the long comments have been edited  *
;* and the short comments have been converted to lower case.                   *
;*                                                                             *
;* Addresses for the Woz Disk II card have used the IWM conventions from the   *
;* sourcegen symbol table. Other symbols match those in the RWTS routines in   *
;* the DOS 3.3C source code.                                                   *
;*                                                                             *
;* Code has large chunks that are copies of the RWTS routines from DOS, but    *
;* some bits are different (PRENIB16 for example) along with the RWTS calling  *
;* mechanism which means a one to one match doesn't work.                      *
;*                                                                             *
;*******************************************************************************
DISKII:         ldy     #$02       ;Set Recalibrate
                sty     RECALCNT   ;Count
                ldy     #$04       ;Set reseek
                sty     SEEKCNT    ;count
                ldx     DISKSLOTCX ;Get slot # for this operation
; Now check if the motor is on, then start it.
                lda     IWM_Q7_OFF,x ;Make sure in read mode
                lda     IWM_Q6_OFF,x
                ldy     #$08       ;We may hafta check several times to be sure
CHKIFON:        lda     IWM_Q6_OFF,x ;Get the data
                pha                ;Delay for disk data to change
                pla
                pha
                pla
                cmp     IWM_Q6_OFF,x ;Check running here
                bne     ITISON     ;=> it's on
                dey                ;Maybe we didn't catch it
                bne     CHKIFON    ;So we'll try again
ITISON:         php                ;Save test results
                lda     IWM_MOTOR_ON,x ;Turn on motor regardless
                lda     #$ef       ;Set up the
                sta     MONTIMEL   ;motor-on time
                lda     #$d8       ;Note value is complemented
                sta     MONTIMEH
                lda     DISK_DRV   ;Determine drive one or two
                cmp     DISK_ACTD  ;same drive used before?
                beq     OK
                sta     DISK_ACTD  ;Now using this drive
                plp                ;Tell him motor was off
                ldy     #$00       ;Set zero flag
                php
OK:             rol     A          ;By going into the carry
                bcs     SD1        ;Select drive 2!
                lda     IWM_DRIVE_1,x ;Assume drive 1 to hit
                bcc     DRVSEL     ;If wrong, enable drive 2 instead

SD1:            lda     IWM_DRIVE_2,x ;Nope drive 2
DRVSEL:         ror     DRIVNO     ;Save selected drive
; Drive selected. If motoring up,
; wait before seeking...
                plp                ;Was the motor
                php                ;Previously off?
                bne     NOWAIT     ;=> No, forget waiting
                ldy     #$07       ;Yes, delay 150mS
SEEKW:          jsr     MSWAIT
                dey
                bne     SEEKW
                ldx     DISKSLOTCX ;Restore slot number
NOWAIT:         lda     DISK_OP    ;Examine disk operation
                cmp     #DSKOP_FMT
                bne     NOTFORMAT  ;Not format
                plp                ;Get back motor status
                jmp     DSKFORM    ;Do the format

NOTFORMAT:      lda     DISK_TRKL  ;Goto the track
                jsr     MYSEEK
                lda     DISK_OP    ;Get disk operation
                plp                ;Get back if we have some data incoming?
                bne     MOTORREADY ;Drive running so skip
                cmp     #DSKOP_RD  ;Read?
                beq     MOTORREADY ;Can skip waiting for rest of motor
                jsr     MOTOF      ;Time for a read
MOTORREADY:     cmp     #DSKOP_WRTRK ;Write a whole track?
                bne     CHECKRDTRKOP ;Nope, check for read
                jmp     D2TRACKOPER ;Go do full track operation

CHECKRDTRKOP:   cmp     #DSKOP_RDTRK ;Read track operation?
                bne     TRYTRK     ;Nope,do a single sector
                jmp     D2TRACKOPER ;Go do full track operation

TRYTRK:         ror     A          ;Set carry=1 for read, 0 for write
                php                ;and save that
                bcs     TRYTRK2    ;Must prenibblize for write
                jsr     PRENIB16
TRYTRK2:        ldy     #$30       ;Only 48 retries of any kind.
                sty     RETRYCNT
TRYADR:         ldx     DISKSLOTCX ;Get slot num into x-reg
                jsr     RDADR16    ;Read next address field
                bcc     RDRIGHT    ;If it read right, hurrah!
TRYADR2:        dec     RETRYCNT   ;Another mistaek!!
                bpl     TRYADR
; *
; * RRRRRECALIBRATE !!!!
; *
RECAL:          lda     #$2a       ;Recalibrate all over again
                jsr     SETTRK     ;Pretend to be on track 42 (DOS uses 96)
                dec     RECALCNT   ;Once too many?
                beq     DRVERR     ;Tried to recalibrate too many times error!
                lda     #$04       ;Reset the
                sta     SEEKCNT    ;seek counter
                lda     #$00
                jsr     MYSEEK     ;Move to track 00
                lda     DISK_TRKL
RESEEK:         jsr     MYSEEK     ;Go to correct track this time!
                jmp     TRYTRK2    ;Loop back, tray again on this track

RDRIGHT:        lda     VOLUME     ;Check volume isn't very interesting for CP/M
                sta     DISK_VOL   ;So just copy it
                pha                ;Left over from RWTS volume check code?
                pla
                ldy     TRACK      ;On the right track
                cpy     DISK_TRKL
                beq     RTTRK      ;If so good
                lda     CURTRK     ;Preserve destination track
                pha
                tya
                jsr     SETTRK
                pla
                dec     SEEKCNT    ;Should we reseek?
                bne     RESEEK     ;=> Yes, reseek
                beq     RECAL      ;=> No, Recalibrate!

DRVERR:         lda     #$01       ;Bad drive error
                plp                ;Pop disk operation
                sec
                bcs     DISKII_ERR

RTTRK:          lda     DISK_SECT  ;Get requested (logical) sector
                tay                ;Move to index reg
DOSECTTRAN:     lda     CPM_TRAN_SECT,y ;Compute physical sector
                cmp     SECTOR     ;Did we get the sector?
                bne     TRYADR2    ;No, keep trying
; *
; * Hooray! We got the right sector!
; *
                plp
                bcc     WRIT       ;Carry was set for read operation
                jsr     READ16
                php                ;Save status of read operation
                bcs     TRYADR2    ;Retry on error
                plp                ;Careful of stack
                ldx     #$00       ;Setup to postnibilize
                stx     T0
                jsr     POSTNB16
                ldx     DISKSLOTCX ;Restore slotnum into X
DISKII_OK:      lda     #$00       ;Clear error
                clc
DISKII_ERR:     sta     DISK_ERR   ;Setup disk error
                lda     IWM_MOTOR_OFF,x ;Turn off motor
                rts

WRIT:           jsr     WRITE16    ;Write nybbles now
                bcc     DISKII_OK  ;If no errors
                lda     #$10       ;Disk is write protected.
                sec
                bcs     DISKII_ERR ;Always taken

; CPM logical sector to physical disk sector number
CPM_TRAN_SECT:  .byte   $00,$03,$06,$09,$0c,$0f,$02,$05
                .byte   $08,$0b,$0e,$01,$04,$07,$0a,$0d
; Table of off timings for the stepper motor
OFFTABLE:       .byte   $70,$2c,$26,$22,$1f,$1e,$1d,$1c
                .byte   $1c,$1c,$1c,$1c,$1c
; Table for nibble conversion to disk
NIBL:           .byte   $96,$97,$9a,$9b,$9d,$9e,$9f,$a6
                .byte   $a7,$ab,$ac,$ad,$ae,$af,$b2,$b3
                .byte   $b4,$b5,$b6,$b7,$b9,$ba,$bb,$bc
                .byte   $bd,$be,$bf,$cb,$cd,$ce,$cf,$d3
                .byte   $d6,$d7,$d9,$da,$db,$dc,$dd,$de
                .byte   $df,$e5,$e6,$e7,$e9,$ea,$eb,$ec
                .byte   $ed,$ee,$ef,$f2,$f3,$f4,$f5,$f6
                .byte   $f7,$f9,$fa,$fb,$fc,$fd,$fe,$ff
                .byte   $00,$00,$00,$00,$00,$01
                .byte   $98,$99,$02,$03,$9c,$04,$05,$06
                .byte   $a0,$a1,$a2,$a3,$a4,$a5,$07,$08
                .byte   $a8,$a9,$aa,$09,$0a,$0b,$0c,$0d
                .byte   $b0,$b1,$0e,$0f,$10,$11,$12,$13
                .byte   $b8,$14,$15,$16,$17,$18,$19,$1a
                .byte   $c0,$c1,$c2,$c3,$c4,$c5,$c6,$c7
                .byte   $c8,$c9,$ca,$1b,$cc,$1c,$1d,$1e
                .byte   $d0,$d1,$d2,$1f,$d4,$d5,$20,$21
                .byte   $d8,$22,$23,$24,$25,$26,$27,$28
                .byte   $e0,$e1,$e2,$e3,$e4,$29,$2a,$2b
                .byte   $e8,$2c,$2d,$2e,$2f,$30,$31,$32
                .byte   $f0,$f1,$33,$34,$35,$36,$37,$38
                .byte   $f8,$39,$3a,$3b,$3c,$3d,$3e,$3f
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
WRITE16:        sec                ;Anticipate wrpot err.
                stx     SLOTZ      ;For zero page access.
                stx     SLOTABS    ;For non-zero page.
                lda     IWM_Q6_ON,x
                lda     IWM_Q7_OFF,x ;Sense wprot flag.
                bmi     WEXIT      ;If high, then err.
                lda     NBUF2
                sta     WTEMP      ;For zero-page access
                lda     #$ff       ;sync data.
                sta     IWM_Q7_ON,x ;(5) Write 1st nibl.
                ora     IWM_Q6_OFF,x ;(4)
                pha                ;(3)
                pla                ;(4) Critical timing!
                nop                ;(2)
                ldy     #$04       ;(2) for 5 nibls.
WSYNC:          pha                ;(3) Exact timing.
                pla                ;(4) Exact timing.
                jsr     WNIBL7     ;(13,9,6) Write SYNC
                dey                ;(2)
                bne     WSYNC      ;(2*) MUST NOT cross page!
                lda     #$d5       ;(2) 1st data mark.
                jsr     WNIBL9     ;(15,9,6)
                lda     #$aa       ;(2) 2nd data mark.
                jsr     WNIBL9     ;(15,9,6)
                lda     #$ad       ;(2) 3rd data mark.
                jsr     WNIBL9     ;(15,9,6)
                tya                ;(2) Clear checksum
                ldy     #$56       ;(2) NBUF2 index
                bne     WDATA1     ;(3) Always. No Page Cross!!

WDATA0:         lda     NBUF2,y    ;(4) Prior 6=bit nibl.
WDATA1:         eor     NBUF2-1,y  ;(5) XOR with current
; (NBUF2 MUST be on page boundary for timing!!)
                tax                ;(2) index to 7-bit nibl
                lda     NIBL,x     ;(4) Must not cross page!
                ldx     SLOTZ      ;(3) Critical timing!
                sta     IWM_Q6_ON,x ;(5) Write nibl.
                lda     IWM_Q6_OFF,x ;(4)
                dey                ;(2) Next nibl.
                bne     WDATA0     ;(2*) Must not cross page!
                lda     WTEMP      ;(3) Prior nibl from buf6.
                nop                ;(2) Critical timing.
WDATA2:         eor     NBUF1,y    ;(4) XOR NBUF1 nibl.
                tax                ;(2) Index to 7-bit nibl.
                lda     NIBL,x     ;(4)
                ldx     SLOTABS    ;(4) Timing critical
                sta     IWM_Q6_ON,x ;(5) Write nibl.
                lda     IWM_Q6_OFF,x ;(4)
                lda     NBUF1,y    ;(4) Prior 6-bit nibl.
                iny                ;(2) Next NBUF1 nibl.
                bne     WDATA2     ;(2*) Must not cross page!
                tax                ;(2) Last nibl as chksum
                lda     NIBL,x     ;(4) Index to 7-bit nibl.
                ldx     SLOTZ      ;(3)
                jsr     WNIBL      ;(6,9,6) Write checksum
                lda     #$de       ;(2) DM4, bit slip mark.
                jsr     WNIBL9     ;(15,9,6) Write it
                lda     #$aa       ;(2) DM5, bit slip mark.
                jsr     WNIBL9     ;(15,9,6) Write it
                lda     #$eb       ;(2) DM6, bit slip mark.
                jsr     WNIBL9     ;(15,9,6) Write it
                lda     #$ff       ;(2) Turn-off byte.
                jsr     WNIBL9     ;(15,9,6) Write it
                lda     IWM_Q7_OFF,x ;Out of write mode
WEXIT:          lda     IWM_Q6_OFF,x ;to read mode
                rts                ;Return from write

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
PRENIB16:       ldx     #$55       ;Clear out the two bit table
                lda     #$00
PRENIB1:        sta     NBUF2,x    ;Clear it
                dex
                bpl     PRENIB1    ;Loop until done
                tay                ;Zero counter
                ldx     #$ac       ;First time thru we need to more bits
                .byte   $2c        ;BIT instruction

PRENIB2:        ldx     #$aa       ;First time X is AC, Second time AA
PRENIB3:        dey
PRENIBPAGE:     lda     DISK_BUFF,y ;Get data byte
                lsr     A
                rol     NBUF1+86,x ;Rotate into two bit data
                lsr     A
                rol     NBUF1+86,x
                sta     NBUF1,y    ;Put left overs into six bit data
                inx
                bne     PRENIB3    ;Out of two bit data?
                tya
                bne     PRENIB2    ;Done all 256 bytes?
                rts

; **************************************
; * 7-BIT NIBL WRITE SUBRS  A-REG OR'D *
; * PRIOR EXIT CARRY CLEARED           *
; **************************************
WNIBL9:         clc                ;(2) 9 cycles, then write.
WNIBL7:         pha                ;(3) 7 cycles, then write.
                pla                ;(4)
WNIBL:          sta     IWM_Q6_ON,x ;(5) Nibl write sub.
                ora     IWM_Q6_OFF,x ;(4) Clobbers acc, not carry.
                rts

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
POSTNB16:       ldy     #$00       ;User data buf IDX.
POST1:          ldx     #$56       ;Init NBUF2 Index.
POST2:          dex                ;NBUF IDX $55 to $0
                bmi     POST1      ;Wrap around if neg.
                lda     NBUF1,y
                lsr     NBUF2,x    ;Shift 2 bits from
                rol     A          ;Current NBUF2 nibl
                lsr     NBUF2,x    ;into current NUBF1
                rol     A          ;nibl.
POSTNBPAGE:     sta     DISK_BUFF,y ;Byte of user data.
                iny                ;Next user byte.
                cpy     T0         ;Done if equal T0
                bne     POST2      ;Return.
                rts

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
MSWAIT:         ldx     #$11
MSW1:           dex                ;Delay 86 uSec.
                bne     MSW1
                inc     MONTIMEL
                bne     MSW2       ;Double-byte
                inc     MONTIMEH   ;increment.
                bne     MSW2
                dec     MONTIMEH   ;NOT SAME AS RWTS
MSW2:           sec
                sbc     #$01       ;Done 'N' intervals?
                bne     MSWAIT     ;(A-reg counts)
                rts

; This subroutine sets the slot dependent track location.
SETTRK:         pha                ;Preserve destination track
                lda     DISK_DRV
                rol     A          ;Get drive # into carry
                ror     DRIVNO     ;into (DRIVNO)
                jsr     SLOT_TO_Y  ;Setup Y-reg
                pla
                asl     A          ;Track is held * 2
                bit     DRIVNO
                bmi     ONDRV1     ;If on drive 1(1), DRIVNO minus 
                sta     DRV2TRK,y
                bpl     SETRTS

ONDRV1:         sta     DRV1TRK,y
SETRTS:         rts

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
READ16:         ldy     #$20       ;'Must find' count
RSYNC:          dey                ;If can't find marks
                beq     RDERR      ;Then exit with carry set.
READ1:          lda     IWM_Q6_OFF,x ;Read nibl.
                bpl     READ1      ;*** NO PAGE CROSS! ***
RSYNC1:         eor     #$d5       ;Data mark 1?
                bne     RSYNC      ;Loop if not.
                nop                ;Delay between nibls
READ2:          lda     IWM_Q6_OFF,x
                bpl     READ2      ;*** NO PAGE CROSS! ***
                cmp     #$aa       ;Data mark 2?
                bne     RSYNC1     ;(If not, is it DM1?)
                ldy     #$56       ;Init NBUF2 index.
; (added nibl delay)
READ3:          lda     IWM_Q6_OFF,x
                bpl     READ3      ;*** NO PAGE CROSS! ***
                cmp     #$ad       ;Data mark 3?
                bne     RSYNC1     ;(If not, is it DM1?)
; (Carry set if DM3!)
                lda     #$00       ;Init checksum
RDATA1:         dey
                sty     IDX
READ4:          ldy     IWM_Q6_OFF,x
                bpl     READ4      ;*** NO PAGE CROSS! ***
                eor     NIBL-82,y  ;XOR 6-bit nibl.
                ldy     IDX
                sta     NBUF2,y    ;Store in NBUF2 page
                bne     RDATA1     ;Taken if Y-reg nonzero.
RDATA2:         sty     IDX
READ5:          ldy     IWM_Q6_OFF,x
                bpl     READ5      ;*** NO PAGE CROSS! ***
                eor     NIBL-82,y  ;XOR 6-bit nibl.
                ldy     IDX
                sta     NBUF1,y    ;Store in NBUF1 page.
                iny
                bne     RDATA2
READ6:          ldy     IWM_Q6_OFF,x ;Read 7-bit csum nibl.
                bpl     READ6      ;*** NO PAGE CROSS! ***
                cmp     NIBL-82,y  ;If last NBUF1 nibl not
                bne     RDERR      ;equal chksum nibl then err.
READ7:          lda     IWM_Q6_OFF,x
                bpl     READ7      ;*** NO PAGE CROSS! ***
                cmp     #$de       ;First bit slip mark?
                bne     RDERR      ;(Err if not)
                nop                ;Delay between nibls.
READ8:          lda     IWM_Q6_OFF,x
                bpl     READ8      ;*** NO PAGE CROSS! ***
                cmp     #$aa       ;Second bit slip mark?
                beq     RDEXIT     ;(Done if it is)
RDERR:          sec                ;Indicate 'Error exit'
                rts                ;From READ16 or RDADR16

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
RDADR16:        ldy     #$fc
                sty     COUNT      ;'Must find' count
RDASYN:         iny
                bne     RDA1       ;Low order of count.
                inc     COUNT      ;(2K nibls to find
                beq     RDERR      ;adr mark, else err)
RDA1:           lda     IWM_Q6_OFF,x ;Read nibl.
                bpl     RDA1       ;*** NO PAGE CROSS! ***
RDASN1:         cmp     #$d5       ;Adr mark 1?
                bne     RDASYN     ;(Loop if not)
                nop                ;Nibl delay.
RDA2:           lda     IWM_Q6_OFF,x
                bpl     RDA2       ;*** NO PAGE CROSS! ***
                cmp     #$aa       ;Adr mark 2?
                bne     RDASN1     ;(If not, is it AM1?)
                ldy     #$03       ;Index for 4-byte read
; (Added nibl delay)
RDA3:           lda     IWM_Q6_OFF,x
                bpl     RDA3       ;*** NO PAGE CROSS! ***
                cmp     #$96       ;Adr mark 3?
                bne     RDASN1     ;(If not, is it AM1)
; (Leaves carry set!)
                lda     #$00
RDAFLD:         sta     CSUM       ;Init checksum
RDA4:           lda     IWM_Q6_OFF,x ;Read 'Odd bit' nibl.
                bpl     RDA4       ;*** NO PAGE CROSS! ***
                rol     A          ;Align odd bits, '1' into LSB.
                sta     LAST       ;Save for later
RDA5:           lda     IWM_Q6_OFF,x ;Read 'Even bit' nibl.
                bpl     RDA5       ;*** NO PAGE CROSS! ***
                and     LAST       ;Merge odd and even bytes
                sta     CSSTV,y    ;Store data byte
                eor     CSUM       ;XOR checksum
                dey
                bpl     RDAFLD     ;Loop on 4 data bytes
                tay                ;If final checksum
                bne     RDERR      ;Nonzero, then error.
RDA6:           lda     IWM_Q6_OFF,x ;Read trailing byte
                bpl     RDA6       ;*** NO PAGE CROSS! ***
                cmp     #$de
                bne     RDERR      ;Wrong, go home with a error
                nop
RDA7:           lda     IWM_Q6_OFF,x ;Error if no match
                bpl     RDA7       ;*** NO PAGE CROSS! ***
                cmp     #$aa
                bne     RDERR      ;Error if nonmatch
RDEXIT:         clc                ;Carry on
                rts                ;Normal read exits

;***************************************
;* THIS IS THE 'SEEK' ROUTINE          *
;* SEEKS TRACK 'N' IN SLOT #X/$10      *
;* IF DRIVNO IS NEGATIVE, ON DRIVE 1   *
;* IF DRIVNO IS POSITIVE, ON DRIVE 2   *
;***************************************
MYSEEK:         asl     A          ;Two phases per track
                jsr     MYSEEK2
                lsr     CURTRK     ;Divide back down
                rts

MYSEEK2:        sta     TRKN       ;Save destination track(*2)
                jsr     SLOT_TO_Y  ;Set Y=Slot #
                lda     DRV1TRK,y
                bit     DRIVNO
                bmi     WASD0      ;Is minus, on drive zero
                lda     DRV2TRK,y
WASD0:          sta     CURTRK     ;This is where I am
                lda     TRKN       ;and where I'm going to
                bit     DRIVNO     ;Now update slot dependent
                bmi     ISDRV1     ;locations with track
                sta     DRV2TRK,y  ;Information
                bpl     SEEK       ;Always taken

ISDRV1:         sta     DRV1TRK,y
SEEK:           stx     SLOTTEMP   ;Save X-reg
                sta     TRKN       ;Save target track
                cmp     CURTRK     ;On desired track
                beq     SEEKRTS    ;Yes return
                lda     #$00
                sta     TRKCNT     ;Half track count
SEEK2:          lda     CURTRK     ;save CURTRK for 
                sta     PRIOR      ;Delayed turnoff
                sec
                sbc     TRKN       ;Delta-tracks
                beq     SEEKEND    ;BR if CURTRK=DESTINATION
                bcs     OUT        ;(move out not in)
                eor     #$ff       ;Calc tracks to go
                inc     CURTRK     ;increment current track (IN)
                bcc     MINTST     ;(Always taken)

OUT:            adc     #$fe       ;Calc tracks to go
                dec     CURTRK     ;Decr current track (Out)
MINTST:         cmp     TRKCNT
                bcc     MAXTST     ;And 'trks moved'
                lda     TRKCNT
MAXTST:         cmp     #$0c
                bcs     STEP2      ;If TRKCNT>$B leave Y alone (Y=$B).
                tay                ;Else set acceleration index in Y
STEP2:          sec                ;Carry set=phase on
                jsr     SETPHASE   ;Phase on
                lda     ONTABLE,y  ;For 'on time'
                jsr     MSWAIT     ;(100 uSec intervals)
                lda     PRIOR
                clc                ;carry clear=phase off
                jsr     CLRPHASE   ;Phase off
                lda     OFFTABLE,y ;then wait 'off time'
                jsr     MSWAIT     ;(100 uSec intervals)
                inc     TRKCNT
                bne     SEEK2
; End of seeking
SEEKEND:        jsr     MSWAIT     ;A=0: Wait 25 mS settle
                clc                ;And turn off phase
; Turn head stepper phase on/off
SETPHASE:       lda     CURTRK     ;Get current phase
CLRPHASE:       and     #$03       ;Mask for 1 of 4 phases
                rol     A          ;Double for phase index
                ora     SLOTTEMP
                tax
                lda     IWM_PH0_OFF,x ;Flip the phase
                ldx     SLOTTEMP   ;Restore X-reg
SEEKRTS:        rts                ;And return

WRPROTERR:      lda     IWM_Q6_OFF,x ;Motor off
                lda     #$10       ;Flag write protect
                sec                ;Set carry and go home
                rts

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
WADR16:         lda     IWM_Q6_ON,x ;Into 'Wr prot sense' mode
                lda     IWM_Q7_OFF,x ;Sense it (NEG=protected)
                bmi     WRPROTERR  ;Error exit if protected.
                lda     #$ff       ;Self-sync nibl.
                sta     IWM_Q7_ON,x ;Write first nibl.
                cmp     IWM_Q6_OFF,x ;(4) back to write mode.
                pha                ;(3) for delay
                pla                ;(4)
WSYNC1:         jsr     WADRTS1    ;(12) For 40 uSec nibls.
                jsr     WADRTS1    ;(12)
                sta     IWM_Q6_ON,x ;(5) Write nibl.
                cmp     IWM_Q6_OFF,x ;(4) (back to write mode)
                nop                ;(2) For delay
                dey                ;(2) Next of 'N' nibls.
                bne     WSYNC1     ;(3) *** NO PAGE CROSS! ***
                lda     #$d5       ;(2) Adr Mark 1.
                jsr     WNIBL2     ;(15, 9, 6) Write it.
                lda     #$aa       ;(2) Adr Mark 2.
                jsr     WNIBL2     ;(15, 9, 6) Write it.
                lda     #$96       ;(2) 16-sector adr mark 3.
                jsr     WNIBL2     ;(15, 9, 6) Write it.
                lda     NVOL       ;(3)
                jsr     WBYTE      ;(14,9,6) Write NVOL (odd, then even bits.)
                lda     TRK        ;(3) Write track number
                jsr     WBYTE      ;(14,9,6) (odd, then even bits.)
                lda     NSECT      ;(3) Write sector number.
                jsr     WBYTE      ;(14,9,6) (odd, then even bits.)
                lda     NVOL       ;(3)
                eor     TRK        ;(3) Form adr field checksum.
                eor     NSECT      ;(3)
                pha                ;(3) Save for even bits
                lsr     A          ;(2) Align odd bits
                ora     AA         ;(3) Set clock bits.
; (Precise timing, 32 cycles per nibl)
                sta     IWM_Q6_ON,x ;(5) Write checksum odd bits.
                lda     IWM_Q6_OFF,x ;(4) back to write mode.
                pla
                ora     #$aa       ;(2) set clock bits.
                jsr     WNIBLA     ;(17, 9, 6) Write them.
                lda     #$de       ;End mark 1.
                jsr     WNIBL2     ;(15, 9, 6) Write it.
                lda     #$aa       ;End mark 2.
                jsr     WNIBL2     ;(15, 9, 6) Write it.
                lda     #$eb       ;End mark 3.
                jsr     WNIBL2     ;(15, 9, 6) 'Write turn off'
                clc                ;Indicate no Wr Prot Err.
                lda     IWM_Q7_OFF,x ;Out of write mode
                lda     IWM_Q6_OFF,x ;To read mode.
WADRTS1:        rts

;***************************************
;*                                     *
;* Wait time for motor to come up to   *
;* speed before starting to write to   *
;* disk, finishing off any time left   *
;* over.                               *
;*                                     *
;***************************************
MOTOF:          ldy     #$12       ;Delay 100 uSec per count
CONWAIT:        dey
                bne     CONWAIT
                inc     MONTIMEL
                bne     MOTOF
                inc     MONTIMEH
                bne     MOTOF      ;Count up to $0000
                rts

; 
; Write a byte routine during formatting in 4-4 format
;  
WBYTE:          pha                ;(3) Preserve for even bits.
                lsr     A          ;(2) align odd bits.
                ora     AA         ;(3) Set clock bits
                sta     IWM_Q6_ON,x ;(5) Write nibl.
                cmp     IWM_Q6_OFF,x ;(4)
                pla                ;(4) Recover even bits
                nop                ;(2)
                nop                ;(2) For delay
                nop                ;(2)
                ora     #$aa       ;(2) Set clock bits.
WNIBLA:         nop                ;(2) (17,9,6) Entry
WNIBL2:         nop                ;(2) (15,9,6) Entry
                pha                ;(3) For
                pla                ;(4) delay.
                sta     IWM_Q6_ON,x ;(5) Write nibl.
                cmp     IWM_Q6_OFF,x ;(4)
WBYTERTS:       rts                ;(6) Return

;***************************************
;*                                     *
;* Unused code anywhere in this BIOS   *
;* Looks like it searches for card     *
;* type                                *
;* in the slots, skipping slot 6.      *
;*                                     *
;***************************************
                ldx     #$07       ;Looks like this searches for a card type in Acc
D2NXTSLT:       cpx     #$06       ;Slot is 6
                beq     SKIPSL6    ;Skip it
                cmp     SLOT_INFO,x ;Found the card type we're looking for?
                beq     FOUNDCARD  ;Yes, rotate left....
SKIPSL6:        dex
                bne     D2NXTSLT   ;Next slot
                pla                ;Remove callers address
                pla
                jmp     SET_DISK_ERR1 ;Exit via error.

FOUNDCARD:      txa                ;Set acc to Slot * 16
                asl     A
                asl     A
                asl     A
                asl     A
                rts

; ProDOS logical sector to physical disk translation table
PD_SECT_TRAN:   .byte   $00,$02,$04,$06,$08,$0a,$0c,$0e
                .byte   $01,$03,$05,$07,$09,$0b,$0d,$0f

; ******************************
; *                            *
; *   WRITE TRACK SUBROUTINE   *
; *                            *
; ******************************
WTRACK16:       lda     #$00
                sta     NSECT      ;Sector number, 0 to 15
                ldy     #128       ;128 NIBs prior sector 0
                bne     WSECT0     ;To insure no blank spot betw 15 & 0

WSECT:          ldy     NSYNC      ;Current num of gap self-sync nibls
WSECT0:         jsr     WADR16     ;Write gap and adr field
                bcs     WBYTERTS   ;Err if write protected
                jsr     WRITE16
                nop                ;Was branch if write protected
                nop                ;in original RWTS code
                inc     NSECT      ;Next of 16 sectors
                lda     NSECT
                cmp     #$10
                bcc     WSECT      ;Continue if not done
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
                ldy     #$0f
                sty     NSECT      ;Set 16 bytes of
                lda     #$30       ;sector found table
                sta     RETRYCNT   ;to $30 (Mark them)
CLRFOUND:       sta     FOUND,y
                dey
                bpl     CLRFOUND
                ldy     NSYNC      ;Delay 50 uSec for every
S0DELAY:        jsr     WEXIT2     ;(12) Self sync nibl
                jsr     WEXIT2     ;(12) Expected to insure
                jsr     WEXIT2     ;(12) proper gap prior sector 0
                pha                ;(3) Note this code is possibly wrong 
                pla                ;(4) as the jsr is to the SEC
                nop                ;(2) rather the RTS in RWTS source
                dey                ;(2)
                bne     S0DELAY    ;(3)
                jsr     RDADR16    ;Read next address field
                bcs     S15LOC     ;Err, locate sect 15 and rewrite trk.
                lda     SECTOR     ;Was it sector 0
                beq     VDATA      ;Yes, now verify data field
                lda     #$10
                cmp     NSYNC      ;Decr NSYNC by 1 if less than
                lda     NSYNC      ;16, by 2 if not less
                sbc     #$01
                sta     NSYNC
                cmp     #$05       ;If less than 5, unrecoverable
                bcs     S15LOC     ;err, else rewrite after data fld 15
                bcc     VERR       ;Extremely fast or severe error

VSECT:          jsr     RDADR16    ;Read an address field
                bcs     VERR1      ;Retry if error
VDATA:          jsr     READ16     ;Read data field
                bcc     SECTOK     ;(Good)
VERR1:          dec     RETRYCNT   ;Next of 48 sector tries.
                bne     VSECT      ;(Keep trying)
S15LOC:         jsr     RDADR16    ;Read address field
                bcs     NOTS15     ;Err, try up to 128 times.
                lda     SECTOR     ;Sector that was read.
                cmp     #$0f       ;Sector 15?
                bne     NOTS15     ;No, continue searching
                jsr     READ16     ;Read data field
                bcc     WTRACK16   ;Write track from here if no err.
NOTS15:         dec     RETRYCNT   ;$FF to $7F, 128 tries.
                bne     S15LOC     ;Try for sect 15 again
VERR:           lda     #$01
WEXIT2:         sec                ;Set carry to indicate error
WEXIT3:         rts                ;Return to formatter

SECTOK:         ldy     SECTOR     ;This is sector read
                lda     FOUND,y    ;already found?
                bmi     VERR1      ;Yes, ignore it.
                lda     #$ff
                sta     FOUND,y    ;Indicate this sect now found
                dec     NSECT      ;Found 16 sectors?
                bpl     VSECT      ;No, look for next.
                lda     TRK
                bne     WEXIT1     ;If track and NSYNC > 16
                lda     NSYNC      ;(Num gap sync nibls)
                cmp     #$10       ;Then subtract 2 from NSYBC
                bcc     WEXIT3     ;To avoid retries on later trks.
                dec     NSYNC
                dec     NSYNC
WEXIT1:         clc                ;Indicate no error.
                rts                ;Return.

; ****************************
; *                          *
; *  FORMAT DISK AND RETURN  *
; *                          *
; ****************************
DSKFORM:        jsr     MOTOF      ;Wait for motor to come up to speed
                lda     DISK_VOL   ;Copy volume number
                sta     NVOL       ;For formatter
                lda     #$aa       ;Set z-pag loc to $AA for
                sta     AA         ;Time dependent references
                ldy     #$56
                lda     #$00       ;Track number, 0 to 34
                sta     TRK
                lda     #$2a       ;Clear NBUFS to write sectors
CLRNBUF2:       sta     NBUF2-1,y  ;Different values from RWTS
                dey
                bne     CLRNBUF2
                lda     #$39       ;$E5 shr 2 for empty CP/M directory 
CLRNBUF1:       sta     NBUF1,y
                dey
                bne     CLRNBUF1
                lda     #35        ;Set the max track to format
                sta     MAXTRK
                lda     #42
                jsr     SETTRK     ;Fake like on track 42
                lda     #$28
                sta     NSYNC      ;Begin with 40 self-sync nibls.
FORMTRK:        lda     TRK
                jsr     MYSEEK     ;Goto next track
                jsr     WTRACK16   ;Write and verify track
                bcs     FORMDONE   ;Error go home
                lda     #$30       ;Upto 48 sector retries
                sta     RETRYCNT   ;to find sector 0
FINDS0:         sec                ;Anticpate 'unable to format'
                dec     RETRYCNT   ;Done 48 retries?
                beq     FORMERR    ;If so, 'Unable to format' err.
                jsr     RDADR16    ;Read adr field
                bcs     FINDS0     ;Retry if err
                lda     SECTOR     ;Check sector that was read.
                bne     FINDS0     ;Continue searching if not sect 0
                jsr     READ16     ;Now read data field
                bcs     FINDS0     ;Continue search if err.
                inc     TRK        ;Increment track number
                lda     MAXTRK
                cmp     TRK        ;Continue if less than 25
                bne     FORMTRK
                lda     #$00       ;Return back success
                beq     FORMDONE

FORMERR:        lda     #$01
FORMDONE:       sta     DISK_ERR   ;FORMDONE
                lda     IWM_MOTOR_OFF,x
                rts

;***************************************
;*                                     *
;* Do a read or write on a whole track *
;*                                     *
;***************************************
D2TRACKOPER:    lda     #$00
                sta     DISK_SECT
                lda     PRENIBPAGE+2 ;Save data buffer page value for writes
                sta     D2SAVWRDTAPG
                lda     POSTNBPAGE+2 ;Save data buffer page value for reads
                sta     D2SAVRDDTAPG
                lda     DOSECTTRAN+1 ;Save CPM sector translate
                sta     D2SAVETRAN
                lda     DOSECTTRAN+2
                sta     D2SAVETRAN+1
                lda     #>PD_SECT_TRAN ;Swap to Prodos sector translate
                sta     DOSECTTRAN+2
                lda     #<PD_SECT_TRAN
                sta     DOSECTTRAN+1
                lda     DISK_TRK_ADDR ;Set up data pointers
                sta     PRENIBPAGE+2
                sta     POSTNBPAGE+2
D2TRKNXTSECT:   lda     #$02
                sta     RECALCNT
                lda     #$04
                sta     DRV2TRK
                lda     DISK_OP
                jsr     TRYTRK
                bcs     D2TRACKOPEX ;Had an error go home
                lda     IWM_MOTOR_ON,x ;Leave the motor running
                inc     PRENIBPAGE+2 ;Increment data pointer
                inc     POSTNBPAGE+2
                inc     DISK_SECT  ;Bounce sector
                inc     DISK_TRK_ADDR ;And the data pointer
                lda     #$10       ;Done a track?
                cmp     DISK_SECT
                bne     D2TRKNXTSECT ;Nope loop
                lda     IWM_MOTOR_OFF,x
D2TRACKOPEX:    lda     D2SAVWRDTAPG ;Put back data buffer pages for writes
                sta     PRENIBPAGE+2
                lda     D2SAVRDDTAPG ;Put back data buffer pages for reads
                sta     POSTNBPAGE+2
                lda     D2SAVETRAN ;Put back CPM sector translate
                sta     DOSECTTRAN+1
                lda     D2SAVETRAN+1
                sta     DOSECTTRAN+2
                rts

; Table of on timings for the stepper motor
ONTABLE:        .byte   $01,$30,$28,$24,$20,$1e,$1d,$1c
                .byte   $1c,$1c,$1c,$1c
; Get the current slot number into Y
SLOT_TO_Y:      lda     DISKSLOTCX ;Get slot number *16
                lsr     A          ;Divide by 16
                lsr     A
                lsr     A
                lsr     A
                tay                ;Put Acc into Y
                rts

; What sort of not Disk ][ is it?
IDC_CHECK:      cmp     #$07       ;What sort of drive?
                beq     SMARTDRV_FOUND ;Smartdrive is for RAM drives
                jmp     PRODOS

;*******************************************************************************
;* SmartDrive code                                                             *
;*******************************************************************************
SMARTDRV_FOUND: txa                ;Convert to CX
                ora     #$c0
                sta     SMARTDRV_CALL+2 ;Save slot rom into call high
                sta     GET_SMARTDRV_ADDR+2 ;Save slot rom to get entry point
GET_SMARTDRV_ADDR:
                lda     SCC_INIT-1 ;Get the entry point
                clc
                adc     #$03       ;Add 3 to get smartdrive point
                sta     SMARTDRV_CALL+1 ;Update the call low byte
                lda     DISK_OP
                beq     SET_DISK_ERR1 ;Status returns error $01
                cmp     #$03       ;Read or write
                bcc     SMART_CMDOK ;Yep carry on
SET_DISK_ERR1:  ldx     #$01       ;Set disk error to 1 (bad cmd)
                bne     SET_DISK_ERRX

SMART_CMDOK:    adc     #$07       ;Change from Block to byte command
                sta     SMARTDRV_CMD
; For the smart drive address to read is
; (TRACKH*$100+TRACKL) * $10 + SECT*2
                asl     DISK_SECT  ;8 sectors per track
                lda     DISK_TRKL
                ldy     #$04       ;Shift left 4 times (aka mult by 16)
SMART_MUL:      asl     A
                rol     DISK_TRKH
                dey
                bne     SMART_MUL
                ora     DISK_SECT  ;Or in the sector
                sta     SMARTDRV_BLOCKNUM+1 ;Save blocknumber into parameters
                lda     DISK_TRKH
                sta     SMARTDRV_BLOCKNUM+2
SMARTDRV_CALL:  jsr     $0000
SMARTDRV_CMD:   .byte   $08
                .word   SMARTDRV_PARAM

PD_CHECK_ERR:   ldx     #$00       ;Everything happy
                bcc     SET_DISK_ERRX ;Yeah store success and return
                inx                ;Nope setup for a error
                cmp     #$2b       ;Write protected error?
                bne     SET_DISK_ERRX ;Lets say it's generic error
                ldx     #$10       ;Write protect error
SET_DISK_ERRX:  stx     DISK_ERR
                rts

;*******************************************************************************
;* Prodos driver code                                                          *
;*******************************************************************************
PRODOS:         txa
                ora     #$c0
                sta     PD_CALL_DRIVER+2 ;Patch up the driver call
                sta     PD_GET_ENTRY+2 ;Patch the call to find the driver entry
PD_GET_ENTRY:   lda     SCC_INIT-1 ;Get the entry point
                sta     PD_CALL_DRIVER+1 ;Patch the call
                lda     DISK_DRV
                sta     PRODOS_UNITNUM
                lda     DISK_OP    ;Status commmand? Return eror
                beq     SET_DISK_ERR1
                cmp     #$04       ;Greater than 3 not simple.
                bcs     PD_MULT_SECT_OP
                pha
                jsr     TRKSEC2PD_BLK ;Convert track / sector to ProDosBloc
                pla
PD_ALT_CALL:    sta     PRODOS_CMD ;Copy the command over
                lda     #$00
                sta     PRDOOS_BUFPTRL ;Buffer is at $800
                lda     #$08
                sta     PRDOOS_BUFPTRL+1
PD_CALL_DRIVER: jsr     $0000
                jsr     PD_CHECK_ERR
                bcs     PD_EXIT    ;Did we have an error?
                lda     PRODOS_CMD
                cmp     #$03       ;Was it initialise?
                beq     PD_INIT_DATA ;Do the rest of the track
PD_EXIT:        rts

PD_INIT_DATA:   lda     #$18       ;Looks like this skips the first three tracks
                sta     DISK_SECT
PD_INIT_WR:     lda     #$00       ;Zero the high block
                sta     PRODOS_BLKNUM+1
                lda     DISK_SECT  ;Which block to write
                sta     PRODOS_BLKNUM
                lda     #$02       ;Setup for a write
                jsr     PD_ALT_CALL ;Write out sector
                bcs     PD_EXIT    ;Error go home
                inc     DISK_SECT  ;Next sector
                dec     DISK_TRKL  ;Until the counter =0
                bne     PD_INIT_WR
                rts

;*******************************************************************************
;* We get here if the command is greater than or equal to four.                *
;* Normal ProDOS commands are                                                  *
;* 0 - Status                                                                  *
;* 1 - Read                                                                    *
;* 2 - Write                                                                   *
;* 3 - Init                                                                    *
;* Extended commands (read / write a whole track)                              *
;* 4 - gets translated as (4-3)^3 so to a 2 - Write                            *
;* 5 - gets translated as (5-3)^3 so to a 1 - Read                             *
;* 6 - gets translated as (6-3)^3 so to a 0 - status                           *
;*******************************************************************************
PD_MULT_SECT_OP:
                sec                ;Do the conversion
                sbc     #$03
                eor     #$03
                sta     PRODOS_CMD ;Set the command
                lda     #$08       ;Whole track?
                sta     PD_TRACK_OP_CNT
                lda     DISK_TRK_ADDR ;Get disk data pointer
                sta     PRODOS_BUFPTRH
                lda     #$00
                sta     DISK_SECT  ;We're doing the whole track
                sta     PRDOOS_BUFPTRL
                jsr     TRKSEC2PD_BLK ;Convert to PD block
PD_TRACK_OP_LOOP:
                jsr     PD_CALL_DRIVER
                bcs     PD_EXIT    ;Flag we had an error
                inc     DISK_TRK_ADDR ;Add 512 bytes to destination / source
                inc     DISK_TRK_ADDR
                inc     PRODOS_BLKNUM ;Bounce the block number along
                bne     PD_BLK_NO_WRAP
                inc     PRODOS_BLKNUM+1
PD_BLK_NO_WRAP: inc     NSYNC      ;Do the ProDOS address
                inc     NSYNC
                dec     PD_TRACK_OP_CNT ;Do the loop
                bne     PD_TRACK_OP_LOOP
                rts

TRKSEC2PD_BLK:  lda     DISK_TRKH  ;Prodos block is TRACK*8 + SECT
                sta     PRODOS_BLKNUM+1
                lda     DISK_TRKL
                ldx     #$03
BLK_MULT_2:     asl     A          ;Multiply by two
                rol     PRODOS_BLKNUM+1
                dex
                bne     BLK_MULT_2
                ora     DISK_SECT  ;Add sector
                sta     PRODOS_BLKNUM
                rts

SMARTDRV_PARAM: .byte   $04
SMARTDRV_UNITNUM:
                .byte   $01
SMARTDRV_BUFPTR:
                .word   $0800
SMARTDRV_NUMBYTES:
                .word   $0200
SMARTDRV_BLOCKNUM:
                .byte   $00
                .byte   $00
                .byte   $00
PD_TRACK_OP_CNT:
                .byte   $00
                .res    83,$00

;*******************************************************************************
;* Character mode device BIOS.                                                 *
;* These get copied out of $DC00 into $0A00                                    *
;* They also get copied into the other bank of memory                          *
;* On entry:                                                                   *
;* A EQU Character to read / write OR                                           *
;*      0EQU Output status check                                                *
;*      1EQU Input status check                                                 *
;* X EQU Device slot                                                            *
;*  0 EQU Console                                                               *
;*  1..7 Slot number                                                           *
;*  $80   Toggle cursor on off                                                 *
;* Y EQU operation                                                              *
;*  $0DEQU Init                                                                 *
;*  $0EEQU Read character                                                       *
;*  $0FEQU Write character                                                      *
;*  $10EQU Get status                                                           *
;*******************************************************************************
                .org    $0a00
                cld                ;Clear decimal mode
                pha                ;Put acc on stack
                txa                ;Which slot / what are doing?
                bne     CHECK_CUR_TOG ;Output to console?
                bit     LCBANK1    ;Yes, page in video BIOS in language card
                bit     LCBANK1
                jmp     PRINT_STACK_CHAR ;Put top of stack onto screen

CHECK_CUR_TOG:  bpl     DO_SLOT_IO ;Slot number positive
                bit     LCBANK1    ;Nope, so page in video BIOS
                bit     LCBANK1
                jmp     TOG_CURJMP ;And toggle the cursor

; See what sort of card is in the slot
DO_SLOT_IO:     stx     PAGEINROM2+1 ;Setup for paging in rom
                lda     SLOT_INFO,x ;Get the card type
                and     #$0f       ;Mask to low nybble
                pha                ;Save it for later
                txa                ;Multiply slot number by 8
                asl     A
                asl     A
                asl     A
                asl     A
                tax                ;XEQU Slot number * 8
                pla
                cmp     #$03       ;Apple Comms or CCS7710A
                beq     COMMS6550
                cmp     #$04       ;High speed serial
                beq     SSC
                cmp     #$05       ;Parallel printer
                beq     APPLEPARA
                cmp     #$06       ;Pascal based card
                beq     PASCALCARD
                pla                ;Remove actual character
                bne     CHAR_RET_0 ;Go home
; 
; Pascal card
;  
PASCALCARD:     pla                ;Get back the character
                cpy     #CHAR_OP_RD ;Read operation?
                beq     DOPASCAL_OP ;Go Do it
                cpy     #CHAR_OP_WR ;Write operation
                beq     DOPASCAL_OP ;Go Do it
                cpy     #CHAR_OP_INI ;Init operation?
                beq     DOPASCAL_OP ;Go Do it
                cpy     #CHAR_OP_ST ;Status operation?
                bne     CHAR_RET_0 ;Lie and return OK
                jsr     DOPASCAL_OP ;Go do our operation
                bcs     CARDRETFF  ;Result is No
                bcc     CHAR_RET_0 ;Result is Yes

DOPASCAL_OP:    sty     GETPASENTRY+1 ;Save offset of pascal entry
                pha                ;Save Acc
                jsr     PAGEINROM  ;Page in $C800 ROM 
                stx     GETPASENTRY+2 ;Save Cx00 into get offset instruction
                stx     JMPPASENTRY+2 ;Save Cx00 into call to card
GETPASENTRY:    lda     $c100      ;Get the offset of the operation
                sta     JMPPASENTRY+1 ;Save it into jump to pascal operation
                pla                ;Get back character
JMPPASENTRY:    jmp     $c100      ;Go call card routine

; 
; Apple Parallel card code
;  
APPLEPARA:      pla                ;Get back the character
                cpy     #CHAR_OP_INI ;No initialise routine
                beq     CARDRETFF  ;So go home
                cpy     #CHAR_OP_ST ;Get status
                beq     PARA_STATUS ;Go do it
                cpy     #CHAR_OP_WR ;CHAR_OP_WR
                bne     CHAR_RET_0 ;Do the write
                pha                ;Save character
PARASTLOOP:     jsr     PARA_STATUS ;Check status
                beq     PARASTLOOP ;Wait until clear
                pla                ;Get back character
                sta     PARA_DATAOUT,y ;Output the character to card
                rts                ;Go home

PARA_STATUS:    jsr     PAGEINROM  ;Page in the rom (sets X)
                stx     GETPARASTAT+2
GETPARASTAT:    lda     PARA_ACKIN ;Get the status
                bmi     CHAR_RET_0 ;Busy?
CARDRETFF:      lda     #$ff       ;Nope
                rts

; 
; Super serial card code, calls pascal entry points directly
;  
SSC:            pla                ;Get back character
                cpy     #CHAR_OP_ST ;Status
                beq     CARDRETFF  ;Return good always
                cpy     #CHAR_OP_INI ;Init?
                beq     JSRSCCINIT ;Go do it
                cpy     #CHAR_OP_WR ;Write?
                beq     JSRSCCWRITE ;Go do it
                cpy     #CHAR_OP_RD ;Read a character
                beq     JSRSSCREAD ;Go do it
CHAR_RET_0:     lda     #$00
                rts

; 
; 6650 based serial comms card
; CCS7710 or Apple Communications
;  
COMMS6550:      pla
                cpy     #CHAR_OP_ST ;Status operation
                beq     STATUS6550
                cpy     #CHAR_OP_WR ;Write operation
                beq     WRITE6550
                cpy     #CHAR_OP_INI ;Initialise
                beq     INIT6550
                cpy     #CHAR_OP_RD ;Read operation
                bne     CHAR_RET_0
RD6550WAIT:     lda     #$01       ;Wait for read data
                jsr     STATUS6550
                beq     RD6550WAIT ;Nothing yet
                lda     DATA6510,x ;Get our data
                lda     #$ff       ;And over write it!!!!
                rts

WRITE6550:      pha                ;Save character
WR6550WAIT:     lda     #$00       ;Check write status
                jsr     STATUS6550
                beq     WR6550WAIT ;Wait until we can write
                pla                ;Get character back
                sta     DATA6510,x ;Send it
                lda     #$ff
                rts

STATUS6550:     tay                ;Read or write status
                lda     STATUS6510,x ;Get status reg
                lsr     A          ;Shift into carry
                dey                ;Read data?
                beq     ST6550FLAG ;Yep, use bit 0
                lsr     A          ;Check bit 1 for write
ST6550FLAG:     bcc     CHAR_RET_0 ;Set flag depending on carry
                bcs     CARDRETFF

INIT6550:       lda     #$03       ;ACIA master reset
                sta     STATUS6510,x
                lda     #$15       ;8 bit data, no parity, 1 stop, clock is 16x
                sta     STATUS6510,x
                bne     CARDRETFF

JSRSSCREAD:     jsr     PAGEINROM  ;Bring in the SSC ROM
                jsr     SSC_READ   ;Read a character
                lda     STSBYTE,x  ;Get the character
                rts

JSRSCCWRITE:    pha
                jsr     PAGEINROM  ;Bring in the SSC ROM
                pla
                sta     STSBYTE,x  ;Save character to write
                jmp     SSC_WRITE  ;Call write routine

JSRSCCINIT:     jsr     PAGEINROM  ;Bring in the SSC ROM
                jmp     SCC_INIT   ;Call the init routine

PAGEINROM:      stx     SCRNHOLE5  ;Mark us as using rom space
                txa
                tay
PAGEINROM2:     lda     #$00       ;Value over written by other code
                ora     #$c0       ;Put into correct IO space
                tax
                stx     READROMSLOT+2 ;Set up for a read from the ROM
                bit     CLRROM     ;Clear any other ROMS in $C800
READROMSLOT:    lda     $c100      ;Read from our rom to bring in $C800
                rts

                .res    230,$1a
