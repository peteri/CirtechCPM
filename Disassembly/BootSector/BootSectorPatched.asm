;
; Quick and dirty 6502 code to boot the Cirtech disk
; Use it to load the 6502 code into the language card
; and the CPMLDR into the main memory at $1100 from the
; first three tracks on disk.
; Assemble with https://www.masswerk.at/6502/assembler.html
; Paste hex file into Apple //e monitor and run with 6000G
;
  * = $6000 
; Copy the boot rom and patch out the JMP $801
; Use $9600 as that's the traditional 4am point.
    LDY #0
ROMLOOP: 
    LDA $C600,Y
    STA $9600,Y
    INY
    BNE ROMLOOP
;Patch out 801 call
    LDA #<FIRSTSECT
    STA $96F9
    LDA #>FIRSTSECT
    STA $96FA
    JMP $9600
; Come here after rom has loaded the first sector
; Patch the OR $C0 to point to us instead
FIRSTSECT: 
    LDA #$90
    STA $080B
    LDA #<SECONDSECT   ; Setup our jump
    STA $96F9   ; To point to our second sector routine
    LDA #>SECONDSECT
    STA $96FA
    JMP $801
; Come back to here after the second sector has loaded.
; Undo our changes so far and use the ROM.
; but we patch the jump into starting the Z80 to come back to us.
SECONDSECT:
    LDA #$C0 ; Put back the OR
    STA $80B
    LDA #$C6 ; Put back the ROM
    STA $891
    LDA #<COPYLANG  ;Jump to us after loading
    STA $90B        ;the first three tracks.
    LDA #>COPYLANG
    STA $90C
    JMP $801
; Copy the contents of the language card code
; into somewhere ($4000) we can get to it.
COPYLANG:
    LDA $C0E8	; Turn off drive motor
    LDA #$00    ; Setup source address
    STA $10
    LDA #$D0
    STA $11
    LDA #$00    ; Setup destination
    STA $12
    LDA #$40
    STA $13
; Copy the language card
    LDX #$10
    LDY #0
LOOP1: 
    LDA ($10),Y ; Copy those bytes
    STA ($12),Y
    INY
    BNE LOOP1   ; Done a page?
    INC $11     ; Increment the pointers
    INC $13
    DEX
    BNE LOOP1
    LDA $C081 ; Put back the ROM
    JSR $C300 ; Init the 80 column card
    JMP $FF65 ; Jump into the monitor ROM.