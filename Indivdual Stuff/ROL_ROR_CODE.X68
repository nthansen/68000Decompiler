*-----------------------------------------------------------
* Title      :  ROR AND ROS DECOMPILER CODE
* Written by :  Brad Minogue
* Date       :  11/25/14
* Description:  ROR/ROS decompiler code
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
    ROR #5,D6
* Put program code here
    MOVE.L (SAMPLE_INPUT),D2
    
    MOVE.L D2,D1
    LSR #8,D1
    LSR #1,D1
    MOVE D1,D3
    CMP.L  MEMORY_ROTATE_VALUE, D1
    BEQ ROR_ROL_ROTATE

    LSR #3,D1
    CMP.L  REGESTER_ROTATE_VALUE, D1
    BNE END_SEG

    BRA ROR_ROL_ROTATE
    
MODE_SEG    CMP.L MEMORY_ROTATE_VALUE,D3
    BEQ MEM_SEG
    MOVE.L D2,D1
    LSL #8,D1
    LSL #2,D1
    LSR #8,D1
    LSR #2,D1
    LSL #5,D1
    MOVE.L D2,D3
    LSL #4,D3
    LSR #4,D3
    LSR #8,D3
    LSR #1,D3
    CMP #0,D1
    BNE REG_VALUE
        
    LEA VALUE_TEXT,A1
    MOVE.L #14,D0
    TRAP #15
    BRA FINISH_OUTPUT
REG_VALUE   LEA VALUE_TEXT,A1
    MOVE.L #14,D0
    TRAP #15
    BRA FINISH_OUTPUT
    
FINISH_OUTPUT
    MOVE.L D3,D1
    EXT.L   D1                ;Tells us what register we are using
    MOVE.B  #3,D0                ;loading
    TRAP    #15                  ;displaying
    
    MOVE.L D2,D1
    LSL #8,D1
    LSL #5,D1
    LSR #8,D1
    LSR #5,D1
    LEA COMMA, A1
    MOVE.L #14,D0
    TRAP #15
    LEA REG_TEXT,A1
    MOVE.L #14,D0
    TRAP #15
    EXT.L D1
    MOVE #3,D0
    TRAP #15
    BRA END_SEG                         ;we are done here
    
    
MEM_SEG 
    MOVE.L D2,D1
    LEA EA_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    BRA END_SEG    
ROR_ROL_ROTATE    
    MOVE.L D2,D1
    LSL #7,D1
    LSR #7,D1
    LSR #8,D1
    CMP #0,D1
    BNE LEFT_ROTATE
    
    LEA ROR_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    
    BRA MODE_SEG
LEFT_ROTATE    LEA ROL_TEXT,A1    ;just testing branching here
    MOVE.B #14,D0
    TRAP #15
    
    BRA MODE_SEG
END_SEG    SIMHALT             ; halt simulator

* Put variables and constants here
SAMPLE_INPUT DC.L $E6C0
MEMORY_ROTATE_VALUE DC.L $73
REGESTER_ROTATE_VALUE DC.L $E
ROR_TEXT DC.B 'ROR ',0
ROL_TEXT DC.B 'ROL ',0
VALUE_TEXT DC.B '#',0
REG_TEXT DC.B 'D',0
COMMA DC.B ',',0
EA_TEXT DC.B 'EA',0
    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
