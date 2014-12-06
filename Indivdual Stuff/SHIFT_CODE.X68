*-----------------------------------------------------------
* Title      : Shift Decompiler Code
* Written by : Brad Minogue
* Date       :
* Description: Decompiles LSn, ASn, and ROn
*-----------------------------------------------------------
    ORG    $1000
START:       
    LSR #2,D0
    MOVE.L (SAMPLE_INPUT),D2            ;load up sample data    
    MOVE.L D2,D1                        ;copy data
    LSR #8,D1                           ;find out what shift type we are
    LSR #4,D1
    MOVE D1,D3                          ;copy data
    CMP.L REGESTER_ROTATE_VALUE, D1     ;see if we are indeed register rotate
    BNE END_SEG                         ;if not end this
    MOVE D2,D1      
    AND.L MEMORY_ROTATE_VALUE,D1        ;bit mask data to see if we are going to be
    CMP.L MEMORY_ROTATE_VALUE,D1        ; a register or memeory rotate type
    BEQ SHIFT_FOR_MEM
    MOVE D2,D1                          ;restor data
    LSL #8,D1                           ;put the stuff in the right place to find
    LSL #3,D1
    LSR #8,D1
    LSR #6,D1
    CMP.L RO_VALUE,D1                   ;are we ROd?
    BNE LS_PRINT
    LEA RO_TEXT,A1                      ;yes? print it out
    MOVE.L #14,D0
    TRAP #15
    BRA LEFT_RIGHT                      ;decide if we are left or right
SHIFT_FOR_MEM MOVE D2,D1                ;restore data
    LSL #8,D1
    LSR #8,D1
    LSR #6,D1
    CMP.L RO_VALUE,D1                   ;are we ROd?
    BNE LS_PRINT
    LEA RO_TEXT,A1                      ;yes? print out
    MOVE.L #14,D0
    TRAP #15
    BRA LEFT_RIGHT                      ;decide if we are left or right
LS_PRINT    CMP.L LS_VALUE,D1
    BNE AS_PRINT                        ;are we ls?
    LEA LS_TEXT,A1                      ;yes? print
    MOVE.L #14,D0
    TRAP #15
    BRA LEFT_RIGHT                      ;decide if we are left or right
AS_PRINT    CMP.L AS_VALUE,D1           ;are we AS?
    BNE END_SEG                         
    LEA AS_TEXT,A1                      ;print out AS
    MOVE.L #14,D0
    TRAP #15
    BRA LEFT_RIGHT
LEFT_RIGHT    MOVE.L D2,D1              ;decide if we are left or right
    LSL #7,D1
    LSR #7,D1                           ;git rid of all the data
    LSR #8,D1
    CMP #1,D1
    BNE RIGHT_ONLY                      ;we arn't left so right
    
    LEA LEFT_TEXT,A1                    ;print out left
    MOVE.B #14,D0
    TRAP #15
    BRA MEMORY_OR_REGESTER_MODE
RIGHT_ONLY  LEA RIGHT_TEXT,A1           ;print out right
    MOVE.B #14,D0
    TRAP #15
    BRA MEMORY_OR_REGESTER_MODE
MEMORY_OR_REGESTER_MODE    MOVE.L D2,D1 ;are we memeory or regester mode?
    LSR #8,D1
    LSR #1,D1
    AND.L MEMORY_ROTATE_VALUE,D1        ;bit mask data
    CMP.L MEMORY_ROTATE_VALUE,D1        ;are we memeory?
    BNE REGESTER_SEG 
    MOVE.L D2,D1
    LEA EA_TEXT,A1                      ;had off to ea
    MOVE.B #14,D0
    TRAP #15
    BRA END_SEG
REGESTER_SEG   MOVE.L D2,D1             ;restore data
    LSL #8,D1
    LSL #2,D1
    LSR #8,D1
    LSR #2,D1
    LSL #5,D1
    MOVE.L D2,D3                        ;restore data
    LSL #4,D3
    LSR #4,D3
    LSR #8,D3
    LSR #1,D3                           ;figure out
    CMP #0,D1
    BNE REG_VALUE
        
    LEA VALUE_TEXT,A1
    MOVE.L #14,D0
    TRAP #15
    BRA FINISH_OUTPUT
REG_VALUE   LEA VALUE_TEXT,A1           ;print out #
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
    LEA COMMA, A1                       ;print out ,
    MOVE.L #14,D0
    TRAP #15
    LEA REG_TEXT,A1
    MOVE.L #14,D0
    TRAP #15
    EXT.L D1                            ;print out Dn
    MOVE #3,D0
    TRAP #15
    BRA END_SEG                         ;we are done here
    
    
END_SEG    SIMHALT             ; halt simulator

* Put variables and constants here
SAMPLE_INPUT DC.L $E448
RO_TEXT DC.B 'RO',0
RO_VALUE DC.L $3
LS_TEXT DC.B 'LS',0
LS_VALUE DC.L $1
AS_TEXT DC.B 'AS',0
AS_VALUE DC.L $0
RIGHT_TEXT DC.B 'R ',0
LEFT_TEXT DC.B 'L ',0
MEMORY_ROTATE_VALUE DC.L $7300
REGESTER_ROTATE_VALUE DC.L $E
VALUE_TEXT DC.B '#',0
REG_TEXT DC.B 'D',0
COMMA DC.B ',',0
EA_TEXT DC.B 'EA',0
    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
