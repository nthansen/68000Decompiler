*-----------------------------------------------------------
* Title      :  LEA Decompiler code
* Written by :  Brad Minogue
* Date       :  12/2/14
* Description:  Decompiles LEA Code
*-----------------------------------------------------------
    ORG    $1000
START:                  
    MOVE.L (LEA_VALUE),D1       ;load up what we see as LEA
    MOVE.L (SAMPLE_VALUE),D3    ;load up sample data
    MOVE.L D3,D2                ;copy it
    AND.L D1,D3                 ;bitmask the useless data in the input
    CMP.L D1,D3                 ;see if the remaindg data is LEA
    BNE END_SEG                 ;if not end this
    
    MOVE.L D2,D1                ;copy back
    LSL #4,D1                   ;move data around so only
    LSR #8,D1                   ;the register remains
    LSR #5,D1
    
    LEA LEA_TEXT,A1             ;print out LEA
    MOVE #14,D0
    TRAP #15  
    
    LEA EA_TEXT,A1              ;print out EA
    MOVE #14,D0                 ;aka hand off here
    TRAP #15  

    LEA REG_TEXT,A1             ;print out A
    MOVE #14,D0                 ;we know that An is going to be here
    TRAP #15    
    
    EXT.L D1                    ;print out what address reg we are in
    MOVE.B #3,D0
    TRAP #15   
END_SEG    SIMHALT
LEA_VALUE DC.L $41C0
SAMPLE_VALUE DC.L $41F9
LEA_TEXT DC.B 'LEA ',0
REG_TEXT DC.B ',A',0
EA_TEXT DC.B 'EA',0
    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
