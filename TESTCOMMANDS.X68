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
    
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
