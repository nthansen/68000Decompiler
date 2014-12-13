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


    NEG.B   D1
    NEG.W   D4
    NEG.L   D6
    
    ORI.B   #$FF,D6
    ORI.W   #$A134,D3
    ORI.L   #$1435DCDA,D4
    
    CMPI.B  #$AA,D2
    CMPI.W  #$B432,D3
    CMPI.L  #$ABCD1234,D7
    
    RTS
    NOP
    JSR (A1)
    JSR WORD
    JSR LONG
    
    LEA (A3),A7
    
    BCLR #$5,D1             ; Static
    BCLR #$8,(A4)           ; Static
    
    BCLR D6,(A7)            ; Dynamic
    
    MOVE.B  D4,D3
    MOVE.B  (A3),(A4)
    MOVE.B  D5,(A1)
    MOVE.B  #$BC,D1
    MOVE.B  #$11,(A4)
    
    MOVE.W  D4,D3
    MOVE.W  (A3),(A4)
    MOVE.W  D5,(A1)
    MOVE.W #$A134,D6
    
    MOVEA.W #$134,A4
    MOVEA.W #$A134,A4
    MOVEA.W #$A34,A4 
    
    MOVE.L  D4,D3
    MOVE.L  (A3),(A4)
    MOVE.L  D5,(A1)
    MOVE.L #$A134,D6
    
    MOVEA.L #$134,A4
    MOVEA.L #$FFFFA134,A4
    MOVEA.L #$A34,A4    
    
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
