*-----------------------------------------------------------
* Title      : JSR CODE
* Written by : Brad Minogue
* Date       : 11/19/2014
* Description: JSR Code for OP
*-----------------------------------------------------------
    ORG    $1000
START: 
    MOVE.L (SAMPLE_INPUT),D2    ;Load up sample input
    MOVE.L D2,D1                ;copy the data so we don't ruin it
    LSR #6,D1                   ;erase the EA
    CMP.L JSR_VALUE, D1         ;see if we are JSR
    BNE END_SEG                 ;if not end this segment
    
    LEA JSR_TEXT,A1             ;print out JSR
    MOVE.B #14, D0
    TRAP #15
    
    LEA EA_TEXT,A1              ;this is where we hand off to EA
    MOVE.B #14,D0
    TRAP #15
END_SEG    SIMHALT             ; halt simulator

SAMPLE_INPUT DC.L $4E91
JSR_VALUE DC.L $13A
JSR_TEXT DC.B 'JSR',0
EA_TEXT DC.B ' EA',0
    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
