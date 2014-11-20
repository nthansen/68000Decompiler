*-----------------------------------------------------------
* Title      : OR decompile code
* Written by : Brad Minogue
* Date       : 11/18/14
* Description: Decomples OR input
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
    LEA SAMPLE_INPUT, A1        ;load sample data
    MOVE.L (A1),D1              ;move sample data to directory
    MOVE.L D1,D2                ;Copy data
    LSR #4,D1                   ;Keep moving the bit over untill we get what we want only
    LSR #4,D1                   ;we only care about the first 4 bits so everything else
    LSR #4,D1                   ;is worthless
    CMP.L #8,D1                 ;see if we are OR
    BNE END_SEG                 ;start decompiling OR

    LEA OR_TEXT,A1              ;We found that this is indeed OR so print it out
    MOVE.B #14,D0               ;we also know that a . will follow regardless of 
    TRAP #15                    ;if the origional code specified
    MOVE.L D2,D1

    LSL #4, D1                  ;here we are getting rid of all didgets except
    LSL #3, D1                  ;the OP Mode information
    LSR #4, D1                  ;after errasing the mode and register shift it back
    LSR #3, D1                  ;for future calculations
    LSR #4, D1                  ;errase Effective address
    LSR #2, D1
    
    CMP.B BYTE_VAL_ONE, D1      ;these two compares tell if we are a byte mode
    BEQ BYTE_PRINT_V1           ;there are two ways the input can be used
    CMP.B BYTE_VAL_TWO, D1      ;V1 is if the EA comes first
    BEQ BYTE_PRINT_V2           ;V2 is if the register comes first
    
    CMP.B LONG_VAL_ONE, D1      ;thse two compares tell if we are in a long mode
    BEQ LONG_PRINT_V1           ;this is the same code as the byte section but for longs
    CMP.B LONG_VAL_TWO, D1
    BEQ LONG_PRINT_V2
    
    CMP.B WORD_VAL_ONE, D1      ;these two compares tell if we are in a word mode
    BEQ WORD_PRINT_V1           ;same section as for others but for word
    CMP.B WORD_VAL_TWO, D1
    BEQ WORD_PRINT_V2
    
REG_SEG_V1  LEA EA_TEXT,A1      ;this section is for printing out the register and EA
    MOVE.B #14,D0               ;if the EA came first
    TRAP #15
    
    LEA COMA,A1                 ;print ,
    MOVE.B  #14,D0                  
    TRAP    #15
    
    MOVE.L D2,D1                ;get back the orgional data so we can see
    LSL #4, D1                  ;what register we are in
    LSR #4, D1                  ;errase the opearnd mode
    LSR #3, D1                  ;errase EA and op mode to find what regisster
    LSR #6, D1                  ;we are using
    
    LEA D_TEXT, A1              ;print out D
    MOVE.B #14,D0
    TRAP #15
    
    EXT.L   D1                   ;Tells us what register we are using
    MOVE.B  #3,D0                ;loading
    TRAP    #15                  ;displaying
    BRA END_SEG                  ;we are done with this command
REG_SEG_V2  MOVE.L D2,D1         ;get back the orgional data so we can see
    LSL #4, D1                   ;delete the operand mode
    LSR #4, D1
    LSR #3, D1                   ;delete the EA and OP mode
    LSR #6, D1                   ;we only need the register value
   
    LEA D_TEXT, A1               ;print out D
    MOVE.B #14,D0                
    TRAP #15
    
    EXT.L   D1                   ;print out what register the code is using
    MOVE.B  #3,D0                ;loading
    TRAP    #15                  ;displaying

    LEA COMA,A1                  ;print ,
    MOVE.B  #14,D0                  
    TRAP    #15
         
    LEA EA_TEXT,A1               ;print out EA to signle for EA guy
    MOVE.B #14,D0
    TRAP #15
        
    BRA END_SEG
* Put program code here
BYTE_PRINT_V1  LEA BYTE_TEXT,A1     ;print B
    MOVE.B  #14,D0                  
    TRAP    #15
    BRA REG_SEG_V1                  ;go to the proper way to pring out register and EA
LONG_PRINT_V1  LEA LONG_TEXT,A1     ;print L
    MOVE.B  #14,D0                  
    TRAP    #15
    BRA REG_SEG_V1                  ;go to the proper way to pring out register and EA
WORD_PRINT_V1  LEA WORD_TEXT,A1     ;print W
    MOVE.B  #14,D0                  
    TRAP    #15
    BRA REG_SEG_V1                  ;go to the proper way to pring out register and EA
BYTE_PRINT_V2  LEA BYTE_TEXT,A1     ;print B
    MOVE.B  #14,D0                  
    TRAP    #15
    BRA REG_SEG_V2                  ;go to the proper way to pring out register and EA
LONG_PRINT_V2  LEA LONG_TEXT,A1     ;print L
    MOVE.B  #14,D0                  
    TRAP    #15
    BRA REG_SEG_V2                  ;go to the proper way to pring out register and EA
WORD_PRINT_V2  LEA WORD_TEXT,A1     ;print W
    MOVE.B  #14,D0                  
    TRAP    #15
    BRA REG_SEG_V2                  ;go to the proper way to pring out register and EA
    
END_SEG    SIMHALT             ; halt simulator

*Common used variable
SAMPLE_INPUT DC.L $8710
OR_TEXT DC.B 'OR.',0
BYTE_TEXT DC.B 'B ',0
LONG_TEXT DC.B 'L ',0
WORD_TEXT DC.B 'W ',0
BYTE_VAL_ONE DC.B $0
BYTE_VAL_TWO DC.B $4
WORD_VAL_ONE DC.B $1
WORD_VAL_TWO DC.B $5
LONG_VAL_ONE DC.B $2
LONG_VAL_TWO DC.B $6
EA_TEXT DC.B 'EA',0
COMA DC.B ',',0
D_TEXT DC.B 'D',0
    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
