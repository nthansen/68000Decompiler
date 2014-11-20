*-----------------------------------------------------------
* Title      : BRA and BCC OP Code
* Written by : Brad Minouge
* Date       : 11/19/2014
* Description: BRA and BCC decompiler code
*These are the same as the only difference is one didget
*-----------------------------------------------------------
    ORG    $1000
START:         
    MOVE.L (SAMPLE_INPUT),D2    ;load up sample input
    MOVE.L D2,D1                ;copy it so no mod the origional input
    LSR #8, D1                  ;get rid of the displacement
    CMP.L BRA_VALUE,D1          ;see if we are a BRA
    BNE BCC_SEG                 ;if not end this eg
   
    LEA BRA_TEXT,A1             ;print out BRA
    MOVE.B #14,D0
    TRAP #15
        
    MOVE.L D2,D1                ;here we are printing out the displacment
    LSL #8, D1                  ;here we get rid of the instruction
    LSR #8, D1                  ;so only the displacement is left
    BRA DISP_SEG
BCC_SEG
    MOVE.L D2,D1                ;copy it so no mod the origional input
    LSR #8, D1                  ;get rid of the displacement
    LSR #4, D1                  ;get rid of the condition
    
    CMP.L BCC_VALUE,D1          ;see if we are a BCC
    BNE END_SEG                 ;if not end this eg

    LEA BCC_TEXT,A1             ;print out BCC
    MOVE.B #14,D0
    TRAP #15
        
    MOVE.L D2,D1                ;here we are printing out the displacment
    LSL #4, D1                  ;here we get rid of the instruction
    LSR #4, D1                  ;so only the displacement is left
    BRA DISP_SEG
DISP_SEG
    EXT.L D1                    ;print out the displacement
    MOVE.B #3,D0
    TRAP #15   
END_SEG SIMHALT             ; halt simulator

* Put variables and constants here
SAMPLE_INPUT DC.L $61FE
BRA_VALUE DC.L $60
BRA_TEXT DC.B 'BRA ',0
BCC_VALUE DC.L $6
BCC_TEXT DC.B 'BCC ',0
    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
