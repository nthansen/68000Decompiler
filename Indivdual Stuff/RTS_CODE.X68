*-----------------------------------------------------------
* Title      : RTS Code for OP
* Written by : Brad Minogue
* Date       : 11/19/2014
* Description: RTS Code
*-----------------------------------------------------------
    ORG    $1000
START:                  
    MOVE.L (SAMPLE_INPUT),D1    ;load up sample input   
                                ;no need to copy data as usual no modifications
    CMP.L RTS_VALUE, D1         ;see if we are a RTS instruction
    BNE END_SEG                 ;if not end this

    LEA RTS_TEXT,A1             ;print out RTS
    TRAP #15
END_SEG    SIMHALT             ; halt simulator

SAMPLE_INPUT DC.L $4E75
RTS_VALUE DC.L $4E75
RTS_TEXT DC.L 'RTS',0
    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
