*-----------------------------------------------------------
* Title      : CMP Decompiler
* Written by : Brad Minogue
* Date       : 12/5/14
* Description: Decompiles CMP
*-----------------------------------------------------------
    ORG    $1000
START:        
    CMP.L CMP_VALUE,D1          ;load up the variable to compare to
    MOVE.L (SAMPLE_INPUT),D2    ;load up sample input
    MOVE.L D2,D1                ;copy data
    AND.L CMP_VALUE, D1         ;bit mask the input
    CMP.L CMP_VALUE,D1          ;compare the input
    BNE END_SEG                 ;if we are not CMP go to the end seg
    LEA CMP_TEXT,A1             ;print out CMP.
    MOVE.B #14,D0
    TRAP #15
    MOVE.L D2,D1                ;restore data
    LSL #7,D1                   ;get rid of all data exect the size
    LSR #7,D1
    LSR #6,D1
    CMP.L #0,D1                 ;are we a byte?
    BNE WORD_SEG        
    LEA BYTE_TEXT,A1            ;yes? print it out
    MOVE.B #14,D0
    TRAP #15
    BRA REG_SEG
WORD_SEG CMP.L #1,D1            ;are we a word?
    BNE LONG_SEG
    
    LEA WORD_TEXT,A1            ;yes? print it out
    MOVE.B #14,D0
    TRAP #15
    BRA REG_SEG
LONG_SEG                        ;only thing left is long
    LEA LONG_TEXT,A1            ;print it
    MOVE.B #14,D0
    TRAP #15
    BRA REG_SEG
REG_SEG LEA REGESTER_TEXT,A1    ;we are always dealing with
    MOVE.B #14,D0               ;a register here so print it
    TRAP #15
    MOVE.L D2,D1                ;restore data
    LSL #4,D1                   ;find out what reg we are
    LSR #5,D1
    LSR #8,D1
    EXT.L D1                    ;print that out
    MOVE.B #3,D0
    TRAP #15
    BRA EA_SEG
EA_SEG                          ;hand off to ea
    LEA EA_TEXT,A1
    MOVE.B #14,D0
    TRAP #15

END_SEG    SIMHALT             ; halt simulator
SAMPLE_INPUT DC.L $B2B9
CMP_TEXT DC.B 'CMP.',0
CMP_VALUE DC.L $B000
BYTE_TEXT DC.B 'B ',0
LONG_TEXT DC.B 'L ',0
WORD_TEXT DC.B 'W ',0
EA_TEXT DC.B ',EA',0
REGESTER_TEXT DC.B 'D',0
    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
