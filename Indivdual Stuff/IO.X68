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
START:                  ; first instruction of program
        LEA     STACK, SP           *Get the stak pointer
        MOVE.L  #buffer,A1
        *JSR     GET_START_ADDR
        *JSR     GET_ENDING_ADDR
        JSR DISPLAY_COMMAND
        RTS
        
            
*/////////////////////SUBROUTINES/////////////////////////
DATA_LOOP
        MOVE.W (A4)+,D3    
        CMP.L   A4,A5
        BEQ     DONE  

PRINT           
        MOVE.B  #$00,(A1)                 * Terminate the string
        CLR.L   D0                        * Clear D0   
        MOVE.B  #14,D0                    * Load task number 14 for printing
        LEA     buffer,A1                 * Load the buffer into A1 
        TRAP    #15                       * Print the buffer              
        RTS

*TEST FOR PRINT SUBROUTINE
DISPLAY_COMMAND 
        CLR.L   D2
        MOVE.B  #'D',(A1)+
        MOVE.B  #'A',(A1)+  
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
        ADD.B   #1,D0       *add to the character count 
        
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
        CMPI    #$0,D1              *Check if less than 0 chars
        BLE     INPUT_TOO_SHORT
        CMPI    #$8,D1              *Check if more than 8 chars
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
    END    START        ; last line of source
   










*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
