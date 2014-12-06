*-----------------------------------------------------------
* Title      :  ADD and ADDA Decoding
* Written by :  Brad Minogue
* Date       :  12/5/14
* Description:  Add and ADDa decoding, they share op code
*so they need to be decoded toegher 
*-----------------------------------------------------------
    ORG    $1000
START:
    MOVE.L (SAMPLE_INPUT),D2    ;load up input
    MOVE.L D2,D1                ;copy it
    ;determine if we are a type of add
    AND.L (ADD_VALUE),D1
    CMP.L ADD_VALUE,D1
    BNE END_SEG                 ;if not end this
    ;print out add both types of add will use this
    LEA ADD_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    ;this is how we are going to check for which add we are
    MOVE.L D2,D1                ;by looking at the size we can
    LSL #7,D1                   ;tell if we are ADDA or ADD
    LSR #7,D1                   ;and which form of ADD we are
    LSR #6,D1                   ;ADD Dn, EA or ADD EA,Dn
    
    CMP.L ADDA_WORD_VALUE,D1    ;we will start with ADDA since
    BEQ ADDA_W_SEG              ;thre are only two forms
    CMP.L ADDA_LONG_VALUE,D1
    BEQ ADDA_L_SEG
    
    BRA ADD_SEG                 ;if we are not adda we are add
ADDA_W_SEG 
    LEA ADD_ADDR_TEXT,A1        ;print out the a in ADD(A)
    MOVE.B #14,D0
    TRAP #15
    LEA WORD_TEXT,A1            ;print out our size
    MOVE.B #14,D0
    TRAP #15
    BRA ADDA_SEG                ;now to the rest of the OP
ADDA_L_SEG
    LEA ADD_ADDR_TEXT,A1        ;print out the a in ADD(A)
    MOVE.B #14,D0            
    TRAP #15
    LEA LONG_TEXT,A1            ;print out the size
    MOVE.B #14,D0
    TRAP #15
    BRA ADDA_SEG                ;now to the rest of the OP
ADDA_SEG
    LEA EA_TEXT,A1              ;EA will always come first in ADDA
    MOVE.B #14,D0               ;so hand off here
    TRAP #15

    LEA COMMA_TEXT,A1           ;print out a ,
    MOVE.B #14,D0
    TRAP #15

    LEA ADD_ADDR_TEXT,A1        ;print out An
    MOVE.B #14,D0
    TRAP #15
    
    MOVE.L D2,D1                ;find n
    LSL #4,D1
    LSR #5,D1
    LSR #8,D1    
    MOVE.B #3,D0                 ;print out what reg we are in
    TRAP #15
    
    BRA END_SEG
ADD_SEG 
    ;here we are finding what size and what version we are
    ;this set of versions has EA then Dn
    CMP.L ADD_BYTE_V1,D1 
    BEQ ADD_B_V1
    CMP.L ADD_LONG_V1,D1       
    BEQ ADD_L_V1
    CMP.L ADD_WORD_V1,D1        
    BEQ ADD_W_V1
    ;this set of versions has Dn then EA
    CMP.L ADD_BYTE_V2,D1
    BEQ ADD_B_V2
    CMP.L ADD_LONG_V2,D1
    BEQ ADD_L_V2
    CMP.L ADD_WORD_V2,D1
    BEQ ADD_W_V2
    BRA END_SEG
ADD_B_V1 ;print out byte then go to the rest
    LEA BYTE_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    BRA ADD_V1
ADD_L_V1 ;print out the long then to the rest
    LEA LONG_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    BRA ADD_V1
ADD_W_V1    ;print out the w then to the rest
    LEA WORD_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    BRA ADD_V1
ADD_B_V2    ;print out the b then the rest
    LEA BYTE_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    BRA ADD_V2
ADD_L_V2    ;print out the l then ther eest
    LEA LONG_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    BRA ADD_V2
ADD_W_V2    ;print out the w then the rest
    LEA WORD_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    BRA ADD_V2 
ADD_V1  ;here we are going to finish the EA then Dn
    LEA EA_TEXT,A1  ;hand off to EA
    MOVE.B #14,D0
    TRAP #15
    LEA COMMA_TEXT,A1   ;type a ,
    MOVE.B #14,D0
    TRAP #15
    LEA REG_TEXT,A1     ;type a D
    MOVE.B #14,D0
    TRAP #15
    MOVE.L D2,D1
    LSL #4,D1           ;find and print our register
    LSR #5,D1
    LSR #8,D1    
    MOVE.B #3,D0                        ;print out what reg we are in
    TRAP #15
    BRA END_SEG
ADD_V2
    LEA REG_TEXT,A1     ;find and print our reg
    MOVE.B #14,D0
    TRAP #15
    MOVE.L D2,D1
    LSL #4,D1
    LSR #5,D1
    LSR #8,D1    
    MOVE.B #3,D0                        ;print out what reg we are in
    TRAP #15
    LEA COMMA_TEXT,A1
    MOVE.B #14,D0       ;hand off to ea
    TRAP #15
    LEA EA_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    BRA END_SEG
END_SEG    SIMHALT
SAMPLE_INPUT DC.L $DBC1
ADD_VALUE DC.L $D000
ADD_TEXT DC.B 'ADD',0
ADD_ADDR_TEXT DC.B 'A',0
ADD_BYTE_V1 DC.L $0
ADD_WORD_V1 DC.L $1
ADD_LONG_V1 DC.L $2

ADD_BYTE_V2 DC.L $4
ADD_WORD_V2 DC.L $5
ADD_LONG_V2 DC.L $6

REG_TEXT DC.B 'D',0
ADDA_WORD_VALUE DC.L $3
WORD_TEXT DC.B '.W ',0
ADDA_LONG_VALUE DC.L $7
LONG_TEXT DC.B '.L ',0
BYTE_TEXT DC.B '.B ',0
EA_TEXT DC.B 'EA',0
COMMA_TEXT DC.B ',',0
    END    START        ; last line of source
    
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
