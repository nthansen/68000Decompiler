*-----------------------------------------------------------
* Title      :
* Written by : Konstantin Stekhov
* Date       : 11/20/2014
* Description: Gets input starting address and ending address
*              and loops thorough those
*-----------------------------------------------------------
CR      EQU $0D
LF      EQU $0A  
BYTE    EQU $1
STACK   EQU $7000               * Stack address
BEGIN   EQU $00007000
END     EQU $00FFFFFE   
    
    ORG    $1000
    
* MODE

MDRD      EQU     %000    *  Dn
MARD      EQU     %001    *  An
MARI      EQU     %010    * (An)
MARIP     EQU     %011    * (An)+
MARIM     EQU     %100    * -(An)
MAWA      EQU     %111    * (xxx).W
MALA      EQU     %111    * (xxx).L
MID       EQU     %111    * #<data>

* REGISTER

RAWA      EQU     %000    * (xxx).W
RALA      EQU     %001    * (xxx).L
RID       EQU     %100    * #<data>

ADD       EQU     %0011001111111100 * 00 SIZE 11 DEST REG 010 DEST MODE 001 SOURCE MODE 111 SOURCE REG 011

START:                  ; first instruction of program
        LEA     STACK, SP           *Get the stak pointer
        
        JSR     GET_START_ADDR
        JSR     GET_ENDING_ADDR
        CLR.L   D1                  * Clear D1
        CLR.L   D2                  * Clear D2
        CLR.L   D3                  * Clear D3
        CLR.L   D5                  * Clear D5
        CLR.L   D6                  * Clear D6
        CLR.L   D7                  * Clear D7
        JSR     DATA_LOOP
        *JSR DISPLAY_COMMAND
        RTS
        
            
*/////////////////////SUBROUTINES/////////////////////////
DATA_LOOP
        CMP.L   A4,A5
        BEQ     DONE
        MOVE.W (A4)+,D3
        JSR DECODE_OPCODE
        BRA DATA_LOOP  

PRINT           
        MOVE.B  #$00,(A1)                 * Terminate the string
        CLR.L   D0                        * Clear D0   
        MOVE.B  #13,D0                    * Load task number 13 for printing
        LEA     buffer,A1                 * Load the buffer into A1 
        TRAP    #15                       * Print the buffer              
        RTS

*TEST FOR PRINT SUBROUTINE
DISPLAY_COMMAND 
        CLR.L   D2
        MOVE.L  #buffer,A1
        MOVE.B  #'D',(A1)+
        MOVE.B  #'A',(A1)+
        MOVE.B  #' ',(A1)+  
        BRA     PRINT
        RTS

*NOT MINE        
hex_to_ascii    
    ANDI.L  #$000000FF,D1                   * Isolate the size
    CMP.B   #4,D1                           * Compare the size to 4
    BGT     hta_error                       * Error if the size is > 4
    CMP.B   #0,D1                           * Compare the size to 0
    BLE     hta_error                       * Error if the size < 0
    MOVEM.L D0/D2-D3,-(A7)                  * Push the register data onto the stack
    ROL.L   #1,D1                           * Rotate left by 1 to multiply the size by 2
    MOVE.L  D1,D3                           * Save the counter into D3
                
hta_loop        
    MOVE.L  D0,D2                           * Copy data at D0 into D2
    ANDI.B  #%00001111,D2                   * Select the first ASCII character in D2
    CMP.B   #9,D2                           * Compare the character to 9
    BLE     hta_number                      * Branch to hex number if <= 9
    ADDI    #55,D2                          * If letter, add 55 to make it an ASCII value
    BRA     hta_continue                    * Branch to stack operation
                
hta_number      
    ADDI    #48,D2                          * If number, add 48 to make it an ASCII value

hta_continue    
    MOVE.B  D2,-(A7)                        * Add the ASCII value to the stack
    ROR.L   #4,D0                           * Rotate right by 4 to get the next character
    SUBI    #1,D1                           * Subtract 1 from the counter
    CMP.B   #0,D1                           * Compare the counter to 0
    BNE     hta_loop                        * Branch to convert the next character if counter is not 0
                
hta_result      
    MOVE.B  (A7)+,(A1)+                     * Retrieve ASCII values from the stack and put them in A1
    SUBI    #1,D3                           * Subtract 1 from the counter
    CMP.B   #0,D3                           * Compare the counter to 0
    BNE     hta_result                      * Branch to retrieve the next character if counter is not 0
    MOVEM.L (A7)+,D0/D2-D3                  * Retrieve original data for the register

hta_finish      
    RTS                                     * Return
    
*////////////////////////////////////////////////////////////////////////////////////////
*odd_error: The provided address was odd, so print an error and return a -1 for the address.
*////////////////////////////////////////////////////////////////////////////////////////
hta_error       
*    LEA     hta_error_msg,A1                * Assign hex to ascii error message into A1
    LEA     'sdf',A1
    MOVE.B  #14,D0                          * Assign task code for message into D0
    TRAP    #15                             * Display message
    RTS                                     * Return

*END NOT MINE

GET_START_ADDR
        LEA     INPUT_MSG_START,A1 *Load the start message in A1
        MOVE.B  #14,D0             *Display the message
        TRAP    #15
        
        LEA     START_ADDR,A1      *Load the Start address variable
        MOVE.B  #2,D0              *The starting address input in D1
        TRAP    #15
        
        CLR.L   D1
        JSR     CONVERT_ONE_CHAR_TO_HEX
        JSR     VALID_SIZE
        JSR     CHECK_IF_EVEN
        JSR     CHECK_BOUNDS
        MOVEA.L D3,A4
        
        CLR.L   D1                  * Clear D1
        CLR.L   D2                  * Clear D2
        CLR.L   D3                  * Clear D3
        CLR.L   D5                  * Clear D5
        
        RTS 

GET_ENDING_ADDR        
        LEA     INPUT_MSG_END,A1   *Load the end message in A1
        MOVE.B  #14,D0             *Display the message
        TRAP    #15
        
        LEA     END_ADDR,A1        *Load the end address variable
        MOVE.B  #2,D0              *The ending address input in D1
        TRAP    #15       
        
        CLR.L   D1
        JSR     CONVERT_ONE_CHAR_TO_HEX
        JSR     VALID_SIZE
        JSR     CHECK_IF_EVEN
        JSR     CHECK_BOUNDS      
        
        CMP.L   A4,D3               * Compare address to lower address
        BLE     WRONG_INPUT         * Error if address is below or equal starting address
        MOVE.L  D3,A5
        
        CLR.L   D1                  * Clear D1
        CLR.L   D2                  * Clear D2
        CLR.L   D3                  * Clear D3
        CLR.L   D5                  * Clear D5         
        RTS

CONVERT_ONE_CHAR_TO_HEX
        MOVE.B  (A1)+, D2   *Get character in D2
        ADD.B   #1,D1       *add to the character count 
        
        CMP.B   #0, D2      *Compare it to null
        BEQ     STRING_END
        CMP.B   #70, D2     *If greater than higest upercase      
        BGT     WRONG_INPUT
        CMP.B   #64, D2     *If greater than lowest upercase
        BGT     UPPER_HEX
        CMP.B   #96, D2     *If greater than lowest lowercase
        BGT     WRONG_INPUT
        CMP.B   #102,D2     *If greater than highest character
        BGT     WRONG_INPUT
        CMP.B   #57, D2     *If greater than highest decimal
        BGT     WRONG_INPUT
        CMP.B   #48, D2     *If lower than lowest decimal
        BLT     WRONG_INPUT 
        SUBI.B  #48, D2     *Get hex value
        BRA     DECODED

UPPER_HEX
        SUBI.B  #55,D2      *Get hex value
         
DECODED         
        ASL.L   #4, D3
        ADD.B   D2, D3                  *Move the result into D3
        BRA     CONVERT_ONE_CHAR_TO_HEX *Go to the next one
 
STRING_END
        RTS        

VALID_SIZE
        SUB     #1,D1
        CMPI    #0,D1              *Check if less than 0 chars
        BLE     INPUT_TOO_SHORT
        CMPI    #8,D1              *Check if more than 8 chars
        BGT     INPUT_TOO_LONG
        RTS
        *CMP.L   #0,D3               *Check if negative just in case
        *BLE     DISPLAY_NEG_ERR
        
CHECK_BOUNDS
        MOVE.L  #BEGIN,D5          * Assign minimum address bound to D5
        CMP.L   D5,D3              
        BLT     WRONG_INPUT        * Error if address is below minimum D3
        MOVE.L  #END,D5            * Assign maximum address bound to D5
        CMP.L   D5,D3              * Compare address to maximum bound
        BGT     WRONG_INPUT        * Error if address is above maximum
        RTS
        
CHECK_IF_EVEN
        CLR.L   D2              *Clear old value in D2
        CLR.L   D1              *Clear old value in D1
        MOVE.L  #$00000002,D1   *Put 2 in D1
        MOVE.L  D3,D2
        DIVU    D1,D2           *Divide
        SWAP    D2
        CMP.B   #01,D2         *If there is a remainder then display error;
        BEQ     ODD_INPUT
        RTS

;CONVERT_HEX_TO_ASCII
;        ANDI.L  #$000000FF,D1
;        CMP.B   #4,D1             *If size is greater than 4
;        BGT     DISPLAY_BYTE_ERR  *then display incorrect byte size error
;        CMP.B   #0,D1             *If size is less or equal to 0
;        BLE     DISPLAY_BYTE_ERR  *do the same
        
WRONG_INPUT
        LEA     INPUT_ERR,A1
        MOVE.B  #14,D0
        TRAP    #15
        CLR.L   D3
        BRA     GET_START_ADDR

INPUT_TOO_SHORT
        LEA     INPUT_SHORT_ERR,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     GET_START_ADDR

INPUT_TOO_LONG
        LEA     INPUT_LONG_ERR,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     GET_START_ADDR

ODD_INPUT
        LEA     ODD_ERR,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     GET_START_ADDR

DISPLAY_BYTE_ERR
        LEA     BYTE_ERR,A1
        MOVE    #14,D0
        TRAP    #15

DISPLAY_NEG_ERR
        LEA     NEG_ADDR,A1
        MOVE.B  #14,D0
        TRAP    #15
        
        BRA     GET_START_ADDR
        
*////////////////////////////////////////////////////////////////////////////////////////
OPCODE SECTION
*////////////////////////////////////////////////////////////////////////////////////////
        
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
    
    MOVEM.L D0-D3,-(SP)           ;back up data before function call
    JSR GET_SOURCE_REGISTER  
    MOVEM.L (SP)+,D0-D3
    
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
    
    MOVEM.L D0-D3,-(SP)     ;back up data before hand off
    JSR GET_SOURCE_REGISTER    ;hand off to EA to decode where we are LEA
    MOVEM.L (SP)+,D0-D3     ;restore data
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
LEFT_RIGHT    MOVE.L D2,D1                  ;decide if we are left or right
    LSL #7,D1
    LSR #7,D1                               ;git rid of all the data
    LSR #8,D1
    CMP #1,D1
    BNE RIGHT_ONLY                          ;we arn't left so right
    
    JSR PRINT_LEFT
    BRA MEMORY_OR_REGESTER_MODE
RIGHT_ONLY  JSR PRINT_RIGHT
    BRA MEMORY_OR_REGESTER_MODE
MEMORY_OR_REGESTER_MODE    MOVE.L D2,D1     ;are we memeory or regester mode?
    LSR #8,D1
    LSR #1,D1
    AND.L (MEMORY_ROTATE_VALUE),D1          ;bit mask data
    CMP.L MEMORY_ROTATE_VALUE,D1            ;are we memeory?
    BNE SHIFT_REGESTER_SEG 
    MOVE.L D2,D1
    
    MOVEM.L D0-D3,-(SP)                     ;back up data
    JSR GET_SOURCE_REGISTER            ;have EA decode what we are shifting
    MOVEM.L (SP)+,D0-D3                     ;restore data
    BRA END_SEG
SHIFT_REGESTER_SEG   MOVE.L D2,D1           ;restore data
    LSL #8,D1                               ;pre-shifting data
    LSL #2,D1                               ;for latter on
    LSR #8,D1
    LSR #2,D1
    LSL #5,D1
    MOVE.L D2,D3                            ;restore data
    LSL #4,D3                           
    LSR #4,D3
    LSR #8,D3
    LSR #1,D3                               ;figure out something
    CMP #0,D1                               ; *ouch*
    BNE SHIFT_REG_VALUE
    JSR PRINT_VALUE
    BRA FINISH_OUTPUT
SHIFT_REG_VALUE JSR PRINT_VALUE
    BRA FINISH_OUTPUT
    
FINISH_OUTPUT                               ;this segment of code is shared by all shfit code
    MOVE.L D3,D1
    JSR PRINT_D1
    
    MOVE.L D2,D1                            ;shift data around to figure out what reg we are using
    LSL #8,D1
    LSL #5,D1
    LSR #8,D1
    LSR #5,D1                           
    JSR COMMA_TEXT
    JSR PRINT_D1
    BRA END_SEG                             ;we are done here
*------------------------------NEG--------------------------------
NEG_SEG
    MOVE.L D2,D1                            ;copy input to maintain purity
    LSR #8,D1                               ;get rid of data that isn't involved in testing NEG
    CMP.L NEG_VALUE, D1                     ;test to see if we are neg
    BNE MOVES_SEG                           ;if we are not NEG end this
    
    JSR PRINT_NEG
    
    MOVE.L D2,D1                            ;Copy data in
    LSL #8,D1                               ;get rid of the NEG code
    LSR #8,D1
    LSR #6, D1                              ;get rid of the EA code
        
    CMP.L #0,D1                             ;are we dealing with a bit?
    BNE NEG_LONG_SEG                        ;if not go to next test
    
    MOVE.B #0,D4                            ;potential necicary information for EA
    JSR PRINT_BYTE
    JSR PRINT_SPACE
    
    BRA NEG_EA_SEG                          ;mote to teh EA section
NEG_LONG_SEG CMP.L #2,D1                    ;are we a long?
    BNE NEG_WORD_SEG                        ;if not we are a word
    
    MOVE.B #3,D4                            ;potential necicary information for EA
    JSR PRINT_LONG
    JSR PRINT_SPACE
    BRA NEG_EA_SEG                          ;move to EA section
NEG_WORD_SEG 
    MOVE.B #2,D4                            ;potential necicary information for EA
    JSR PRINT_WORD
    JSR PRINT_SPACE
    
    
    BRA NEG_EA_SEG    
NEG_EA_SEG 
    MOVEM.L D0-D3,-(SP)                     ;back up our data
    JSR GET_SOURCE_REGISTER
    MOVEM.L (SP)+,D0-D3
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
    MOVEM.L D0-D3,-(SP)           ;back up data
    JSR GET_DESTINATION_REGISTER
    MOVEM.L (SP)+,D0-D3           ;restore data
    BRA END_SEG
MOVE_TO_CCR_SEG
    ;print out move
    JSR PRINT_MOVE
    JSR PRINT_SPACE
    ;hand off to ea
    MOVE.L D2,D1
    MOVEM.L D0-D3,-(SP)           ;back up data
    JSR GET_SOURCE_REGISTER
    MOVEM.L (SP)+,D0-D3           ;restore data
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
    MOVEM.L D0-D3,-(SP)               ;back up our data
    JSR GET_SOURCE_REGISTER
    MOVEM.L (SP)+,D0-D3               ;restore it
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
    MOVEM.L D0-D3,-(SP)               ;back up data
    JSR GET_SOURCE_REGISTER
    MOVEM.L (SP)+,D0-D3               ;restore data
    JSR PRINT_COMMA 
    JSR PRINT_LIST
    BRA END_SEG
REG_TO_MEM
    
    JSR PRINT_LIST
    JSR PRINT_COMMA
    MOVEM.L D0-D3,-(SP)       ;back up data
    JSR GET_SOURCE_REGISTER   
    MOVEM.L (SP)+,D0-D3       ;restore data
    BRA END_SEG

MOVE_F_SR_SEG       
    JSR PRINT_MOVE
    MOVE.L D2,D1
    JSR PRINT_SPACE
    JSR PRINT_SR
    JSR PRINT_COMMA
    MOVEM.L D0-D3,-(SP)   ;back up data
    JSR GET_SOURCE_REGISTER
    MOVEM.L (SP)+,D0-D3   ;restore data
    BRA END_SEG
*-----------------------------LAST--------------------------------
LAST_SEG
    ;see if we are a move
    MOVE.L D2,D1
    AND.L (MOVE_MIN_VALUE),D1
    CMP.L MOVE_MIN_VALUE,D1
    BEQ MOVE_SEG            ;BGE is used as all moves must be
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
    MOVEM.L D0-D3,-(SP)   ;back up data
    JSR GET_SOURCE_REGISTER
    MOVEM.L (SP)+,D0-D3       ;restore data
    JSR PRINT_COMMA
    MOVEM.L D0-D3,-(SP)       ;back up data
    JSR GET_DESTINATION_REGISTER
    MOVEM.L (SP)+,D0-D3       ;restore data
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
    MOVEM.L D0-D3,-(SP)           ;back up data
    JSR GET_SOURCE_REGISTER
    MOVEM.L (SP)+,D0-D3           ;restore data
    
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
    BNE LAST_SEG
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
    MOVEM.L D0-D3,-(SP)           ;back up data
    JSR GET_SOURCE_REGISTER
    MOVEM.L (SP)+,D0-D3           ;restore data
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
    BRA LAST_SEG
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
    MOVEM.L D0-D3,-(SP)   ;back up data
    JSR GET_SOURCE_REGISTER
    MOVEM.L (SP)+,D0-D3       ;restore data
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
    MOVEM.L D0-D3,-(SP)                   ;back up data
    JSR GET_SOURCE_REGISTER
    MOVEM.L (SP)+,D0-D3
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
    MOVEM.L D0-D3,-(SP)               ;back up data
    JSR GET_SOURCE_REGISTER
    MOVEM.L (SP)+,D0-D3               ;restore data
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
    MOVEM.L D0-D3,-(SP)               ;back up datat
    JSR GET_SOURCE_REGISTER
    MOVEM.L (SP)+,D0-D3               ;restore data
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
    
    JSR GET_IMMEDIATE_VALUE
    
    BRA EA_SEG                  ;go to ea
LONG_SEG CMP.L #2,D0            ;are we long? no? then word
    BNE WORD_SEG
    MOVE.B #3,D4        ;potential necicary information for EA
    
    JSR PRINT_LONG
    JSR PRINT_SPACE
    
    JSR GET_IMMEDIATE_VALUE
    
    BRA EA_SEG                  ;branch to ea
WORD_SEG 
    MOVE.B #2,D4        ;potential necicary information for EA
    
    JSR PRINT_WORD
    JSR PRINT_SPACE
    
    JSR GET_IMMEDIATE_VALUE
    
    BRA EA_SEG
EA_SEG 
    JSR PRINT_SPACE
    MOVEM.L D0-D3,-(SP)           ;back up data
    JSR GET_SOURCE_REGISTER
    MOVEM.L (SP)+,D0-D3           ;back up data
    BRA END_SEG
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
    MOVEM.L D0-D3,-(SP)           ;back up data
    JSR GET_SOURCE_REGISTER
    MOVEM.L (SP)+,D0-D3                   ;restore data
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
    
    MOVEM.L D0-D3,-(SP)            ;back up data     
    JSR GET_SOURCE_REGISTER
    MOVEM.L (SP)+,D0-D3           ;restore data
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
    BNE ADD_SUB_SEG                     ;if not we are done here
    
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
    JSR GET_IMMEDIATE_VALUE                 ;EA guy needs to grab our value here
    MOVEM.L (SP)+,D0-D7/A0-A7
    JSR PRINT_COMMA                 
    MOVEM.L D0-D7/A0-A7,-(SP)         ;back up data
    JSR GET_SOURCE_REGISTER   
    MOVEM.L (SP)+,D0-D7/A0-A7
                                 
    BRA END_SEG                     ;we are done with the program
ORI_TO_CCR  
    JSR PRINT_ORI                  
    
    JSR PRINT_SPACE    
    MOVEM.L D0-D7/A0-A7,-(SP)          ;back up data
    *Hand of to EA, this call is temparary
    JSR GET_IMMEDIATE_VALUE                ;EA guy needs to grab our value here
    MOVEM.L (SP)+,D0-D7/A0-A7   
    
    JSR PRINT_COMMA
    
    JSR PRINT_CCR           
    BRA END_SEG
*----------------------------------------------------------------------
*The functions bellow are callee saved functions that do basic things
*such as print. The idea is to reduce over all code lenght and 
*readability
PRINT_LONG:                         
    MOVEM.L D0/A0-A1,-(SP)            ;back up any data we might step on
    MOVE.B LONG_TEXT,(A6)+                ;print out .L
    MOVEM.L (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_WORD:                        
    MOVEM.L D0/A0-A1,-(SP)            ;back up any data we might step on
    MOVE.B WORD_TEXT,(A6)+                ;print out .W
    MOVEM.L (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_BYTE:                        
    MOVEM.L D0/A0-A1,-(SP)            ;back up any data we might step on
    MOVE.B BYTE_TEXT,(A6)+                ;print out .B
    MOVEM.L (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_SPACE:
    MOVEM.L D0/A0-A1,-(SP)            ;back up any data we might step on
    MOVE.B SPACE_TEXT,(A6)+                ;print out SPACE
    MOVEM.L (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_COMMA:
    MOVEM.L D0/A0-A1,-(SP)            ;back up any data we might step on
    MOVE.B COMMA_TEXT,(A6)+                ;print out ,
    MOVEM.L (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_REG:
    MOVEM.L D0/A0-A1,-(SP)            ;back up any data we might step on
    MOVE.B REG_TEXT,(A6)+                ;print out D
    MOVEM.L (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_VALUE:
    MOVEM.L D0/A0-A1,-(SP)            ;back up any data we might step on
    MOVE.B COMMA_TEXT,(A6)+                ;print out #
    MOVEM.L (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_NOP:
    MOVEM.L D0/A0-A1,-(SP)            ;back up any data we might step on
    MOVE.B NOP_TEXT,(A6)+                ;print out NOP
    MOVEM.L (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_JSR:
    MOVEM.L D0/A0-A1,-(SP)            ;back up any data we might step on
    MOVE.B (JSR_TEXT),(A6)+                ;print out JSR
    MOVEM.L (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_RTS:
    MOVEM.L D0/A0-A1,-(SP)            ;back up any data we might step on
    MOVE.B RTS_TEXT,(A6)+                ;print out RTS
    MOVEM.L (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_LS:
    MOVEM.L D0/A0-A1,-(SP)            ;back up any data we might step on
    MOVE.B LS_TEXT,(A6)+                ;print out LS
    MOVEM.L (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_AS:
    MOVEM.L D0/A0-A1,-(SP)            ;back up any data we might step on
    MOVE.B AS_TEXT,(A6)+                ;print out AS
    MOVEM.L (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_RO:
    MOVEM.L D0/A0-A1,-(SP)            ;back up any data we might step on
    MOVE.B RO_TEXT,(A6)+                ;print out RO
    MOVEM.L (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_RIGHT:
    MOVEM.L D0/A0-A1,-(SP)            ;back up any data we might step on
    MOVE.B RIGHT_TEXT,(A6)+                ;print out R
    MOVEM.L (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_LEFT:
    MOVEM.L D0/A0-A1,-(SP)            ;back up any data we might step on
    MOVE.B LEFT_TEXT,(A6)+                ;print out L
    MOVEM.L (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_LEA:
    MOVEM.L D0/A0-A1,-(SP)            ;back up any data we might step on
    MOVE.B LEA_TEXT,(A6)+                ;print out LEA
    MOVEM.L (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_CCR:
    MOVEM.L D0/A0-A1,-(SP)            ;back up any data we might step on
    MOVE.B CCR_TEXT,(A6)+                ;print out CCR
    MOVEM.L (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_SR:
    MOVEM.L D0/A0-A1,-(SP)            ;back up any data we might step on
    MOVE.B SR_TEXT,(A6)+                ;print out SR
    MOVEM.L (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_MOVE:
    MOVEM.L D0/A0-A1,-(SP)            ;back up any data we might step on
    MOVE.B MOVE_TEXT,(A6)+                ;print out MOVE
    MOVEM.L (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_MOVEM:
    MOVEM.L D0/A0-A1,-(SP)            ;back up any data we might step on
    MOVE.B MOVEM_TEXT,(A6)+                ;print out MOVEM
    MOVEM.L (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_LIST:
    MOVEM.L D0/A0-A1,-(SP)            ;back up any data we might step on
    MOVE.B LIST_TEXT,(A6)+                ;print out <LIST>
    MOVEM.L (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_NEG:
    MOVEM.L D0/A0-A1,-(SP)            ;back up any data we might step on
    MOVE.B NEG_TEXT,(A6)+                ;print out NEG
    MOVEM.L (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_BRA:
    MOVEM.L D0/A0-A1,-(SP)            ;back up any data we might step on
    MOVE.B BRA_TEXT,(A6)+                ;print out BRA
    MOVEM.L (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_BCC:
    MOVEM.L D0/A0-A1,-(SP)            ;back up any data we might step on
    MOVE.B COMMA_TEXT,(A6)+                ;print out BCC
    MOVEM.L (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_MULS:
    MOVEM.L D0/A0-A1,-(SP)            ;back up any data we might step on
    MOVE.B MULS_TEXT,(A6)+                ;print out MULS
    MOVEM.L (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_DIVS:
    MOVEM.L D0/A0-A1,-(SP)            ;back up any data we might step on
    MOVE.B DIVS_TEXT,(A6)+                ;print out DIVS
    MOVEM.L (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_CMP:
    MOVEM.L D0/A0-A1,-(SP)            ;back up any data we might step on
    MOVE.B CMP_TEXT,(A6)+                ;print out CMP
    MOVEM.L (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_CMPI:
    MOVEM.L D0/A0-A1,-(SP)            ;back up any data we might step on
    MOVE.B CMPI_TEXT,(A6)+                ;print out CMPI
    MOVEM.L (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_ORI:
    MOVEM.L D0/A0-A1,-(SP)            ;back up any data we might step on
    MOVE.B ORI_TEXT,(A6)+                ;print out ORI
    MOVEM.L (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_OR:
    MOVEM.L D0/A0-A1,-(SP)            ;back up any data we might step on
    MOVE.B OR_TEXT,(A6)+                ;print out OR
    MOVEM.L (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_SUB:
    MOVEM.L D0/A0-A1,-(SP)            ;back up any data we might step on
    MOVE.B SUB_TEXT,(A6)+                ;print out SUB
    MOVEM.L (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_SUBQ:
    MOVEM.L D0/A0-A1,-(SP)            ;back up any data we might step on
    MOVE.B SUBQ_TEXT,(A6)+                ;print out SUBQ
    MOVEM.L (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_ADD:
    MOVEM.L D0/A0-A1,-(SP)            ;back up any data we might step on
    MOVE.B ADD_TEXT,(A6)+                ;print out ADD
    MOVEM.L (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_ADD_REG:
    MOVEM.L D0/A0-A1,-(SP)            ;back up any data we might step on
    MOVE.B ADD_REG_TEXT,(A6)+                ;print out A
    MOVEM.L (SP)+,D0/A0-A1            ;restore any data
    RTS                             ;return to sender
PRINT_D1:                           ;assumes data is in D1, common for printing data in OP CODE
    MOVEM.L D0/A0-A1,-(SP)            ;back up any data we might step on
    ADD #$30,D1
    MOVE.B D1,(A1)+
    MOVEM.L (SP)+,D0/A0-A1            ;restore any data
    RTS
*-----------------------------------------------------------------
END_SEG    SIMHALT             ; halt simulator

GET_DESTINATION_REGISTER
    LEA EA_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    RTS
GET_SOURCE_REGISTER
    LEA EA_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    RTS
GET_IMMEDIATE_VALUE
    LEA EA_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    RTS

        
*////////////////////////////////////////////////////////////////////////////////////////
* EA: This is the section for decoding EA
*////////////////////////////////////////////////////////////////////////////////////////

GETDESTINATIONREG:    
    MOVE.L D3,D1                ; this is for detecting the register
    LSL #4,D1                   ; Remove starting address
    LSR #8,D1                   ; Put back into place
    LSR #5,D1                   ; Remove excess so now it's 010
    MOVE.B D1,D7
    BRA GETDESTINATIONMODE
    
    
GETDESTINATIONMODE:
    MOVE.L D3,D1                ; this is for detecting the mode
    LSL #7,D1                   ; Remove starting address
    LSR #8,D1                   ; Put back into place
    LSR #5,D1                   ; Remove excess so now it's 000
    MOVE.B D1,D6
    LEA RETURNDESTMODE,A0
    JMP PRINT_EA_MODE

RETURNDESTMODE:
    LEA (A3),A0                   ; return to where we are in the op code
    JMP PRINT_EA_REG
    

GETSOURCEMODE:    
    MOVE.L D3,D1                ; this is for detecting the mode
    LSL #8,D1                   ; Remove starting address
    LSL #2,D1                   ; Remove offset
    LSR #8,D1                   ; Put back into place
    LSR #5,D1                   ; Remove register
    MOVE.B D1,D6                ; store in D6 to be used for display
    LEA GETSOURCEREG,A0         ; once finished decode the source reg
    JMP PRINT_EA_MODE
    
GETSOURCEREG:
    MOVE.L D3,D1                ; this is for detecting the register
    LSL #8,D1                   ; Remove starting address
    LSL #5,D1                   ; Remove offset
    LSR #8,D1                   ; Put back into place
    LSR #5,D1                   ; Remove excess 
    MOVE.B D1,D7                ; store in D7 to be used for display
    LEA (A3),A0                   ; Once finished jump to where we are in op code
    JMP PRINT_EA_REG
        

PRINT_EA_MODE:
    CMP.B #MDRD,D6  
    BEQ PRINT_EA_DRD                ; Prints out D
    CMP.B #MARD,D6
    BEQ PRINT_EA_ARD                ; Prints out A
    CMP.B #MARI,D6
    BEQ PRINT_EA_ARI                ; Prints out (A                
    CMP.B #MARIP,D6
    BEQ PRINT_EA_ARIP               ; Prints out (A
    CMP.B #MARIM,D6
    BEQ PRINT_EA_ARIM               ; Prints out -(A
    CMP.B #MAWA,D6
    ; NEED TO DO THESE IN THE REGISTER CAUSE THE MODES ALL MATCH
    BEQ PRINT_EA_AWA                ; Prints out (
    CMP.B #MALA,D6
    BEQ PRINT_EA_ALA                ; Prints out (
    CMP.B #MID,D6
    BEQ PRINT_EA_ID                 ; Prints out #

PRINT_EA_REG:
    CMP.B   #MDRD,D6                ; If the mode is a Dn then we just print the value in the register
    BEQ     PRINT_EA_REG_VALUE
    CMP.B   #MARD,D6                ; If the mode is a An then we just print the value in the register
    BEQ     PRINT_EA_REG_VALUE
    CMP.B   #MARI,D6                ; If the mode is a (An) we need to print the reg value and )
    BEQ     PRINT_EA_ARI_REG
    CMP.B   #MARIP,D6               ; If the mode is a (An)+ we need to print the reg value and )+
    BEQ     PRINT_EA_ARIP_REG           
    CMP.B   #MARIM,D6               ; If the mode is a -(SP) we need to print the reg value and )
    BEQ     PRINT_EA_ARI_REG
    CMP.B   #RAWA,D7                ; The reg is a .w so we need to print the address and ).W
    BEQ     PRINT_EA_AWA_REG
    CMP.B   #RALA,D7                ; The reg is a .l so we need to print the address and ).L
    BEQ     PRINT_EA_ALA_REG
    CMP.B   #RID,D7                 ; The reg can be several different lengths so go to our operation and compare address mode, print address and >
    BEQ     PRINT_EA_ID_REG

PRINT_EA_REG_VALUE:
    MOVE.B D7,D1                    ; Move the reg value to the spot to print
    MOVE.B #16,D2                   ; Make sure it's in base 16
    MOVE.B #15,D0                   ; Necessary to print values
    TRAP #15                        ; Print
    JMP (A0)                        ; Jump back to location

PRINT_EA_ARI_REG:
   MOVE.L A0,A2
   LEA PRINT_EA_ARI_REG_END,A0          ; Load the display end part of ARI to address to jump to later
   JMP PRINT_EA_REG_VALUE               ; Display the register value
   
PRINT_EA_ARIP_REG:
    MOVE.L A0,A2
    LEA PRINT_EA_ARIP_REG_END,A0
    JMP PRINT_EA_REG_VALUE
   
   
PRINT_EA_ARI_REG_END:
    LEA ARI_END_TEXT,A1
    MOVE.B  #14,D0
    TRAP #15
    JMP (A2)  
    
PRINT_EA_ARIP_REG_END:
    LEA ARIP_END_TEXT,A1
    MOVE.B  #14,D0
    TRAP #15
    JMP (A2)  
    
PRINT_EA_AWA_REG:
    MOVE.W  (A5)+,D1
    MOVE.B  #15,D0
    MOVE.B  #16,D2
    TRAP    #15    
    LEA     AWA_END_TEXT,A1
    MOVE.B  #14,D0
    TRAP    #15
    JMP     (A0)


PRINT_EA_ALA_REG:
    MOVE.L  (A5)+,D1
    MOVE.B  #15,D0
    MOVE.B  #16,D2
    TRAP    #15 
    LEA     ALA_END_TEXT,A1
    MOVE.B  #14,D0
    TRAP    #15
    JMP     (A0)
        
PRINT_EA_ID_REG:
    CMP.B   #0,D4
    BEQ     PRINT_EA_ID_REG_W
    CMP.B   #2,D4
    BEQ     PRINT_EA_ID_REG_W
    CMP.B   #3,D4
    BEQ     PRINT_EA_ID_REG_L
    
PRINT_EA_ID_REG_W:   
    MOVE.W  (A5)+,D1
    MOVE.B  #15,D0
    MOVE.B  #16,D2
    TRAP    #15
    LEA     ID_END_TEXT,A1
    MOVE.B  #14,D0
    TRAP    #15
    JMP     (A0) 
    
PRINT_EA_ID_REG_L:
    MOVE.L  (A5)+,D1
    MOVE.B  #15,D0
    MOVE.B  #16,D2
    TRAP    #15
    LEA     ID_END_TEXT,A1
    MOVE.B  #14,D0
    TRAP    #15
    JMP     (A0)
    
PRINT_EA_DRD
    LEA DRD_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    JMP (A0)
    
PRINT_EA_ARD
    LEA ARD_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    JMP (A0)
    
PRINT_EA_ARI
    LEA ARI_TEXT,A1
    MOVE.B  #14,D0
    TRAP #15
    JMP (A0)
    
PRINT_EA_ARIP
    LEA ARIP_TEXT,A1
    MOVE.B  #14,D0
    TRAP #15
    JMP (A0)
    
PRINT_EA_ARIM
    LEA ARIM_TEXT,A1
    MOVE.B  #14,D0
    TRAP #15
    JMP (A0)

    
PRINT_EA_ID
    LEA ID_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    JMP (A0)
    
PRINT_EA_ALA
    LEA ALA_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    JMP (A0)
    
PRINT_EA_AWA
    LEA AWA_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    JMP (A0)

DONE
    SIMHALT
        
* Put variables and constants here
NEG_ADDR            DC.B    'Address must be positive',CR,LF,0
INPUT_ERR           DC.B    'The input is wrong',CR,LF,0
INPUT_MSG_START     DC.B    'Please type the starting address: ',CR,LF,0
INPUT_MSG_END       DC.B    'Please type the ending address: ',CR,LF,0
NOT_VALID_ERR       DC.B    'Starting address is larger or equal to ending address',CR,LF,0
BYTE_ERR            DC.B    'Incorrect byte size',CR,LF,0
ODD_ERR             DC.B    'The address is odd',CR,LF,0
INPUT_LONG_ERR      DC.B    'The address is longer than 8 bits',CR,LF,0
INPUT_SHORT_ERR     DC.B    'The address must be longer than 0 bits',CR,LF,0
START_ADDR          DS.B    80
END_ADDR            DS.B    80
BUFFER              DS.B    80   

SAMPLE_INPUT DC.L $D041
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
ORI_TEXT DC.B 'ORI',0
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


 
DRD_TEXT DC.B ' D', 0
ARD_TEXT DC.B ' A',0
ARI_TEXT DC.B ' (A',0
ARIP_TEXT DC.B ' (A',0
ARIM_TEXT DC.B ' -(A',0
ID_TEXT DC.B ' #<',0
ID_END_TEXT DC.B '>',0
ARI_END_TEXT DC.B ') ',0
ARIP_END_TEXT DC.B ')+ ',0
ALA_TEXT DC.B ' (',0
AWA_TEXT DC.B ' (',0
ALA_END_TEXT DC.B ').L',0
AWA_END_TEXT DC.B ').W',0
    


    END    START        ; last line of source
   













*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
