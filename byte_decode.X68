*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
    MOVE.B  #$F3,D1
    
    LSR     #7,D1
    
    MOVE.B  #$F3,D1
    
    LSL.B     #1,D1
    LSR.B     #7,D1

    MOVE.B  #$F3,D1
    
    LSL.B     #2,D1
    LSR.B     #7,D1
    
    MOVE.B  #$F3,D1
    
    LSL.B     #3,D1
    LSR.B     #7,D1

    MOVE.B  #$F3,D1
    
    LSL.B     #4,D1
    LSR.B     #7,D1
    
    MOVE.B  #$F3,D1
    
    LSL.B     #5,D1
    LSR.B     #7,D1
    
    MOVE.B  #$F3,D1
    
    LSL.B     #6,D1
    LSR.B     #7,D1
    
    MOVE.B  #$F3,D1
    
    LSL.B     #7,D1
    LSR.B     #7,D1
    
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
