*-----------------------------------------------------------
* Title      : NOP Decompiler
* Written by : Brad Minogue
* Date       : 11/18/2014
* Description: Decompiles NOP input
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

    LEA SAMPLE_INPUT, A1        ;load sample data
    MOVE.L (A1),D1              ;move sample data to directory

    CMP.L NOP_VALUE, D1         ;check to see if we are NOP
    BNE END_SEG                 ;if not just end this
    
    LEA NOP_TEXT, A1            ;print out NOP
    MOVE.B #14, D0
    TRAP #15
    
END_SEG    SIMHALT             ; halt simulator

* Put variables and constants here
SAMPLE_INPUT DC.L $4E71
SAMPLE_INPUT_2 DC.L $8710
NOP_VALUE DC.L $4E71
NOP_TEXT DC.B 'NOP',0
    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
