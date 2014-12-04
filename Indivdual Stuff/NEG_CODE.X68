*-----------------------------------------------------------
* Title      :  NEG Decompiler Code
* Written by :  Brad Minogue
* Date       :  11/25/14
* Description:  NEG Decompiler code
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
    MOVE.L (SAMPLE_INPUT),D2        ;load in sample input
    MOVE.L D2,D1                    ;copy input to maintain purity
    LSR #8,D1                       ;get rid of data that isn't involved in testing NEG
    CMP.L NEG_VALUE, D1             ;test to see if we are neg
    BNE END_SEG                     ;if we are not NEG end this
    
    LEA NEG_TEXT, A1                ;Load up and print 'NEG'
    MOVE.B #14,D0
    TRAP #15
    
    MOVE.L D2,D1                    ;Copy data in
    LSL #8,D1                       ;get rid of the NEG code
    LSR #8,D1
    LSR #6, D1                      ;get rid of the EA code
        
    CMP.L #0,D1                     ;are we dealing with a bit?
    BNE LONG_SEG                    ;if not go to next test
    
    LEA B_TEXT,A1                   ;print out bit
    MOVE.B #14,D0
    TRAP #15
    BRA EA_SEG                      ;mote to teh EA section
LONG_SEG CMP.L #2,D1                ;are we a long?
    BNE WORD_SEG                    ;if not we are a word
    
    LEA L_TEXT, A1                  ;print out L
    MOVE.B #14, D0
    TRAP #15
    BRA EA_SEG                      ;move to EA section
WORD_SEG LEA W_TEXT, A1             ;print out W
    MOVE.B #14,D0
    TRAP #15
    
EA_SEG LEA EA_TEXT,A1               ;print out EA also this is
    MOVE.B #14,D0                   ;where we ould hand off to EA
    TRAP #15
END_SEG    SIMHALT                  ;halt simulator

* Put variables and constants here
SAMPLE_INPUT DC.L $4440
NEG_VALUE DC.L $0044
NEG_TEXT DC.B 'NEG.',0
B_TEXT DC.B 'B ',0
L_TEXT DC.B 'L ',0
W_TEXT DC.B 'W ',0
EA_TEXT DC.B 'EA',0
    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
