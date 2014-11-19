*-----------------------------------------------------------
* Title      : OR
* Written by : Brad Minogue
* Date       :
* Description: decodes move
*-----------------------------------------------------------
    ORG    $1000
START:                  
    LEA SAMPLE_INPUT, A1        ;load sample data
    MOVE.L (A1),D1              ;move sample data to directory
    MOVE.L D1,D2                ;Copy data
    LSR #4,D1                   ;Keep moving the bit over untill we get what we want only
    LSR #4,D1                   ;we only care about the first 4 bits so everything else
    LSR #4,D1                   ;is worthless
    CMP.L #8,D1                 ;see if we are OR
    BEQ OR_SEG                  ;start decompiling OR
    
OR_SEG  LEA OR_OUT,A1           ;print OR
    MOVE.B  #14,D0                  
    TRAP    #15
    MOVE.L D2,D1                ;Copy data    
    LSL #4, D1                  ;here we are getting rid of all didgets except
    LSL #3, D1                  ;the OP Mode information
    LSR #4, D1
    LSR #3, D1
    LSR #4, D1
    LSR #2, D1
    CMP.B BYTE_VAL_ONE, D1      ;these two compares tell if we are a byte mode
    BEQ BYTE_PRINT
    CMP.B BYTE_VAL_TWO, D1 
    BEQ BYTE_PRINT
    
    CMP.B LONG_VAL_ONE, D1      ;thse two compares tell if we are in a long mode
    BEQ LONG_PRINT
    CMP.B LONG_VAL_TWO, D1
    BEQ LONG_PRINT
    
    CMP.B WORD_VAL_ONE, D1      ;these two compares tell if we are in a word mode
    BEQ WORD_PRINT
    CMP.B WORD_VAL_TWO, D1
    BEQ WORD_PRINT
REG_SEG MOVE.L D2,D1            ;get back the orgional data so we can see
    LSL #4, D1                  ;what register we are in
    LSL #3, D1
    LSR #4, D1
    LSR #3, D1
    LSR #6, D1
    
    LEA D_TEXT, A1              ;print out
    MOVE.B #14,D0
    TRAP #15
    
    EXT.L   D1                   ;load up results
    MOVE.B  #3,D0                ;loading
    TRAP    #15                  ;displaying
    
    LEA COMMA_SPACE, A1          ;set up for the effective address
    MOVE.B #14,D0
    TRAP #15
    BRA END_STEP
BYTE_PRINT  LEA BYTE_TEXT,A1     ;print B
    MOVE.B  #14,D0                  
    TRAP    #15
    BRA REG_SEG
LONG_PRINT  LEA LONG_TEXT, A1    ;print L
    MOVE.B #14,D0
    TRAP #15
    BRA REG_SEG
WORD_PRINT  LEA WORD_TEXT, A1   ;print W
    MOVE.B #14,D0
    TRAP #15
    BRA REG_SEG
END_STEP  LEA EXIT_STATEMENT, A1    ;print our end statement
    MOVE.B #14,D0
    TRAP #15
    SIMHALT             ; halt simulator
* Put variables and constants here
SAMPLE_INPUT DC.L $8040
OR_OUT DC.B 'OR.',0
BYTE_VAL_ONE DC.B $0
BYTE_VAL_TWO DC.B $4
WORD_VAL_ONE DC.B $1
WORD_VAL_TWO DC.B $5
LONG_VAL_ONE DC.B $2
LONG_VAL_TWO DC.B $6
BYTE_TEXT DC.B 'B',0
LONG_TEXT DC.B 'L',0
WORD_TEXT DC.B 'W',0
D_TEXT DC.B ' D(or imidiate)',0
COMMA_SPACE DC.B ', ', 0
EXIT_STATEMENT DC.B ' hand off to address mode', 0
    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
