*-----------------------------------------------------------
* Title      : BCLR Decompiler Code
* Written by : Brad Minogue
* Date       : 12/5/14
* Description: BCLR Decompiler code
*-----------------------------------------------------------
    ORG    $1000
START:          
    MOVE.L (SAMPLE_INPUT),D2            ;load up sample input
    
    MOVE.L D2,D1                        ;copy
    MOVE.L D2,D0                        ;copy so no need to copy latter
    AND.L (BCLR_REG_VALUE),D1           ;bitmask for check
    CMP.L BCLR_REG_VALUE,D1             ;are we a BCLR Register Mode?
    BNE IMID_MODE_SEG                   ;if not maybe imidiat mode
    
    LEA BCLR_TEXT,A1                    ;print out BCLR
    MOVE.B #14,D0
    TRAP #15
    
    LEA REGESTER_TEXT,A1                ;print out D
    MOVE.B #14,D0
    TRAP #15
    
    MOVE.L D2,D1
    LSL #4,D1                           ;get what reg we are in
    LSR #5,D1
    LSR #8,D1
    
    MOVE.B #3,D0                        ;print out what reg we are in
    TRAP #15
    BRA EA_MODE
    
IMID_MODE_SEG AND.L (BCLR_IMID_VALUE),D0 ;check to see if we are BLCR imidiat
    CMP.L BCLR_IMID_VALUE,D0
    BNE END_SEG                         ;if not move on
    LEA BCLR_TEXT,A1                    ;print out BLCR
    MOVE.B #14,D0
    TRAP #15
    
    LEA VALUE_TEXT,A1                   ;print out #
    MOVE.B #14,D0
    TRAP #15
    BRA EA_MODE
    
EA_MODE LEA EA_TEXT,A1                  ;hand off to EA
    MOVE.B #14,D0
    TRAP #15
    BNE END_SEG
END_SEG   SIMHALT             
SAMPLE_INPUT DC.L $0880
BCLR_TEXT DC.B 'BCLR ',0
*BCLR Dn,EA
BCLR_REG_VALUE DC.L $0180
*BCLR #X,EA
BCLR_IMID_VALUE DC.L $0880
EA_TEXT DC.B ', EA',0
VALUE_TEXT DC.B ' #',0
REGESTER_TEXT DC.B 'D',0
    END    START  
    
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
