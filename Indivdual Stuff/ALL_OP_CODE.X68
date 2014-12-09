*-----------------------------------------------------------
* Title      : Decode OP
* Written by : Brad Minogue
* Date       : 12/8/14
* Description: This is the segment of code that decodes the OP
*code input, EA will be appended to this.
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
    ;line of code is obsolete once we get data from IO
    MOVE.L (SAMPLE_INPUT),D2
DECODE_OPCODE           ;this is what is called when IO has input to decode
*-------------------------------NOP-------------------------------    
    MOVE.L D2,D1
    CMP.L NOP_VALUE, D1         ;check to see if we are NOP
    BNE JSR_SEG                 ;if not just end this
    JSR PRINT_NOP
    BRA END_SEG
*-------------------------------JSR-------------------------------    
JSR_SEG
    MOVE.L D2,D1                ;copy the data so we don't ruin it
    LSR #6,D1                   ;erase the EA
    CMP.L JSR_VALUE, D1         ;see if we are JSR
    BNE RTS_SEG                 ;if not end this segment
    JSR PRINT_JSR
    JSR PRINT_SPACE  
    
    MOVEM D0-D3,-(SP)           ;back up data before function call
    LEA EA_TEXT,A1              ;this is where we hand off to EA
    MOVE.B #14,D0
    TRAP #15   
    MOVEM (SP)+,D0-D3
    
    BRA END_SEG
*-------------------------------RTS-------------------------------    
RTS_SEG    
    MOVE.L D2,D1
    CMP.L RTS_VALUE, D1         ;see if we are a RTS instruction
    BNE BRA_BCC_SEG                 ;if not end this

    JSR PRINT_RTS
    BRA END_SEG
*-------------------------------LEA-------------------------------    
LEA_SEG    
    MOVE.L D2,D1                ;copy it
    AND.L (LEA_VALUE),D1                 ;bitmask the useless data in the input
    CMP.L LEA_VALUE,D1                 ;see if the remaindg data is LEA
    BNE SHIFT_SEG                 ;if not end this
    
    MOVE.L D2,D1                ;copy back
    LSL #4,D1                   ;move data around so only
    LSR #8,D1                   ;the register remains
    LSR #5,D1
    JSR PRINT_LEA
    JSR PRINT_SPACE
    
    MOVEM D0-D3,-(SP)     ;back up data before hand off
    LEA EA_TEXT,A1              ;print out EA
    MOVE #14,D0                 ;aka hand off here
    TRAP #15  
    MOVEM (SP)+,D0-D3     ;restore data
    JSR PRINT_COMMA
    JSR PRINT_ADD_REG
    
    JSR PRINT_D1
    BRA END_SEG  
*-------------------------------SHIFT------------------------------    
SHIFT_SEG    
    MOVE.L D2,D1                        ;copy data
    LSR #8,D1                           ;find out what shift type we are
    LSR #4,D1
    MOVE D1,D3                          ;copy data
    CMP.L REGESTER_ROTATE_VALUE, D1     ;see if we are indeed register rotate
    BNE NEG_SEG                         ;if not end this
   
    MOVE D2,D1      
    AND.L (MEMORY_ROTATE_VALUE),D1        ;bit mask data to see if we are going to be
    CMP.L MEMORY_ROTATE_VALUE,D1        ; a register or memeory rotate type
    BEQ SHIFT_FOR_MEM
    
    MOVE D2,D1                          ;restor data
    LSL #8,D1                           ;put the stuff in the right place to find
    LSL #3,D1
    LSR #8,D1
    LSR #6,D1
    CMP.L RO_VALUE,D1                   ;are we ROd?
    BNE LS_PRINT
    
    JSR PRINT_RO
    BRA LEFT_RIGHT                      ;decide if we are left or right
SHIFT_FOR_MEM MOVE D2,D1                ;restore data
    LSL #8,D1
    LSR #8,D1
    LSR #6,D1
    CMP.L RO_VALUE,D1                   ;are we ROd?
    BNE LS_PRINT
    JSR PRINT_RO
    BRA LEFT_RIGHT                      ;decide if we are left or right
LS_PRINT    CMP.L LS_VALUE,D1
    BNE AS_PRINT                        ;are we ls?
    JSR PRINT_LS
    BRA LEFT_RIGHT                      ;decide if we are left or right
AS_PRINT    CMP.L AS_VALUE,D1           ;are we AS?
    BNE END_SEG 
    JSR PRINT_AS
    BRA LEFT_RIGHT
LEFT_RIGHT    MOVE.L D2,D1              ;decide if we are left or right
    LSL #7,D1
    LSR #7,D1                           ;git rid of all the data
    LSR #8,D1
    CMP #1,D1
    BNE RIGHT_ONLY                      ;we arn't left so right
    
    JSR PRINT_LEFT
    BRA MEMORY_OR_REGESTER_MODE
RIGHT_ONLY  JSR PRINT_RIGHT
    BRA MEMORY_OR_REGESTER_MODE
MEMORY_OR_REGESTER_MODE    MOVE.L D2,D1 ;are we memeory or regester mode?
    LSR #8,D1
    LSR #1,D1
    AND.L (MEMORY_ROTATE_VALUE),D1        ;bit mask data
    CMP.L MEMORY_ROTATE_VALUE,D1        ;are we memeory?
    BNE SHIFT_REGESTER_SEG 
    MOVE.L D2,D1
    
    MOVEM D0-D3,-(SP)                   ;back up data
    LEA EA_TEXT,A1                      ;had off to ea
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0-D3                   ;restore data
    BRA END_SEG
SHIFT_REGESTER_SEG   MOVE.L D2,D1             ;restore data
    LSL #8,D1                           ;pre-shifting data
    LSL #2,D1                           ;for latter on
    LSR #8,D1
    LSR #2,D1
    LSL #5,D1
    MOVE.L D2,D3                        ;restore data
    LSL #4,D3                           
    LSR #4,D3
    LSR #8,D3
    LSR #1,D3                           ;figure out something
    CMP #0,D1                           ; *ouch*
    BNE SHIFT_REG_VALUE
    JSR PRINT_VALUE
    BRA FINISH_OUTPUT
SHIFT_REG_VALUE JSR PRINT_VALUE
    BRA FINISH_OUTPUT
    
FINISH_OUTPUT               ;this segment of code is shared by all shfit code
    MOVE.L D3,D1
    JSR PRINT_D1
    
    MOVE.L D2,D1            ;shift data around to figure out what reg we are using
    LSL #8,D1
    LSL #5,D1
    LSR #8,D1
    LSR #5,D1                           
    JSR COMMA_TEXT
    JSR PRINT_D1
    BRA END_SEG                         ;we are done here
*------------------------------NEG--------------------------------
NEG_SEG
    MOVE.L D2,D1                    ;copy input to maintain purity
    LSR #8,D1                       ;get rid of data that isn't involved in testing NEG
    CMP.L NEG_VALUE, D1             ;test to see if we are neg
    BNE MOVES_SEG                     ;if we are not NEG end this
    
    JSR PRINT_NEG
    
    MOVE.L D2,D1                    ;Copy data in
    LSL #8,D1                       ;get rid of the NEG code
    LSR #8,D1
    LSR #6, D1                      ;get rid of the EA code
        
    CMP.L #0,D1                     ;are we dealing with a bit?
    BNE NEG_LONG_SEG                    ;if not go to next test
    
    MOVE.B #0,D4        ;potential necicary information for EA
    JSR PRINT_BYTE
    JSR PRINT_SPACE
    
    BRA NEG_EA_SEG                      ;mote to teh EA section
NEG_LONG_SEG CMP.L #2,D1                ;are we a long?
    BNE NEG_WORD_SEG                    ;if not we are a word
    
    MOVE.B #3,D4        ;potential necicary information for EA
    JSR PRINT_LONG
    JSR PRINT_SPACE
    BRA NEG_EA_SEG                      ;move to EA section
NEG_WORD_SEG 
    MOVE.B #2,D4        ;potential necicary information for EA
    JSR PRINT_WORD
    JSR PRINT_SPACE
    
    
    BRA NEG_EA_SEG    
NEG_EA_SEG 
    MOVEM D0-D3,-(SP)           ;back up our data
    LEA EA_TEXT,A1               ;print out EA also this is
    MOVE.B #14,D0                   ;where we ould hand off to EA
    TRAP #15
    MOVEM (SP)+,D0-D3
    BRA END_SEG
*-------------------------------MOVE------------------------------    
MOVES_SEG
    ;see if we are MOVEM
    MOVE.L D2,D1
    AND.L (MOVEM_VALUE),D1
    CMP.L MOVEM_VALUE,D1
    BEQ MOVEM_SEG
    ;see if we are MOVE FROM CCR
    MOVE.L D2,D1
    AND.L (MOVE_FROM_CCR_VALUE),D1
    CMP.L MOVE_FROM_CCR_VALUE,D1
    BEQ MOVE_FROM_CCR_SEG
    ;see if are move to ccr
    MOVE.L D2,D1
    AND.L (MOVE_TO_CCR_VALUE),D1
    CMP.L MOVE_TO_CCR_VALUE,D1
    BEQ MOVE_TO_CCR_SEG
    ;see if are move from sr
    MOVE.L D2,D1
    AND.L (MOVE_FROM_SR_VALUE),D1
    CMP.L MOVE_FROM_SR_VALUE,D1
    BEQ MOVE_F_SR_SEG
    ;see if we are movea    
    MOVE.L D2,D1
    AND.L (MOVEA_VALUE),D1
    CMP.L MOVEA_VALUE,D1
    BNE  LEA_SEG
    BRA  MOVEA_SEG
MOVE_FROM_CCR_SEG
    ;Start off by print out move
    JSR PRINT_MOVE
    MOVE.L D2,D1
    ;print out ccr
    JSR PRINT_SPACE
    JSR PRINT_CCR
    ;now for a comma
    JSR PRINT_COMMA
    ;now we hand of to ea
    MOVEM D0-D3,-(SP)           ;back up data
    LEA EA_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0-D3           ;restore data
    BRA END_SEG
MOVE_TO_CCR_SEG
    ;print out move
    JSR PRINT_MOVE
    JSR PRINT_SPACE
    ;hand off to ea
    MOVE.L D2,D1
    MOVEM D0-D3,-(SP)           ;back up data
    LEA EA_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0-D3           ;restore data
    ;print out ,
    JSR COMMA_TEXT
    ;print out ccr
    JSR PRINT_CCR
    BRA END_SEG
MOVEA_SEG
    ;print out move
    JSR PRINT_MOVE
    ;print out A
    JSR PRINT_ADD_REG
    ;find out what size we are
    MOVE.L D2,D1
    LSL #2,D1
    LSR #2,D1
    LSR #4,D1
    LSR #8,D1
    BRA MOVEA_LONG_SEG
MOVEA_LONG_SEG
    ;print out L
    CMP.L #2,D1
    BNE MOVEA_WORD_SEG
    
    MOVE.B #3,D4        ;potential necicary information for EA
    JSR PRINT_LONG
    JSR PRINT_SPACE    
    BRA MOVEA_REST_SEG
MOVEA_WORD_SEG
    ;print out W
    MOVE.B #2,D4        ;potential necicary information for EA
    JSR PRINT_WORD
    JSR PRINT_SPACE
    BRA MOVEA_REST_SEG
MOVEA_REST_SEG
    ;hand off to EA
    MOVEM D0-D3,-(SP)               ;back up our data
    LEA EA_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0-D3               ;restore it
    ;print out ,
    JSR PRINT_COMMA
    ;print out A
    JSR PRINT_ADD_REG
    ;find out what reg we are in
    MOVE.L D2,D1
    LSL #4,D1
    LSR #5,D1
    LSR #8,D1 ;then print it out
    JSR PRINT_D1
    BRA END_SEG
MOVEM_SEG 
    ;print out MOVEM
    JSR PRINT_MOVEM
    ;find what size w eare
    MOVE.L D2,D1
    LSL #8,D1
    LSL #1,D1
    LSR #8,D1
    LSR #7,D1
    BRA MOVEM_LONG_SEG
MOVEM_LONG_SEG  ;see if we are a long if so print
    CMP.L #1,D1
    BNE MOVEA_WORD_SEG
    
    MOVE.B #3,D4        ;potential necicary information for EA
    JSR PRINT_LONG
    JSR PRINT_SPACE
    
    BRA MOVEM_REST_SEG
MOVEM_WORD_SEG  ;print out W
    MOVE.B #2,D4        ;potential necicary information for EA
    JSR PRINT_WORD
    JSR PRINT_SPACE
    
    BRA MOVEM_REST_SEG
MOVEM_REST_SEG  ;find which direction we are going
    MOVE.L D2,D1
    LSL #5,D1
    LSR #5,D1
    LSR #8,D1
    LSR #2,D1
    CMP.L #0,D1
    BNE REG_TO_MEM 
    MOVEM D0-D3,-(SP)               ;back up data
    LEA EA_TEXT, A1 ;hand off to ea
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0-D3               ;restore data
    JSR PRINT_COMMA 
    JSR PRINT_LIST
    BRA END_SEG
REG_TO_MEM
    
    JSR PRINT_LIST
    JSR PRINT_COMMA
    MOVEM D0-D3,-(SP)       ;back up data
    LEA EA_TEXT, A1     ;hand off to ea
    MOVE.B #14,D0
    TRAP #15    
    MOVEM (SP)+,D0-D3       ;restore data
    BRA END_SEG

MOVE_F_SR_SEG       
    JSR PRINT_MOVE
    MOVE.L D2,D1
    JSR PRINT_SPACE
    JSR PRINT_SR
    JSR PRINT_COMMA
    MOVEM D0-D3,-(SP)   ;back up data
    LEA EA_TEXT,A1      ;hand off to ea
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0-D3   ;restore data
    BRA END_SEG
*-----------------------------LAST--------------------------------
LAST_SEG
    ;see if we are a move
    MOVE.L D2,D1
    CMP.L MOVE_MIN_VALUE,D1
    BGE MOVE_SEG            ;BGE is used as all moves must be
    BRA END_SEG             ;more than a set value, see size starts at 1
MOVE_SEG
    JSR PRINT_MOVE
    MOVE.L D2,D1    ;restore data
    LSL #2,D1       ;find the size
    LSR #2,D1
    LSR #8,D1
    LSR #4,D1
    CMP.L #1,D1
    BNE MOVE_LONG_SEG   ;if we are a byte print it out
    
    MOVE.B #0,D4        ;potential necicary information for EA
    JSR PRINT_BYTE
    JSR PRINT_SPACE
    BRA MOVE_REST_SEG
MOVE_LONG_SEG               ;if we are a long print ito ut
    CMP.L #2,D1
    BNE MOVE_WORD_SEG
    
    MOVE.B #3,D4        ;potential necicary information for EA
    JSR PRINT_LONG
    JSR PRINT_SPACE
    BRA MOVE_REST_SEG
MOVE_WORD_SEG           ;if we are a word print it
    MOVE.B #2,D4        ;potential necicary information for EA
    
    JSR PRINT_WORD
    JSR PRINT_SPACE
    BRA MOVE_REST_SEG
MOVE_REST_SEG           ;hand off to ea here
    MOVEM D0-D3,-(SP)   ;back up data
    LEA EA_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0-D3       ;restore data
    JSR PRINT_COMMA
    MOVEM D0-D3,-(SP)       ;back up data
    LEA EA_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0-D3       ;restore data
    BRA END_SEG
*------------------------BRA/BCC---------------------------
BRA_BCC_SEG
    MOVE.L D2,D1                ;copy it so no mod the origional input
    LSR #8, D1                  ;get rid of the displacement
    CMP.L BRA_VALUE,D1          ;see if we are a BRA
    BNE BCC_SEG                 ;if not end this eg
   
    JSR PRINT_BRA
    JSR PRINT_SPACE    
    MOVE.L D2,D1                ;here we are printing out the displacment
    LSL #8, D1                  ;here we get rid of the instruction
    LSR #8, D1                  ;so only the displacement is left
    BRA DISP_SEG
BCC_SEG
    MOVE.L D2,D1                ;copy it so no mod the origional input
    LSR #8, D1                  ;get rid of the displacement
    LSR #4, D1                  ;get rid of the condition
    
    CMP.L BCC_VALUE,D1          ;see if we are a BCC
    BNE MULS_SEG                 ;if not end this eg

    JSR PRINT_BCC
    JSR PRINT_SPACE
    MOVE.L D2,D1                ;here we are printing out the displacment
    LSL #4, D1                  ;here we get rid of the instruction
    LSR #4, D1                  ;so only the displacement is left
    BRA DISP_SEG
DISP_SEG
    JSR PRINT_D1   
    BRA END_SEG
*------------------------------MULS/DIVS----------------------------
MULS_SEG
    MOVE.L D2,D1
    AND.L  (MULS_VALUE),D1      ;bit mask data to see if we are
    CMP.L MULS_VALUE,D1         ;MULS or DIVS
    BNE DIVS_SEG                ;if we are divs go to the seg of code
   
    JSR PRINT_MULS    
    JSR PRINT_SPACE
    BRA DIVS_EA_SEG             ;this seg is badly labled, it is shared by muls and divs
DIVS_SEG MOVE.L D2,D1
    AND.L (DIVS_VALUE),D1       ;are we divs? if not move on
    CMP.L DIVS_VALUE,D1
    BNE CMP_SEG
    JSR PRINT_DIVS
    
    JSR PRINT_SPACE
    
    BRA DIVS_EA_SEG             ;this seg is shared by both muls and divs, but does ea stuff
DIVS_EA_SEG 
    MOVEM D0-D3,-(SP)           ;back up data
    LEA EA_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0-D3           ;restore data
    
    JSR PRINT_COMMA
    
    BRA DIVS_REG_SEG            ;this seg is badly labled it is for divs and muls and does rest of output
DIVS_REG_SEG 
    JSR PRINT_REG    
    MOVE.L D2,D1                ;find what reg we are in and print it out
    LSL #4,D1
    LSR #5,D1
    LSR #8,D1 
    JSR PRINT_D1
    BRA END_SEG

*--------------------------ADD---------------------------------------    
ADD_SUB_SEG
    MOVE.L D2,D1                ;copy it
    AND.L (SUB_QUICK_VALUE),D1
    CMP.L SUB_QUICK_VALUE,D1
    BEQ SUBQ_SEG
    MOVE.L D2,D1
    ;determine if we are a type of add
    AND.L (ADD_VALUE),D1
    CMP.L ADD_VALUE,D1
    BNE SUB_SEG                 ;if not end this
    ;print out add both types of add will use this
    JSR PRINT_ADD
    BRA SUB_NEXT_SEG
SUB_SEG MOVE.L D2,D1                ;copy it
    ;determine if we are a type of SUB
    AND.L (SUB_VALUE),D1    
    CMP.L SUB_VALUE,D1
    BNE END_SEG
    JSR PRINT_SUB
    BRA SUB_NEXT_SEG
SUB_NEXT_SEG    ;this is how we are going to check for which add we are
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
    JSR PRINT_ADD
    MOVE.B #2,D4        ;potential necicary information for EA
    JSR PRINT_WORD
    JSR PRINT_SPACE
    BRA ADDA_SEG                ;now to the rest of the OP
ADDA_L_SEG
    JSR PRINT_ADD
    MOVE.B #3,D4        ;potential necicary information for EA
    JSR PRINT_LONG
    JSR PRINT_SPACE
    BRA ADDA_SEG                ;now to the rest of the OP
ADDA_SEG
    MOVEM D0-D3,-(SP)           ;back up data
    LEA EA_TEXT,A1              ;EA will always come first in ADDA
    MOVE.B #14,D0               ;so hand off here
    TRAP #15
    MOVEM (SP)+,D0-D3           ;restore data
    JSR PRINT_COMMA

    JSR PRINT_ADD_REG
    
    MOVE.L D2,D1                ;find n
    LSL #4,D1
    LSR #5,D1
    LSR #8,D1    
    JSR PRINT_D1
    
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
    MOVE.B #0,D4        ;potential necicary information for EA
    JSR PRINT_BYTE
    JSR PRINT_SPACE
    
    BRA ADD_V1
ADD_L_V1 ;print out the long then to the rest
    MOVE.B #3,D4        ;potential necicary information for EA
    JSR PRINT_LONG
    JSR PRINT_SPACE
    
    BRA ADD_V1
ADD_W_V1    ;print out the w then to the rest
    MOVE.B #2,D4        ;potential necicary information for EA
    JSR PRINT_WORD
    JSR PRINT_SPACE
    
    BRA ADD_V1
ADD_B_V2    ;print out the b then the rest
    MOVE.B #0,D4        ;potential necicary information for EA
    JSR PRINT_BYTE
    JSR PRINT_SPACE
    
    BRA ADD_V2
ADD_L_V2    ;print out the l then ther eest
    MOVE.B #3,D4        ;potential necicary information for EA
    JSR PRINT_LONG
    JSR PRINT_SPACE
    
    BRA ADD_V2
ADD_W_V2    ;print out the w then the rest
    MOVE.B #2,D4        ;potential necicary information for EA
    JSR PRINT_WORD
    JSR PRINT_SPACE
    
    BRA ADD_V2 
ADD_V1  ;here we are going to finish the EA then Dn
    MOVEM D0-D3,-(SP)   ;back up data
    LEA EA_TEXT,A1  ;hand off to EA
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0-D3       ;restore data
    JSR PRINT_COMMA
    JSR PRINT_REG
    MOVE.L D2,D1
    LSL #4,D1           ;find and print our register
    LSR #5,D1
    LSR #8,D1    
    JSR PRINT_D1
    BRA END_SEG
ADD_V2
    JSR PRINT_REG
    MOVE.L D2,D1
    LSL #4,D1
    LSR #5,D1
    LSR #8,D1    
    JSR PRINT_D1
    JSR PRINT_COMMA
    MOVEM D0-D3,-(SP)                   ;back up data
    LEA EA_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0-D3
    BRA END_SEG
SUBQ_SEG 
    JSR PRINT_SUBQ
    MOVE.L D2,D1
    LSL #8,D1
    LSR #8,D1
    LSR #6,D1
    CMP.L #0,D1
    BEQ SUBQ_BYTE_SEG
    CMP.L #1,D1
    BEQ SUBQ_WORD_SEG
    BRA SUBQ_LONG_SEG
SUBQ_DATA_SEG MOVE.L D2,D1
    LSL #4,D1
    LSR #5,D1
    LSR #8,D1
    
    JSR PRINT_VALUE
    JSR PRINT_D1
    JSR PRINT_COMMA
    MOVEM D0-D3,-(SP)               ;back up data
    LEA EA_TEXT,A1
    MOVE.B #14,D0       ;hand off to ea
    TRAP #15
    MOVEM (SP)+,D0-D3               ;restore data
    BRA END_SEG
SUBQ_BYTE_SEG
    MOVE.B #0,D4        ;potential necicary information for EA
    JSR PRINT_BYTE
    JSR PRINT_SPACE
    
    BRA SUBQ_DATA_SEG
SUBQ_LONG_SEG
    MOVE.B #3,D4        ;potential necicary information for EA
    JSR PRINT_LONG
    JSR PRINT_SPACE    
    BRA SUBQ_DATA_SEG
SUBQ_WORD_SEG
    MOVE.B #2,D4        ;potential necicary information for EA
    
    JSR PRINT_LONG
    JSR PRINT_SPACE
    
    BRA SUBQ_DATA_SEG

*-----------------------CMP----------------------------------
CMP_SEG
    MOVE.L (SAMPLE_INPUT),D2    ;load up sample input
    MOVE.L D2,D1                ;copy data
    AND.L (CMP_VALUE), D1         ;bit mask the input
    CMP.L CMP_VALUE,D1          ;compare the input
    BNE CMPI_SEG                 ;if we are not CMP go to the end seg
    
    JSR PRINT_CMP
    MOVE.L D2,D1                ;restore data
    LSL #7,D1                   ;get rid of all data exect the size
    LSR #7,D1
    LSR #6,D1
    CMP.L #0,D1                 ;are we a byte?
    BNE CMP_WORD_SEG        
    MOVE.B #0,D4        ;potential necicary information for EA
    
    JSR PRINT_BYTE
    JSR PRINT_SPACE
    
    BRA CMP_REG_SEG
CMP_WORD_SEG CMP.L #1,D1            ;are we a word?
    BNE CMP_LONG_SEG
    MOVE.B #2,D4        ;potential necicary information for EA
    
    JSR PRINT_WORD
    JSR PRINT_SPACE
    BRA CMP_REG_SEG
CMP_LONG_SEG     
    MOVE.B #3,D4        ;potential necicary information for EA
                   ;only thing left is long
    MOVE.B #3,D4        ;potential necicary information for EA
    
    JSR PRINT_LONG
    JSR PRINT_SPACE
    
    BRA CMP_REG_SEG
CMP_REG_SEG 
    JSR PRINT_REG
    MOVE.L D2,D1                ;restore data
    LSL #4,D1                   ;find out what reg we are
    LSR #5,D1
    LSR #8,D1
    
    JSR PRINT_D1
    BRA CMP_EA_SEG
CMP_EA_SEG                          ;hand off to ea
    MOVEM D0-D3,-(SP)               ;back up datat
    LEA EA_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0-D3               ;restore data
    BRA END_SEG
*-------------------------CMPI--------------------------------
CMPI_SEG
    MOVE.L D2,D1                ;store it   
    AND.L (CMPI_VALUE),D1         ;bit mask to test for CMPI
    CMP.L CMPI_VALUE,D1         ;are we CMPI?
    BNE OR_SEG                 ;yes? keep going
    JSR PRINT_CMPI
    MOVE.L D2,D1
    LSL #8,D1
    LSR #8,D1                   ;find our size
    LSR #6,D1
    CMP.L #0,D1
    BNE LONG_SEG                ;if we are not byte mabye long?
    MOVE.B #0,D4        ;potential necicary information for EA
    
    JSR PRINT_LONG
    JSR PRINT_SPACE
    
    JSR PRINT_VALUE
    
    BRA EA_SEG                  ;go to ea
LONG_SEG CMP.L #2,D0            ;are we long? no? then word
    BNE WORD_SEG
    MOVE.B #3,D4        ;potential necicary information for EA
    
    JSR PRINT_LONG
    JSR PRINT_SPACE
    
    JSR PRINT_VALUE
    
    BRA EA_SEG                  ;branch to ea
WORD_SEG 
    MOVE.B #2,D4        ;potential necicary information for EA
    
    JSR PRINT_LONG
    JSR PRINT_SPACE
    
    JSR PRINT_WORD
    
    BRA EA_SEG
EA_SEG 
    JSR PRINT_SPACE
    MOVEM D0-D3,-(SP)           ;back up data
    LEA EA_TEXT,A1              ;branch to ea
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0-D3           ;back up data
*--------------------------OR--------------------------------
OR_SEG
    MOVE.L D2,D1                ;Copy data
    LSR #4,D1                   ;Keep moving the bit over untill we get what we want only
    LSR #4,D1                   ;we only care about the first 4 bits so everything else
    LSR #4,D1                   ;is worthless
    CMP.L #8,D1                 ;see if we are OR
    BNE ORI_SEG                 ;start decompiling OR

                                ;We found that this is indeed OR so print it out 
                                ;we also know that a . will follow regardless of 
                                ;if the origional code specified
    JSR PRINT_OR
    MOVE.L D2,D1

    LSL #4, D1                  ;here we are getting rid of all didgets except
    LSL #3, D1                  ;the OP Mode information
    LSR #4, D1                  ;after errasing the mode and register shift it back
    LSR #3, D1                  ;for future calculations
    LSR #4, D1                  ;errase Effective address
    LSR #2, D1
    
    CMP.B BYTE_VAL_ONE, D1      ;these two compares tell if we are a byte mode
    BEQ OR_BYTE_PRINT_V1           ;there are two ways the input can be used
    CMP.B BYTE_VAL_TWO, D1      ;V1 is if the EA comes first
    BEQ OR_BYTE_PRINT_V2           ;V2 is if the register comes first
    
    CMP.B LONG_VAL_ONE, D1      ;thse two compares tell if we are in a long mode
    BEQ OR_LONG_PRINT_V1           ;this is the same code as the byte section but for longs
    CMP.B LONG_VAL_TWO, D1
    BEQ OR_LONG_PRINT_V2
    
    CMP.B WORD_VAL_ONE, D1      ;these two compares tell if we are in a word mode
    BEQ OR_WORD_PRINT_V1           ;same section as for others but for word
    CMP.B WORD_VAL_TWO, D1
    BEQ OR_WORD_PRINT_V2
    
OR_REG_SEG_V1  
    MOVEM D0-D3,-(SP)           ;back up data
    LEA EA_TEXT,A1      ;this section is for printing out the register and EA
    MOVE.B #14,D0               ;if the EA came first
    TRAP #15
    MOVEM (SP)+,D0-D3                   ;restore data
    JSR COMMA_TEXT
    
    MOVE.L D2,D1                ;get back the orgional data so we can see
    LSL #4, D1                  ;what register we are in
    LSR #4, D1                  ;errase the opearnd mode
    LSR #3, D1                  ;errase EA and op mode to find what regisster
    LSR #6, D1                  ;we are using
    
    JSR PRINT_REG
    
    JSR PRINT_D1
    BRA END_SEG                  ;we are done with this command
OR_REG_SEG_V2  MOVE.L D2,D1         ;get back the orgional data so we can see
    LSL #4, D1                   ;delete the operand mode
    LSR #4, D1
    LSR #3, D1                   ;delete the EA and OP mode
    LSR #6, D1                   ;we only need the register value
   
    JSR PRINT_REG
    
    JSR PRINT_D1

    JSR PRINT_COMMA
    
    MOVEM D0-D3,-(SP)            ;back up data     
    LEA EA_TEXT,A1               ;print out EA to signle for EA guy
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0-D3           ;restore data
    BRA END_SEG
* Put program code here
OR_BYTE_PRINT_V1  
    MOVE.B #0,D4        ;potential necicary information for EA
    
    JSR PRINT_BYTE
    JSR PRINT_SPACE
    
    BRA OR_REG_SEG_V1                  ;go to the proper way to pring out register and EA
OR_LONG_PRINT_V1  
    MOVE.B #3,D4        ;potential necicary information for EA
    
    JSR PRINT_LONG
    JSR PRINT_SPACE
   
    BRA OR_REG_SEG_V1                  ;go to the proper way to pring out register and EA
OR_WORD_PRINT_V1  
    MOVE.B #2,D4        ;potential necicary information for EA
    
    JSR PRINT_WORD
    JSR PRINT_SPACE
   
    BRA OR_REG_SEG_V1                  ;go to the proper way to pring out register and EA
OR_BYTE_PRINT_V2  
    MOVE.B #0,D4        ;potential necicary information for EA
    
    JSR PRINT_BYTE
    JSR PRINT_SPACE
   
    BRA OR_REG_SEG_V2                  ;go to the proper way to pring out register and EA
OR_LONG_PRINT_V2  
    MOVE.B #3,D4        ;potential necicary information for EA
   
    JSR PRINT_LONG
    JSR PRINT_SPACE
    
    BRA OR_REG_SEG_V2                  ;go to the proper way to pring out register and EA
OR_WORD_PRINT_V2  
    MOVE.B #2,D4        ;potential necicary information for EA
    
    JSR PRINT_WORD
    JSR PRINT_SPACE
   
    BRA OR_REG_SEG_V2                  ;go to the proper way to pring out register and EA
    
*-----------------------------ORI--------------------------------------
ORI_SEG    
    MOVE.L D2,D1
    CMP.L  ORI_TO_CCR_VALUE,D2      ;compare to see if we are using CCR
    BEQ ORI_TO_CCR                  ;if we are skip to that section
        
    MOVE.L D2, D1                   ;copy input to maintain purity
    LSR #8,D1                       ;get rid of any extra data
    CMP.L  ORI_VALUE, D1            ;see if we are an ORI
    BNE LAST_SEG                     ;if not we are done here
    
    JSR PRINT_ORI                

    MOVE.L D2,D1
    LSL #8, D1
    LSR #8,D1
    LSL #4,D1

    CMP.L #0, D1
    BNE ORI_LONG_SEG
    
    MOVE.B #0,D4        ;potential necicary information for EA
    
    JSR PRINT_BYTE   
    BRA ORI_AFTER_SIZE_SEG

ORI_LONG_SEG    CMP.L #1,D1
    BNE ORI_WORD_SEG
    MOVE.B #3,D4        ;potential necicary information for EA
    JSR PRINT_LONG   
    BRA ORI_AFTER_SIZE_SEG
    
ORI_WORD_SEG    
    MOVE.B #2,D4        ;potential necicary information for EA
    JSR PRINT_WORD   
    
    
ORI_AFTER_SIZE_SEG    
    JSR PRINT_SPACE
    MOVEM D0-D7/A0-A7,-(SP)          ;back up data
    *Hand of to EA, this call is temparary
    JSR PRINT_VALUE                 ;EA guy needs to grab our value here
    MOVEM (SP)+,D0-D7/A0-A7
    JSR PRINT_COMMA                 
    MOVEM D0-D7/A0-A7,-(SP)         ;back up data
    LEA EA_TEXT,A1                  ;Here we will hand off to EA guy and he will print any EA
    MOVE.B #14,D0               
    TRAP #15   
    MOVEM (SP)+,D0-D7/A0-A7
                                 
    BRA END_SEG                     ;we are done with the program
ORI_TO_CCR  
    JSR PRINT_ORI                  
    
    JSR PRINT_SPACE    
    MOVEM D0-D7/A0-A7,-(SP)          ;back up data
    *Hand of to EA, this call is temparary
    JSR PRINT_VALUE                 ;EA guy needs to grab our value here
    MOVEM (SP)+,D0-D7/A0-A7   
    
    JSR PRINT_COMMA
    
    JSR PRINT_CCR           
    BRA END_SEG
*----------------------------------------------------------------------
*The functions bellow are callee saved functions that do basic things
*such as print. The idea is to reduce over all code lenght and 
*readability
PRINT_LONG:                         
    MOVEM D0/A0-A1,-(SP)            ;back up any data we might step on
    LEA LONG_TEXT,A1                ;print out .L
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_WORD:                        
    MOVEM D0/A0-A1,-(SP)            ;back up any data we might step on
    LEA WORD_TEXT,A1                ;print out .W
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_BYTE:                        
    MOVEM D0/A0-A1,-(SP)            ;back up any data we might step on
    LEA BYTE_TEXT,A1                ;print out .B
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_SPACE:
    MOVEM D0/A0-A1,-(SP)            ;back up any data we might step on
    LEA SPACE_TEXT,A1                ;print out SPACE
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_COMMA:
    MOVEM D0/A0-A1,-(SP)            ;back up any data we might step on
    LEA COMMA_TEXT,A1                ;print out ,
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_REG:
    MOVEM D0/A0-A1,-(SP)            ;back up any data we might step on
    LEA REG_TEXT,A1                ;print out D
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_VALUE:
    MOVEM D0/A0-A1,-(SP)            ;back up any data we might step on
    LEA COMMA_TEXT,A1                ;print out #
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_NOP:
    MOVEM D0/A0-A1,-(SP)            ;back up any data we might step on
    LEA NOP_TEXT,A1                ;print out NOP
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_JSR:
    MOVEM D0/A0-A1,-(SP)            ;back up any data we might step on
    LEA JSR_TEXT,A1                ;print out JSR
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_RTS:
    MOVEM D0/A0-A1,-(SP)            ;back up any data we might step on
    LEA RTS_TEXT,A1                ;print out RTS
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_LS:
    MOVEM D0/A0-A1,-(SP)            ;back up any data we might step on
    LEA LS_TEXT,A1                ;print out LS
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_AS:
    MOVEM D0/A0-A1,-(SP)            ;back up any data we might step on
    LEA AS_TEXT,A1                ;print out AS
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_RO:
    MOVEM D0/A0-A1,-(SP)            ;back up any data we might step on
    LEA RO_TEXT,A1                ;print out RO
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_RIGHT:
    MOVEM D0/A0-A1,-(SP)            ;back up any data we might step on
    LEA RIGHT_TEXT,A1                ;print out R
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_LEFT:
    MOVEM D0/A0-A1,-(SP)            ;back up any data we might step on
    LEA LEFT_TEXT,A1                ;print out L
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_LEA:
    MOVEM D0/A0-A1,-(SP)            ;back up any data we might step on
    LEA LEA_TEXT,A1                ;print out LEA
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_CCR:
    MOVEM D0/A0-A1,-(SP)            ;back up any data we might step on
    LEA CCR_TEXT,A1                ;print out CCR
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_SR:
    MOVEM D0/A0-A1,-(SP)            ;back up any data we might step on
    LEA SR_TEXT,A1                ;print out SR
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_MOVE:
    MOVEM D0/A0-A1,-(SP)            ;back up any data we might step on
    LEA MOVE_TEXT,A1                ;print out MOVE
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_MOVEM:
    MOVEM D0/A0-A1,-(SP)            ;back up any data we might step on
    LEA MOVEM_TEXT,A1                ;print out MOVEM
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_LIST:
    MOVEM D0/A0-A1,-(SP)            ;back up any data we might step on
    LEA LIST_TEXT,A1                ;print out <LIST>
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_NEG:
    MOVEM D0/A0-A1,-(SP)            ;back up any data we might step on
    LEA NEG_TEXT,A1                ;print out NEG
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_BRA:
    MOVEM D0/A0-A1,-(SP)            ;back up any data we might step on
    LEA BRA_TEXT,A1                ;print out BRA
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_BCC:
    MOVEM D0/A0-A1,-(SP)            ;back up any data we might step on
    LEA COMMA_TEXT,A1                ;print out BCC
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_MULS:
    MOVEM D0/A0-A1,-(SP)            ;back up any data we might step on
    LEA MULS_TEXT,A1                ;print out MULS
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_DIVS:
    MOVEM D0/A0-A1,-(SP)            ;back up any data we might step on
    LEA DIVS_TEXT,A1                ;print out DIVS
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_CMP:
    MOVEM D0/A0-A1,-(SP)            ;back up any data we might step on
    LEA CMP_TEXT,A1                ;print out CMP
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_CMPI:
    MOVEM D0/A0-A1,-(SP)            ;back up any data we might step on
    LEA CMPI_TEXT,A1                ;print out CMPI
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_ORI:
    MOVEM D0/A0-A1,-(SP)            ;back up any data we might step on
    LEA ORI_TEXT,A1                ;print out ORI
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_OR:
    MOVEM D0/A0-A1,-(SP)            ;back up any data we might step on
    LEA OR_TEXT,A1                ;print out OR
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_SUB:
    MOVEM D0/A0-A1,-(SP)            ;back up any data we might step on
    LEA SUB_TEXT,A1                ;print out SUB
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_SUBQ:
    MOVEM D0/A0-A1,-(SP)            ;back up any data we might step on
    LEA SUBQ_TEXT,A1                ;print out SUBQ
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_ADD:
    MOVEM D0/A0-A1,-(SP)            ;back up any data we might step on
    LEA ADD_TEXT,A1                ;print out ADD
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_ADD_REG:
    MOVEM D0/A0-A1,-(SP)            ;back up any data we might step on
    LEA ADD_REG_TEXT,A1                ;print out A
    MOVE.B #14,D0
    TRAP #15
    MOVEM (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_D1:                           ;assumes data is in D1, common for printing data in OP CODE
    MOVEM D0/A0-A1,-(SP)            ;back up any data we might step on
    MOVE #3,D0
    TRAP #15
    MOVEM (SP)+,D0/A0-A1            ;restore any data
    RTS
*-----------------------------------------------------------------
END_SEG    SIMHALT             ; halt simulator




SAMPLE_INPUT DC.L $2439
*Bellow this line are variables for each op code
*-----------------------------------------------------------------
NOP_VALUE DC.L $4E71
NOP_TEXT DC.B 'NOP',0
*-----------------------------------------------------------------
JSR_VALUE DC.L $13A
JSR_TEXT DC.B 'JSR',0
*-----------------------------------------------------------------
RTS_TEXT DC.B 'RTS',0
RTS_VALUE DC.L $4E75
*-----------------------------------------------------------------
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
*-----------------------------------------------------------------
LEA_VALUE DC.L $41C0
LEA_TEXT DC.B 'LEA',0
*-----------------------------------------------------------------
CCR_TEXT DC.B ' CCR',0
*CCR,EA
MOVE_FROM_CCR_VALUE DC.L $42C0
*EA,CCR
MOVE_TO_CCR_VALUE DC.L $44C0
SR_TEXT DC.B ' SR',0
*SR,EA
MOVE_FROM_SR_VALUE DC.L $40C0
*EA,An
MOVEA_VALUE DC.L $0040
*EA,EA
MOVE_MIN_VALUE DC.L $1000
*LIST,EA; EA,LIST
MOVEM_VALUE DC.L $4880
MOVE_TEXT DC.B 'MOVE',0
MOVEM_TEXT DC.B 'MOVEM',0
LIST_TEXT DC.B ' <LIST>',0
*-----------------------------------------------------------------
NEG_VALUE DC.L $0044
NEG_TEXT DC.B 'NEG',0
*-----------------------------------------------------------------
BRA_VALUE DC.L $60
BRA_TEXT DC.B 'BRA ',0
BCC_VALUE DC.L $6
BCC_TEXT DC.B 'BCC ',0
*-----------------------------------------------------------------
MULS_VALUE DC.L $C1C0
MULS_TEXT DC.L 'MULS ',0
DIVS_VALUE DC.L $81C0
DIVS_TEXT DC.L 'DIVS ',0
*-----------------------------------------------------------------
CMP_TEXT DC.B 'CMP',0
CMP_VALUE DC.L $B000
*-----------------------------------------------------------------
ORI_VALUE DC.L $0000
ORI_TEXT DC.B 'ORI', 0
ORI_TO_CCR_VALUE DC.L $003C
*-----------------------------------------------------------------
ADDA_LONG_VALUE DC.L $7
ADDA_WORD_VALUE DC.L $3
ADD_BYTE_V1 DC.L $0
ADD_WORD_V1 DC.L $1
ADD_LONG_V1 DC.L $2

ADD_BYTE_V2 DC.L $4
ADD_WORD_V2 DC.L $5
ADD_LONG_V2 DC.L $6
SUB_VALUE DC.L $9000
SUB_TEXT DC.B 'SUB',0
*#,EA
SUB_QUICK_VALUE DC.L $5100
SUBQ_TEXT DC.B 'SUBQ',0
ADD_VALUE DC.L $D000
ADD_TEXT DC.B 'ADD',0
*-----------------------------------------------------------------
CMPI_VALUE DC.L $0C00
CMPI_TEXT DC.B 'CMPI',0
*-----------------------------------------------------------------
OR_TEXT DC.B 'OR',0
BYTE_VAL_ONE DC.B $0
BYTE_VAL_TWO DC.B $4
WORD_VAL_ONE DC.B $1
WORD_VAL_TWO DC.B $5
LONG_VAL_ONE DC.B $2
LONG_VAL_TWO DC.B $6
*-----------------------------------------------------------------
ADD_REG_TEXT DC.B 'A',0
EA_TEXT DC.B 'EA',0
COMMA_TEXT DC.B ',',0
SPACE_TEXT DC.B ' ',0
VALUE_TEXT DC.B '#',0
REG_TEXT DC.B 'D',0
BYTE_TEXT DC.B '.B',0
LONG_TEXT DC.B '.L',0
WORD_TEXT DC.B '.W',0

* Put variables and constants here

    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
