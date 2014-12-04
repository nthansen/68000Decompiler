*-----------------------------------------------------------
* Title      :  ORI DECOMPILER CODE
* Written by :  Brad Minogue
* Date       :  11/25/14
* Description:  Decompiles ORI instruction
*-----------------------------------------------------------
    ORG    $1000
START:        

    MOVE.L (SAMPLE_INPUT),D2        ;take in our sample input
    CMP.L  ORI_TO_CCR_VALUE,D2      ;compare to see if we are using CCR
    BEQ ORI_TO_CCR                  ;if we are skip to that section
        
    MOVE.L D2, D1                   ;copy input to maintain purity
    LSR #8,D1                       ;get rid of any extra data
    CMP.L  ORI_VALUE, D1            ;see if we are an ORI
    BNE END_SEG                     ;if not we are done here
    
    LEA ORI_TEXT,A1                 ;We found that this is indeed ORI # so print it out
    MOVE.B #14,D0                   ;here we will look at our data, nothing for now
    TRAP #15                    

    MOVE.L D2,D1
    LSL #8, D1
    LSR #8,D1
    LSL #4,D1

    CMP.L #0, D1
    BNE LONG_SEG
    
    LEA B_TEXT,A1                  ;Here we will hand off to EA guy and he will print any EA
    MOVE.B #14,D0               
    TRAP #15   
    BRA AFTER_SIZE_SEG

LONG_SEG    CMP.L #1,D1
    BNE WORD_SEG
    
    LEA L_TEXT,A1                  ;Here we will hand off to EA guy and he will print any EA
    MOVE.B #14,D0               
    TRAP #15   
    BRA AFTER_SIZE_SEG
    
WORD_SEG    LEA W_TEXT,A1                  ;Here we will hand off to EA guy and he will print any EA
    MOVE.B #14,D0               
    TRAP #15   
    
    
AFTER_SIZE_SEG    LEA DATA_TEXT,A1                ;here we will be printing out data
    MOVE.B #14,D0
    TRAP #15
    LEA COMMA_TEXT,A1               ;Next comes a ',' so print that
    MOVE.B #14,D0               
    TRAP #15                      
    LEA EA_TEXT,A1                  ;Here we will hand off to EA guy and he will print any EA
    MOVE.B #14,D0               
    TRAP #15   

                                 
    BRA END_SEG                     ;we are done with the program
ORI_TO_CCR  LEA ORI_TEXT,A1         ;We found that this is indeed ORI # so print it out
    MOVE.B #14,D0                   ;we will also look at our data later, nothing for now 
    TRAP #15                    
    
    LEA DATA_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    
    LEA COMMA_TEXT,A1               ;NExt comes a ',' so print that
    MOVE.B #14,D0                   
    TRAP #15                    
    
    LEA CCR_TEXT,A1                 ;Print out CCR
    MOVE.B #14,D0                
    TRAP #15                    
               
    BRA END_SEG                     ;we are done here

END_SEG    SIMHALT                  ;halt simulator

* Variables here
SAMPLE_INPUT DC.L $003C
ORI_VALUE DC.L $0000
ORI_TEXT DC.B 'ORI', 0
ORI_TO_CCR_VALUE DC.L $003C
CCR_TEXT DC.B 'CCR',0
COMMA_TEXT DC.B ',',0
EA_TEXT DC.B 'EA',0
B_TEXT DC.B '.B ',0
L_TEXT DC.B '.L ',0
W_TEXT DC.B '.W ',0
DATA_TEXT DC.B '#',0
    END    START        ; last line of source

    

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
