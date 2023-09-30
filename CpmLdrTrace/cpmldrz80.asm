1100: 31 81 12 ld   sp,$1281    ;lxi	sp,stackbot
;first call is to Cold Boot
1103: CD 00 1B call $1B00   ;call	bootf
;Initialize the System
1106: 0E 0D    ld   c,$0D   ;mvi	c,resetsys
1108: CD 8D 12 call $128D   ;call	bdos
;print the sign on message
110B: 0E 09    ld   c,$09   ;mvi	c,printbuf
110D: 11 25 12 ld   de,$1225;lxi	d,signon
1110: CD 8D 12 call $128D   ;call	bdos
