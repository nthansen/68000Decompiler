*-----------------------------------------------------------
* Title      : MULS and DIVS DECOMPILER CODE
* Written by : Brad Minogue
* Date       : 12/5/14
* Description: Muls and Divs Decompiler code
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
    MULS D7,D3
* Put program code here
    MOVE.L (SAMPLE_INPUT),D2
    MOVE.L D2,D1
    AND.L  (MULS_VALUE),D1
    CMP.L MULS_VALUE,D1
    BNE DIVS_SEG
    
    LEA MULS_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    BRA EA_SEG
DIVS_SEG MOVE.L D2,D1
    AND.L (DIVS_VALUE),D1
    CMP.L DIVS_VALUE,D1
    BNE END_SEG
    LEA DIVS_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    BRA EA_SEG
EA_SEG LEA EA_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    BRA REG_SEG
REG_SEG LEA REG_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    
    MOVE.L D2,D1
    LSL #4,D1
    LSR #5,D1
    LSR #8,D1 
    MOVE.B #3,D0
    TRAP #15
    BRA END_SEG
END_SEG    SIMHALT             ; halt simulator

* Put variables and constants here
SAMPLE_INPUT DC.L $87C7
EA_TEXT DC.B 'EA,',0
MULS_VALUE DC.L $C1C0
MULS_TEXT DC.L 'MULS ',0
DIVS_VALUE DC.L $81C0
DIVS_TEXT DC.L 'DIVS ',0
REG_TEXT DC.L 'D',0

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
