*-----------------------------------------------------------
* Title      : CMPI Decompiler
* Written by : Brad Minogue
* Date       : 12/5/14
* Description: Decompiler code for CMPI
*-----------------------------------------------------------
    ORG    $1000
START:           
    MOVE.L (SAMPLE_INPUT),D2    ;load up sample input
    MOVE.L D2,D1                ;store it   
    AND.L CMPI_VALUE,D1         ;bit mask to test for CMPI
    CMP.L CMPI_VALUE,D1         ;are we CMPI?
    BNE END_SEG                 ;yes? keep going
    LEA CMPI_TEXT,A1            ;print out CMPI.
    MOVE.B #14,D0
    TRAP #15
    MOVE.L D2,D1
    LSL #8,D1
    LSR #8,D1                   ;find our size
    LSR #6,D1
    CMP.L #0,D1
    BNE LONG_SEG                ;if we are not byte mabye long?
    LEA BYTE_TEXT,A1
    MOVE.B #14,D0               ;print out byte
    TRAP #15
    BRA EA_SEG                  ;go to ea
LONG_SEG CMP.L #2,D0            ;are we long? no? then word
    BNE WORD_SEG
    LEA LONG_TEXT,A1            ;print out long
    MOVE.B #14,D0
    TRAP #15
    BRA EA_SEG                  ;branch to ea
WORD_SEG 
    LEA WORD_TEXT,A1            ;print out word
    MOVE.B #14,D0
    TRAP #15
    BRA EA_SEG
EA_SEG 
    LEA EA_TEXT,A1              ;branch to ea
    MOVE.B #14,D0
    TRAP #15
END_SEG    SIMHALT     
SAMPLE_INPUT DC.L $0C01
CMPI_VALUE DC.L $0C00
CMPI_TEXT DC.B 'CMPI.',0
EA_TEXT DC.B ',EA',0
BYTE_TEXT DC.B 'B #',0
LONG_TEXT DC.B 'L #',0
WORD_TEXT DC.B 'W #',0
    END    START       

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
