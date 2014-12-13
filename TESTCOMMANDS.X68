*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
WORD    EQU $0BCD
LONG    EQU $1234ABCD

    ORG    $4000
START:                  ; first instruction of program


*    NEG.B   D1
*    NEG.W   D4
*    NEG.L   D6
*    
*    ORI.B   #$FF,D6
*    ORI.W   #$A134,D3
*    ORI.L   #$1435DCDA,D4
*    
*    CMPI.B  #$AA,D2
*    CMPI.W  #$B432,D3
*    CMPI.L  #$ABCD1234,D7
*    
*    RTS
*    NOP
*    JSR (A1)
*    JSR WORD
*    JSR LONG
*    
*    LEA (A3),A7
*    
*    BCLR #$5,D1             ; Static
*    BCLR #$8,(A4)           ; Static
*    
*    BCLR D6,(A7)            ; Dynamic
*    
*    MOVE.B  D4,D3
*    MOVE.B  (A3),(A4)
*    MOVE.B  D5,(A1)
*    MOVE.B  #$BC,D1
*    MOVE.B  #$11,(A4)
*    
*    MOVE.W  D4,D3
*    MOVE.W  (A3),(A4)
*    MOVE.W  D5,(A1)
*    MOVE.W #$A134,D6
*    
*    MOVEA.W #$134,A4
*    MOVEA.W #$A134,A4
*    MOVEA.W #$A34,A4 
*    
*    MOVE.L  D4,D3
*    MOVE.L  (A3),(A4)
*    MOVE.L  D5,(A1)
*    MOVE.L #$A134,D6
*    
*    MOVEA.L #$134,A4
*    MOVEA.L #$FFFFA134,A4
*    MOVEA.L #$A34,A4    
*    
*    ASL (A1)
*    ASR (A1)
*
*    LSL (A1)
*    LSR (A1)
*    
*    ROL (A1)
*    ROR (A1)
    
    ASL.B D1,D2
    ASL.W D2,D3
    ASL.L D4,D5
    
    ASR.B D1,D2
    ASR.W D2,D3
    ASR.L D4,D5
    
    ASL.B #1,D2
    ASL.W #2,D3
    ASL.L #8,D5
    
    ASR.B #4,D2
    ASR.W #5,D3
    ASR.L #8,D5
    
    LSL.B D1,D2
    LSL.W D2,D3
    LSL.L D4,D5
    
    LSR.B D1,D2
    LSR.W D2,D3
    LSR.L D4,D5
    
    LSL.B #1,D2
    LSL.W #2,D3
    LSL.L #8,D5
    
    LSR.B #4,D2
    LSR.W #5,D3
    LSR.L #8,D5
    
    ROL.B D1,D2
    ROL.W D2,D3
    ROL.L D4,D5
    
    ROR.B D1,D2
    ROR.W D2,D3
    ROR.L D4,D5
    
    ROL.B #1,D2
    ROL.W #2,D3
    ROL.L #8,D5
    
    ROR.B #4,D2
    ROR.W #5,D3
    ROR.L #8,D5
    
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source










*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
