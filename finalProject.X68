*-----------------------------------------------------------
* Title      :
* Written by : Konstantin Stekhov
* Date       : 11/20/2014
* Description: Gets input starting address 
* ending address
*              and loops thorough those
*-----------------------------------------------------------
CR      EQU $0D
LF      EQU $0A  
BYTE    EQU $1
STACK   EQU $7000               * Stack address
BEGIN   EQU $00007000
END     EQU $00FFFFFE   
    
zeroAddr        EQU     $00000000           * Zero out address register
NULL            EQU     $00
TAB             EQU     $09
    
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
        MOVE.W (A4)+,D2
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
    ADDI    #48,D2               -           * If number, add 48 to make it an ASCII value

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
* OPCODE SECTION
*////////////////////////////////////////////////////////////////////////////////////////
        
DECODE_OPCODE
                CLR.L   D0                  * Clear data registers before use
                CLR.L   D1
                CLR.L   D3
                CLR.L   D4
                CLR.L   D5
                CLR.L   D6
                
                MOVE.L  #zeroAddr,A1        * Zero out A1 before use
                MOVE.B  #TAB,(A1)+
                
                MOVE.W  (A5)+,D0            * Store opcode at A5 in D0
                MOVE.W  D0,D1               * Store D0 in D1 to operate on
                
                ANDI.W  #mask15to12,D1      * Mask first 4 bits
                LSR.W   #4,D1               * Shift the first 4 bits to right-most place
                LSR.W   #4,D1
                LSR.W   #4,D1
                
                MOVEM.L D1,-(SP)            * Save D1
                JSR     SPLIT_WORD          * Split the words bits into groups
                MOVEM.L (SP)+,D1            * Restore D1

OPCODE_TABLE
                CMP.B   #%0000,D1           * ADDI, SUBI, EORI, CMPI, BCHG
                BEQ     CODE_0000
                
                CMP.B   #%0001,D1           * MOVE.B
                BEQ     MOVE_INS
                
                CMP.B   #%0011,D1           * MOVE.W
                BEQ     MOVE_INS
                
                CMP.B   #%0010,D1           * MOVE.L
                BEQ     MOVE_INS
                
                CMP.B   #%0100,D1           * CLR, RTS, JSR, MOVEM, and LEA              
                BEQ     CODE_0100
                
                CMP.B   #%0101,D1           * SUBQ (ADDQ, Scc, DBcc are not implemented)
                BEQ     CODE_0101
                
                CMP.B   #%0110,D1           * Bcc (BRA, BSR aren't impl.)
                BEQ     CODE_0110
                
                CMP.B   #%0111,D1           * MOVEQ
                BEQ     CODE_0111
                
                CMP.B   #%1000,D1           * DIVU (DIVS, SBCD, OR not impl.)
                BEQ     CODE_1000
                
                CMP.B   #%1001,D1           * SUB, SUBA (SUBX not impl.)
                BEQ     CODE_1001
                
                CMP.B   #%1011,D1           * EOR, CMP, CMPA (CMPM not impl.)
                BEQ     CODE_1011
                
                CMP     #%1100,D1           * AND, MULS (MULU, ABCD, EXG not impl.)
                BEQ     CODE_1100
                
                CMP.B   #%1101,D1           * ADD, ADDA, ADDX
                BEQ     CODE_1101
                
                CMP     #%1110,D1           * ASR, LSL, ROL, ROR (others not impli.)
                BEQ     CODE_1110
                
INVALID_OPCODE
                MOVEM.L D0/D1,-(SP)         * Save D0
                
                MOVEA.L #zeroAddr,A1        * Zero out A1 before use
                LEA     PRINT_DATA,A1       * Load DATA message
                MOVE.B  #14,D0
                TRAP    #15                 * Print DATA
                
                MOVEM.L (SP)+,D0/D1         * Restore D0
                
                MOVEA.L #zeroAddr,A1        * Zero out A1 before use
                MOVE.B  #4,D2               * Counter for current byte
                
                JSR     DECODE_ADDRESS      * Convert D0 to ASCII and store in D1
                MOVE.L  D1,(A1)+            * Move decoded address to A1
                MOVE.L  #0,A1               * Terminate string with 0
                MOVE.B  #14,D0
                TRAP    #15                 * Print address
                
                BRA     PROCEED

*-----------------------------------------------------------
* CODE_0000
* ADDI, ANDI, SUBI (not required), EORI, CMPI, and BCHG
*
* A5 is the current address
* D0 stores a word of data
* D1 stores the instruction (bits 15 - 12)
* D3 will hold bits 11 - 9
* D4 will hold bits 8 - 6
* D5 will hold bits 5 - 3
* D6 will hold bits 2 - 0
*-----------------------------------------------------------
CODE_0000
                CMP.B   #%100,D4            * possible BCHG instruction if D4 >= 100
                BGE     BCHG_INS_REG
                
                CMP.B   #%001,D3            * ANDI instruction
                BEQ     ANDI_INS
                
                CMP.B   #%011,D3            * ADDI instruction
                BEQ     ADDI_INS
                
                CMP.B   #%100,D3            * BCHG instruction
                BEQ     BCHG_INS
                
                CMP.B   #%101,D3            * EORI instruction
                BEQ     EORI_INS
                
                CMP.B   #%110,D3            * CMPI instruction
                BEQ     CMPI_INS
                
                BRA     INVALID_OPCODE

BCHG_INS_REG
                CMP.B   #%101,D4            * If D3 == 100, D4 must == 101 to be BCHG
                BNE     INVALID_OPCODE
                
                MOVE.B  #'B',(A1)+
                MOVE.B  #'C',(A1)+
                MOVE.B  #'H',(A1)+
                MOVE.B  #'G',(A1)+
                MOVE.B  #TAB,(A1)+
                MOVE.B  #'D',(A1)+
                
                * Decode D3's bits into ASCII
                MOVEM.L D0/D1,-(SP)                 * Save D0/D1 because they'll be used
                MOVE.B  D3,D0
                JSR     CONVERT_REGISTER_TO_ASCII   * !!!: USES D0/D1
                MOVEM.L (SP)+,D0/D1                 * Restore D0/D1
                
                MOVE.B  #',',(A1)+
                
                CMP.B   #%010,D5                * Check for address ending
                BEQ     BCHG_ADDR_DESTINATION
                
                CMP.B   #%011,D5                * Check for address with postincrement ending
                BEQ     BCHG_ADDR_PLUS_DESTINATION
                
                CMP.B   #%100,D5                * CHeck for address with predecrement ending
                BEQ     BCHG_ADDR_MINUS_DESTINATION
                
                CMP.B   #%000,D5                * Check for data register ending
                BEQ     BCHG_DATA_REG_DESTINATION
                
                CMP.B   #%111,D5                * Check for absolute address
                BEQ     BCHG_ABSOLUTE_ADDRESS
                
                BRA     INVALID_OPCODE

BCHG_DATA_REG_DESTINATION
                MOVE.B  #'D',(A1)+                  * Prepare buffer for data register output
                * Decode D6's bits into ASCII
                MOVEM.L D0/D1,-(SP)                 * Save D0/D1 because they'll be used
                MOVE.B  D6,D0
                JSR     CONVERT_REGISTER_TO_ASCII   * !!!: USES D0/D1
                MOVEM.L (SP)+,D0/D1                 * Restore D0/D1
                
                BRA     TEST_OUTPUT

BCHG_ADDR_DESTINATION
                MOVE.B  #'(',(A1)+
                MOVE.B  #'A',(A1)+                  * Prepare buffer for address desination
                * Decode D6's bits into ASCII
                MOVEM.L D0/D1,-(SP)                 * Save D0/D1 because they'll be used
                MOVE.B  D6,D0
                JSR     CONVERT_REGISTER_TO_ASCII   * !!!: USES D0/D1
                MOVEM.L (SP)+,D0/D1                 * Restore D0/D1
                MOVE.B  #')',(A1)+
                BRA     TEST_OUTPUT
                
BCHG_ADDR_PLUS_DESTINATION
                MOVE.B  #'(',(A1)+
                MOVE.B  #'A',(A1)+                  * Prepare buffer for address desination
                * Decode D6's bits into ASCII
                MOVEM.L D0/D1,-(SP)                 * Save D0/D1 because they'll be used
                MOVE.B  D6,D0
                JSR     CONVERT_REGISTER_TO_ASCII   * !!!: USES D0/D1
                MOVEM.L (SP)+,D0/D1                 * Restore D0/D1
                MOVE.B  #')',(A1)+
                MOVE.B  #'+',(A1)+
                
                BRA     TEST_OUTPUT

BCHG_ADDR_MINUS_DESTINATION
                MOVE.B  #'-',(A1)+
                MOVE.B  #'(',(A1)+
                MOVE.B  #'A',(A1)+                  * Prepare buffer for address desination
                * Decode D6's bits into ASCII
                MOVEM.L D0/D1,-(SP)                 * Save D0/D1 because they'll be used
                MOVE.B  D6,D0
                JSR     CONVERT_REGISTER_TO_ASCII   * !!!: USES D0/D1
                MOVEM.L (SP)+,D0/D1                 * Restore D0/D1
                MOVE.B  #')',(A1)+
                
                BRA     TEST_OUTPUT

BCHG_ABSOLUTE_ADDRESS
                CMP.B   #%000,D6                * Short address
                BEQ     BCHG_ABSOLUTE_SHORT
                
                CMP.B   #%001,D6                * Long address
                BEQ     BCHG_ABSOLUTE_LONG
                
                BRA     INVALID_OPCODE

BCHG_ABSOLUTE_SHORT

                MOVE.B  #'$',(A1)+
                MOVE.B  #0,(A1)+            * Terminate string with 0
                MOVE.L  #0,A1
                MOVE.B  #14,D0
                TRAP    #15                 * Print
                
                JSR     PRINT_NEXT_WORD     * Print absolute short address
                BRA     TEST_OUTPUT
                
BCHG_ABSOLUTE_LONG
                MOVE.B  #'$',(A1)+
                MOVE.B  #0,(A1)+            * Terminate string with 0
                MOVE.L  #0,A1
                MOVE.B  #14,D0
                TRAP    #15                 * Print

                JSR     PRINT_NEXT_WORD     * Print absolute long address
                JSR     PRINT_NEXT_WORD
                
                BRA     TEST_OUTPUT

                
BCHG_INS                                        * Source of BCHG is immediate data
                CMP.B   #%001,D4                * If D3 == 100, then D4 must == 001
                BNE     INVALID_OPCODE
                
                CMP.B   #%001,D5                * Doesn't work with address register
                BEQ     INVALID_OPCODE
                
                CMP.B   #%101,D5                * Doesn't work with address with displacement
                BEQ     INVALID_OPCODE
                
                CMP.B   #%110,D5                * Doesn't work with address with index
                BEQ     INVALID_OPCODE
                
                CMP.B   #%111,D5
                BEQ     BCHG_INS_CHECK_111
                
                BRA     BCHG_INS_CONTINUED
                
BCHG_INS_CHECK_111
                CMP.B   #%010,D6
                BEQ     INVALID_OPCODE
                
                CMP.B   #%011,D6
                BEQ     INVALID_OPCODE
                
                BRA     BCHG_INS_CONTINUED
                
BCHG_INS_CONTINUED
                
                MOVE.B  #'B',(A1)+
                MOVE.B  #'C',(A1)+
                MOVE.B  #'H',(A1)+
                MOVE.B  #'G',(A1)+
                MOVE.B  #TAB,(A1)+
                MOVE.B  #'#',(A1)+
                MOVE.B  #'$',(A1)+
                
                MOVEM.L D5/D6,-(SP)                * Save D6 in case
                JSR     PRINT_NEXT_WORD         * next word contains immediate data info
                MOVEM.L (SP)+,D5/D6
                
                MOVE.B  #',',(A1)+
                
                CMP.B   #%010,D5                * Check for address ending
                BEQ     BCHG_ADDR_DESTINATION
                
                CMP.B   #%011,D5                * Check for address with postincrement ending
                BEQ     BCHG_ADDR_PLUS_DESTINATION
                
                CMP.B   #%100,D5                * CHeck for address with predecrement ending
                BEQ     BCHG_ADDR_MINUS_DESTINATION
                
                CMP.B   #%000,D5                * Check for data register ending
                BEQ     BCHG_DATA_REG_DESTINATION
                
                CMP.B   #%111,D5                * Check for absolute address
                BEQ     BCHG_ABSOLUTE_ADDRESS
                
                BRA     INVALID_OPCODE



ANDI_INS
                MOVE.B  #'A',(A1)+          * Add ANDI to buffer
                MOVE.B  #'N',(A1)+
                MOVE.B  #'D',(A1)+
                MOVE.B  #'I',(A1)+
                
                BRA     CODE_0000_SIZE

ADDI_INS
                MOVE.B  #'A',(A1)+          * Add ADDI to buffer
                MOVE.B  #'D',(A1)+
                MOVE.B  #'D',(A1)+
                MOVE.B  #'I',(A1)+
                
                BRA     CODE_0000_SIZE
                
EORI_INS
                MOVE.B  #'E',(A1)+          * Add EORI to buffer
                MOVE.B  #'O',(A1)+
                MOVE.B  #'R',(A1)+
                MOVE.B  #'I',(A1)+
                
                BRA     CODE_0000_SIZE
                
CMPI_INS
                MOVE.B  #'C',(A1)+          * Add CMPI to buffer
                MOVE.B  #'M',(A1)+
                MOVE.B  #'P',(A1)+
                MOVE.B  #'I',(A1)+
                
                BRA     CODE_0000_SIZE

CODE_0000_SIZE                              * Get size of operation
                CMP.B   #%000,D4            * Size == byte
                BEQ     OPMODE_DATA_EA_BYTE
                
                CMP.B   #%001,D4            * Size == word
                BEQ     OPMODE_DATA_EA_WORD
                
                CMP.B   #%010,D4            * Size == long
                BEQ     OPMODE_DATA_EA_LONG
                
                BRA     INVALID_OPCODE

*-----------------------------------------------------------
* CODE_0100
*
* CLR, RTS, JSR, MOVEM, LEA
*
* A5 is the current address
* D0 stores a word of data
* D1 stores the instruction (bits 15 - 12)
* D3 will hold bits 11 - 9
* D4 will hold bits 8 - 6
* D5 will hold bits 5 - 3
* D6 will hold bits 2 - 0
*-----------------------------------------------------------
CODE_0100
                CMP.W   #%0100101011111100,D0   * ILLEGAL
                BEQ     INVALID_OPCODE
                
                CMP.W   #%0100111001110000,D0   *RESET
                BEQ     INVALID_OPCODE
                
                CMP.W   #%0100111001110001,D0   * NOP
                BEQ     INVALID_OPCODE
                
                CMP.W   #%0100111001110010,D0   * STOP
                BEQ     INVALID_OPCODE
                
                CMP.B   #%110,D4                * CHK
                BEQ     INVALID_OPCODE
                
                CMP.W   #%0100111001110101,D0   * RTS
                BEQ     RTS_INS
                
                CMP.B   #%001,D3                * CLR instruction has 001 in bits 11-8
                BEQ     CLR_INS
                
                CMP.B   #%111,D4                * LEA instruction has 111 in bits 8-6
                BEQ     LEA_INS
                
                CMP.B   #%111,D3                * JSR
                BEQ     JSR_INS
                
                CMP.B   #%100,D3                * MOVEM register to memory
                BEQ     MOVEM_INS
                
                CMP.B   #%110,D3
                BEQ     MOVEM_INS               * MOVEM memory to register
                
                BRA     INVALID_OPCODE

*-----------------------------------------------------------
* CLR       CODE: 0100
* <ea>
*-----------------------------------------------------------
CLR_INS
                MOVE.B  #'C',(A1)+              * Add CLR to output buffer
                MOVE.B  #'L',(A1)+
                MOVE.B  #'R',(A1)+
                
                CMP.B   #%000,D4                * Size == byte
                BEQ     OPMODE_EA_BYTE
                
                CMP.B   #%001,D4                * Size == word
                BEQ     OPMODE_EA_WORD
                
                CMP.B   #%010,D4                * Size == long
                BEQ     OPMODE_EA_LONG
                
                BRA     INVALID_OPCODE
                

*-----------------------------------------------------------
* LEA       CODE: 0100
* <ea>
*-----------------------------------------------------------
LEA_INS
                CMP.B   #%011,D5
                BEQ     INVALID_OPCODE
                
                CMP.B   #%100,D5
                BEQ     INVALID_OPCODE
                
                CMP.B   #%101,D5
                BEQ     INVALID_OPCODE
                
                CMP.B   #%110,D5
                BEQ     INVALID_OPCODE

                MOVE.B  #'L',(A1)+              * Add LEA to output buffer
                MOVE.B  #'E',(A1)+
                MOVE.B  #'A',(A1)+
                
                BRA     OPMODE_EA_AN_LONG       * LEA is always a long operation

*-----------------------------------------------------------
* JSR       CODE: 0100 111 010 M Xn
*-----------------------------------------------------------
JSR_INS
                CMP.B   #%010,D4
                BNE     INVALID_OPCODE
                
                MOVE.B  #'J',(A1)+          * Add JSR to buffer
                MOVE.B  #'S',(A1)+
                MOVE.B  #'R',(A1)+
                MOVE.B  #TAB,(A1)+
                
                BRA     EA_Byte

*-----------------------------------------------------------
* RTS       CODE: 0100 1110 0111 0101
*-----------------------------------------------------------
RTS_INS
                MOVE.B  #'R',(A1)+
                MOVE.B  #'T',(A1)+
                MOVE.B  #'S',(A1)+
                
                BRA     TEST_OUTPUT

*-----------------------------------------------------------
* MOVEM     CODE: 0100
* 
* Register list mask is stored in the next word. EA will take care
* of that.
*
* For postincrement, the list goes from A7 to A0, D7 to D0 (bits 15-0)
* For predecrement, the list goes from D0 to D7, A0 to A7 (bits 15-0)
*
* A5 is the current address
* D0 stores a word of data
* D1 stores the instruction (bits 15 - 12)
* D3 will hold bits 11 - 9
* D4 will hold bits 8 - 6
* D5 will hold bits 5 - 3
* D6 will hold bits 2 - 0
*-----------------------------------------------------------
MOVEM_INS
                CMP.B   #%010,D4
                BEQ     MOVEM_INS_WORD
                
                CMP.B   #%011,D4
                BEQ     MOVEM_INS_LONG
                
                BRA     INVALID_OPCODE

*----------------------------------------------------------
* MOVEM instruction is potentially a word at this point
*----------------------------------------------------------
MOVEM_INS_WORD
                * Invalid D5 bits for all MOVEM instructions
                CMP.B   #%000,D5
                BEQ     INVALID_OPCODE
                
                CMP.B   #%001,D5
                BEQ     INVALID_OPCODE
                
                CMP.B   #%101,D5
                BEQ     INVALID_OPCODE
                
                CMP.B   #%110,D5
                BEQ     INVALID_OPCODE
                
                CMP.B   #%100,D3                    * Register to memory
                BEQ     MOVEM_INS_WORD_LIST_EA
               
                CMP.B   #%110,D3                    * Memory to register
                BEQ     MOVEM_INS_WORD_EA_LIST
               
                BRA     INVALID_OPCODE

*----------------------------------------------------------
* MOVEM.W
* <list>,<ea>
*----------------------------------------------------------
MOVEM_INS_WORD_LIST_EA
                * Moving from register to memory cannot have postincrementing
                CMP.B   #%011,D5
                BEQ     INVALID_OPCODE
                
                MOVE.B  #'M',(A1)+                  * Move MOVEM.W to buffer
                MOVE.B  #'O',(A1)+
                MOVE.B  #'V',(A1)+
                MOVE.B  #'E',(A1)+
                MOVE.B  #'M',(A1)+
                
                BRA     OPMODE_LIST_EA_WORD         * Register to memory
                
*----------------------------------------------------------
* MOVEM.W
* <ea>,<list
*----------------------------------------------------------
MOVEM_INS_WORD_EA_LIST
                * Moving from memory to register cannot have predecrementing
                CMP.B   #%100,D5
                BEQ     INVALID_OPCODE
                
                MOVE.B  #'M',(A1)+                  * Move MOVEM.W to buffer
                MOVE.B  #'O',(A1)+
                MOVE.B  #'V',(A1)+
                MOVE.B  #'E',(A1)+
                MOVE.B  #'M',(A1)+
                
                BRA     OPMODE_EA_LIST_WORD         * Memory to register

*----------------------------------------------------------
* MOVEM.L instruction at this point
*----------------------------------------------------------
MOVEM_INS_LONG
                * Invalid D5 bits for all MOVEM instructions
                CMP.B   #%000,D5
                BEQ     INVALID_OPCODE
                
                CMP.B   #%001,D5
                BEQ     INVALID_OPCODE
                
                CMP.B   #%101,D5
                BEQ     INVALID_OPCODE
                
                CMP.B   #%110,D5
                BEQ     INVALID_OPCODE
                
                CMP.B   #%100,D3                    * Register to memory
                BEQ     MOVEM_INS_LONG_LIST_EA
               
                CMP.B   #%110,D3                    * Memory to register
                BEQ     MOVEM_INS_LONG_EA_LIST
               
                BRA     INVALID_OPCODE

*----------------------------------------------------------
* MOVEM.L
* <list>,<ea>
*----------------------------------------------------------
MOVEM_INS_LONG_LIST_EA
                * Moving from register to memory cannot have postincrementing
                CMP.B   #%011,D5
                BEQ     INVALID_OPCODE
                
                MOVE.B  #'M',(A1)+                  * Move MOVEM.W to buffer
                MOVE.B  #'O',(A1)+
                MOVE.B  #'V',(A1)+
                MOVE.B  #'E',(A1)+
                MOVE.B  #'M',(A1)+
                
                BRA     OPMODE_LIST_EA_LONG         * Register to memory
                
*----------------------------------------------------------
* MOVEM.L
* <ea>,<list
*----------------------------------------------------------
MOVEM_INS_LONG_EA_LIST
                * Moving from memory to register cannot have predecrementing
                CMP.B   #%100,D5
                BEQ     INVALID_OPCODE
                
                MOVE.B  #'M',(A1)+                  * Move MOVEM.W to buffer
                MOVE.B  #'O',(A1)+
                MOVE.B  #'V',(A1)+
                MOVE.B  #'E',(A1)+
                MOVE.B  #'M',(A1)+
                
                BRA     OPMODE_EA_LIST_LONG         * Memory to register

*-----------------------------------------------------------
* CODE_0101
*
* SUBQ (ADDQ, Scc, DBcc are not implemented)
*
* A5 is the current address
* D0 stores a word of data
* D1 stores the instruction (bits 15 - 12)
* D3 will hold bits 11 - 9
* D4 will hold bits 8 - 6
* D5 will hold bits 5 - 3
* D6 will hold bits 2 - 0
*-----------------------------------------------------------
CODE_0101
                CMP.B   #%100,D4                * Size == byte
                BEQ     SUBQ_INS
                                
                CMP.B   #%101,D4                * Size == word
                BEQ     SUBQ_INS
                
                CMP.B   #%110,D4                * Size == long
                BEQ     SUBQ_INS
                
                BRA     INVALID_OPCODE          * No matches at this point means invalid instruction
                
SUBQ_INS
                MOVE.B  #'S',(A1)+
                MOVE.B  #'U',(A1)+
                MOVE.B  #'B',(A1)+
                MOVE.B  #'Q',(A1)+
                
                CMP.B   #%100,D4                * Size == byte
                BEQ     OPMODE_DATA_EA_BYTE
                
                CMP.B   #%101,D4                * Size == word
                BEQ     OPMODE_DATA_EA_WORD
                
                CMP.B   #%110,D4                * Size == long
                BEQ     OPMODE_DATA_EA_LONG
                
                BRA     INVALID_OPCODE
                
*-----------------------------------------------------------
* CODE_0110
*
* BCC, BGT, BLE, BVS (BRA, BSR, etc. aren't impl.)
*
* A5 is the current address
* D0 stores a word of data
* D1 stores the instruction (bits 15 - 12)
* D3 will hold bits 11 - 9
* D4 will hold bits 8 - 6
* D5 will hold bits 5 - 3
* D6 will hold bits 2 - 0
*-----------------------------------------------------------
CODE_0110
                * Isolate the condition
                CLR.L   D7                      * Clear D7 for use
                MOVE.W  D0,D7                   * Copy word to D7
                ANDI.W  #%0000111100000000,D7   * Mask bits 11-8
                LSR.L   #4,D7                   * Move bits to rightmost position
                LSR.L   #4,D7
                
                CMP.B   #%0100,D7               * Condition 0100 = BCC (Carry Clear)
                BEQ     BCC_INS
                
                CMP.B   #%1110,D7               * Condition 1110 = BGT (Greater Than)
                BEQ     BGT_INS
                
                CMP.B   #%1111,D7               * Condition 1111 = BLE (Less Than or Equal)
                BEQ     BLE_INS
                
                CMP.B   #%1001,D7               * Condition 1001 = BVS (Overflow Set)
                BEQ     BVS_INS
                
                BRA     INVALID_OPCODE
                
BCC_INS                                         * Branch Carry Clear instruction
                MOVE.B  #'B',(A1)+
                MOVE.B  #'C',(A1)+
                MOVE.B  #'C',(A1)+
                MOVE.B  #TAB,(A1)+
                MOVE.B  #'$',(A1)+
                
                BRA     Bcc_OUTPUT
                
BGT_INS                                         * Branch Greater Than instruction
                MOVE.B  #'B',(A1)+
                MOVE.B  #'G',(A1)+
                MOVE.B  #'T',(A1)+
                MOVE.B  #TAB,(A1)+
                MOVE.B  #'$',(A1)+
                
                BRA     Bcc_OUTPUT
BLE_INS                                         * Branch less than or equal instruction
                MOVE.B  #'B',(A1)+
                MOVE.B  #'L',(A1)+
                MOVE.B  #'E',(A1)+
                MOVE.B  #TAB,(A1)+
                MOVE.B  #'$',(A1)+
                
                BRA     Bcc_OUTPUT
BVS_INS                                         * Branch overflow set instruction
                MOVE.B  #'B',(A1)+
                MOVE.B  #'V',(A1)+
                MOVE.B  #'S',(A1)+
                MOVE.B  #TAB,(A1)+
                MOVE.B  #'$',(A1)+
                
                BRA     Bcc_OUTPUT
                
Bcc_OUTPUT                                      
                MOVE.W  A4,D0                   * Store current address in D0
                
                MOVEM.L D1,-(SP)                * Save D1
                CLR.L   D1
                ANDI.L  #$0000FFFF,D0           * Mask last 16 bits in D0
                MOVE.W  (A5)+,D1
                
                ADD.L   D1,D0                   * Add displacement to current address
                ADD.L   #$2,D0
                
                MOVEM.L (SP)+,D1                * Restore D1
                
                MOVE.B  #4,D2                   * Counter for current byte
                JSR     DECODE_ADDRESS          * Convert D0 to ASCII and store in D1
                MOVE.L  D1,(A1)+                * Move decoded address to A1
                
                MOVE.B  #0,(A1)+                * Terminate string with 0
                MOVE.L  #0,A1
                MOVE.B  #14,D0
                TRAP    #15                     * Print
                
                BRA     TEST_OUTPUT

*-----------------------------------------------------------
* CODE_0111
*
* MOVEQ
*
* A5 is the current address
* D0 stores a word of data
* D1 stores the instruction (bits 15 - 12)
* D3 will hold bits 11 - 9
* D4 will hold bits 8 - 6
* D5 will hold bits 5 - 3
* D6 will hold bits 2 - 0
*-----------------------------------------------------------
CODE_0111
                CMP.B   #%100,D4                    * Bit 8 must be zero
                BGE     INVALID_OPCODE
                
                MOVE.B  #'M',(A1)+                  * Add MOVEQ.L to buffer
                MOVE.B  #'O',(A1)+
                MOVE.B  #'V',(A1)+
                MOVE.B  #'E',(A1)+
                MOVE.B  #'Q',(A1)+
                JSR     ADD_DOT_L
                MOVE.B  #'#',(A1)+                  * Prepare symbols for immediate data
                MOVE.B  #'$',(A1)+
                
                * Decode first char of immediate data
                MOVEM.L D0/D1,-(SP)                 * Save D0/D1 because they'll be used
                CLR.L   D1
                ANDI.W  #%11110000,D0
                LSR.W   #4,D0
                
                JSR     CONVERT_REGISTER_TO_ASCII   * !!!: USES D0/D1
                MOVEM.L (SP)+,D0/D1                 * Restore D0/D1
                
                * Decode second char of immediate data
                MOVEM.L D0/D1,-(SP)                 * Save D0/D1 because they'll be used
                CLR.L   D1
                ANDI.W  #%00001111,D0
                JSR     CONVERT_REGISTER_TO_ASCII   * !!!: USES D0/D1
                MOVEM.L (SP)+,D0/D1                 * Restore D0/D1
                
                MOVE.B  #',',(A1)+
                MOVE.B  #'D',(A1)+
                
                MOVEM.L D0/D1,-(SP)                 * Save D0/D1 because they'll be used
                CLR.L   D0
                CLR.L   D1
                MOVE.B  D3,D0
                JSR     CONVERT_REGISTER_TO_ASCII   * !!!: USES D0/D1
                MOVEM.L (SP)+,D0/D1                 * Restore D0/D1
                
                MOVE.B  #0,(A1)+                    * Null terminate string
                MOVEA.L #0,A1
                MOVE    #14,D0
                TRAP    #15
                
                BRA     TEST_OUTPUT
                
*-----------------------------------------------------------
* CODE_1000
*
* DIVU (DIVS, SBCD, OR not impl.)
*
* A5 is the current address
* D0 stores a word of data
* D1 stores the instruction (bits 15 - 12)
* D3 will hold bits 11 - 9
* D4 will hold bits 8 - 6
* D5 will hold bits 5 - 3
* D6 will hold bits 2 - 0
*-----------------------------------------------------------
CODE_1000
                CMP.B   #%011,D4                * D4 must == 011 to be DIVU instruction
                BNE     INVALID_OPCODE
                
                MOVE.B  #'D',(A1)+              * Add DIVU to buffer
                MOVE.B  #'I',(A1)+
                MOVE.B  #'V',(A1)+
                MOVE.B  #'U',(A1)+
                
                BRA     OPMODE_EA_DN_WORD

                
*-----------------------------------------------------------
* CODE_1001
*
* SUB, SUBA (SUBX not impl.)
*
* A5 is the current address
* D0 stores a word of data
* D1 stores the instruction (bits 15 - 12)
* D3 will hold bits 11 - 9
* D4 will hold bits 8 - 6
* D5 will hold bits 5 - 3
* D6 will hold bits 2 - 0
*-----------------------------------------------------------
CODE_1001
                MOVE.B  #'S',(A1)+          * Add SUB to buffer
                MOVE.B  #'U',(A1)+
                MOVE.B  #'B',(A1)+
                
                CMP.B   #%001,D5            * Check for SUBX
                BEQ     INVALID_OPCODE
                
                CMP.B   #%000,D4            * <ea> - Dn --> Dn (byte)
                BEQ     OPMODE_EA_DN_BYTE
                
                CMP.B   #%001,D4            * <ea> - Dn --> Dn (word)
                BEQ     OPMODE_EA_DN_WORD   
                
                CMP.B   #%010,D4            * <ea> - Dn --> Dn (long)
                BEQ     OPMODE_EA_DN_LONG
                
                CMP.B   #%100,D4            * Dn - <ea> --> <ea> (byte)
                BEQ     OPMODE_DN_EA_BYTE
                
                CMP.B   #%101,D4
                BEQ     OPMODE_DN_EA_WORD   * Dn - <ea> --> <ea> (word)
                
                CMP.B   #%110,D4
                BEQ     OPMODE_DN_EA_LONG   * Dn - <ea> --> <ea> (long)
                
                MOVE.B  #'A',(A1)+          * Add 'A' to buffer to form SUBA
                
                CMP.B   #%011,D4            * SUBA.W instruction
                BEQ     OPMODE_EA_AN_WORD   * <ea>,An

                CMP.B   #%111,D4            * SUBA.L instruction   
                BEQ     OPMODE_EA_AN_LONG   * <ea>,An

                BRA     INVALID_OPCODE

SUBA_INS
                
                
                CMP.B   #%011,D4            * Size == word
                BEQ     OPMODE_EA_AN_WORD   * <ea>,An
                
                CMP.B   #%111,D4            * Size == long
                BEQ     OPMODE_EA_AN_LONG   * <ea>,An
                
                BRA     INVALID_OPCODE

*-----------------------------------------------------------
* CODE_1011
*
* CMP, CMPA, EOR (CMPM not impl.)
*
* A5 is the current address
* D0 stores a word of data
* D1 stores the instruction (bits 15 - 12)
* D3 will hold bits 11 - 9
* D4 will hold bits 8 - 6
* D5 will hold bits 5 - 3
* D6 will hold bits 2 - 0
*-----------------------------------------------------------
CODE_1011
                CMP.B   #%100,D4            * >= 100 corresponds to EOR
                BGE     EOR_INS

                MOVE.B  #'C',(A1)+          * Add "CMP" to buffer
                MOVE.B  #'M',(A1)+
                MOVE.B  #'P',(A1)+
                
                CMP.B   #%000,D4            * 000 corresponds to CMP.B instruction
                BEQ     OPMODE_EA_DN_BYTE
                
                CMP.B   #%001,D4            * 001 corresponds to CMP.W instruction
                BEQ     OPMODE_EA_DN_WORD
                                
                CMP.B   #%010,D4            * 010 corresponds to CMP.L instruction
                BEQ     OPMODE_EA_DN_LONG
                                
                MOVE.B  #'A',(A1)+          * Add 'A' to complete CMPA in buffer
                
                CMP.B   #%011,D4            * 011 corresponds to CMPA.W
                BEQ     OPMODE_EA_AN_WORD
                
                CMP.B   #%111,D4            * 111 corresponds to CMPA.L
                BEQ     OPMODE_EA_AN_LONG
                
                BRA     INVALID_OPCODE      * No valid instruction at this point
                
EOR_INS
                MOVE.B  #'E',(A1)+          * Add EOR to buffer
                MOVE.B  #'O',(A1)+
                MOVE.B  #'R',(A1)+
                
                CMP.B   #%100,D4            * Size == byte
                BEQ     OPMODE_DN_EA_BYTE
                
                CMP.B   #%101,D4            * Size == word
                BEQ     OPMODE_DN_EA_WORD
                
                CMP.B   #%110,D4            * Size == long
                BEQ     OPMODE_DN_EA_LONG
                
                BRA     INVALID_OPCODE      * No valid instruction at this point
                
*-----------------------------------------------------------
* CODE_1100
*
* AND, MULS (MULU, ABCD, EXG not impl.)
*
* A5 is the current address
* D0 stores a word of data
* D1 stores the instruction (bits 15 - 12)
* D3 will hold bits 11 - 9
* D4 will hold bits 8 - 6
* D5 will hold bits 5 - 3
* D6 will hold bits 2 - 0
*-----------------------------------------------------------
CODE_1100
                CMP.B   #%111,D4            * Branch to MULS instruction if D4 is 111
                BEQ     MULS_INS
                
                MOVE.B  #'A',(A1)+          * At this point, AND instruction
                MOVE.B  #'N',(A1)+
                MOVE.B  #'D',(A1)+
                
                CMP.B   #%000,D4            * 000 = Dn + <ea> --> Dn (byte)
                BEQ     OPMODE_EA_DN_BYTE
                
                CMP.B   #%001,D4            * 001 = Dn + <ea> --> Dn (word)
                BEQ     OPMODE_EA_DN_WORD
                
                CMP.B   #%010,D4            * 010 = Dn + <ea> --> Dn (long)
                BEQ     OPMODE_EA_DN_LONG
                
                CMP.B   #%100,D4            * 100 = <ea> + Dn --> <ea> (byte)
                BEQ     OPMODE_DN_EA_BYTE
                
                CMP.B   #%101,D4            * 101 = <ea> + Dn --> <ea> (word)
                BEQ     OPMODE_DN_EA_WORD
                
                CMP.B   #%110,D4            * 110 = <ea> + Dn --> <ea> (long)
                BEQ     OPMODE_DN_EA_WORD
                
                BRA     INVALID_OPCODE      * No valid instruction at this point


MULS_INS
                MOVE.B  #'M',(A1)+          * Add MULS to buffer
                MOVE.B  #'U',(A1)+
                MOVE.B  #'L',(A1)+
                MOVE.B  #'S',(A1)+
                
                BRA     OPMODE_EA_DN_WORD   * Complete MULS.W <ea>,Dn instruction

*-----------------------------------------------------------
* CODE_1101
*
* Attempt to decode the rest of the ADD instructions:
* - ADD
* - ADDA
* - ADDX
*
* A5 is the current address
* D0 stores a word of data
* D1 stores the instruction (bits 15 - 12)
* D3 will hold bits 11 - 9
* D4 will hold bits 8 - 6
* D5 will hold bits 5 - 3
* D6 will hold bits 2 - 0
*-----------------------------------------------------------
CODE_1101
                * Move 'ADD' to buffer
                MOVE.B  #'A',(A1)+
                MOVE.B  #'D',(A1)+
                MOVE.B  #'D',(A1)+
                
                * Branch to the opmode of the correct size and EA type
                CMP.B   #%000,D4
                BEQ     OPMODE_EA_DN_BYTE
                
                CMP.B   #%001,D4
                BEQ     OPMODE_EA_DN_WORD
                
                CMP.B   #%010,D4
                BEQ     OPMODE_EA_DN_LONG
                
                CMP.B   #%100,D4
                BEQ     OPMODE_DN_EA_BYTE
                
                CMP.B   #%101,D4
                BEQ     OPMODE_DN_EA_WORD
                
                CMP.B   #%110,D4
                BEQ     OPMODE_DN_EA_LONG
                
                MOVE.B  #'A',(A1)+              * Add 'A' to form ADDA
                
                CMP.B   #%011,D4                * 011 specifies word op
                BEQ     OPMODE_EA_AN_WORD
                
                CMP.B   #%111,D4                * 111 specifies long op
                BEQ     OPMODE_EA_AN_LONG
                
                BRA     INVALID_OPCODE          * No matches means invalid opcode

*-----------------------------------------------------------
* CODE_1110
*
* ASR, LSL, ROL, ROR (others not impli.)
*
* A5 is the current address
* D0 stores a word of data
* D1 stores the instruction (bits 15 - 12)
* D3 will hold bits 11 - 9
* D4 will hold bits 8 - 6
* D5 will hold bits 5 - 3
* D6 will hold bits 2 - 0
*-----------------------------------------------------------
CODE_1110                                       * Check for possible absolute address instruction
                CMP.B   #%000,D3                * possible ASR/ASL absolute address
                BEQ     ASd_ABSOLUTE
                
                CMP.B   #%001,D3                * possible LSR/LSL absolute address
                BEQ     LSd_ABSOLUTE
                
                CMP.B   #%011,D3                * possible ROR/ROL absolute address
                BEQ     ROd_ABSOLUTE
                
                BRA     CODE_1110_OTHER         * no matches, go to normal codes

ASd_ABSOLUTE
                CMP.B   #%011,D4                * possible ASR absolute address
                BEQ     ASR_ABSOLUTE
                BRA     CODE_1110_OTHER
                
LSd_ABSOLUTE
                CMP.B   #%111,D4                * Check for LSL absolute
                BEQ     LSL_ABSOLUTE
                BRA     CODE_1110_OTHER         * no matches, go to normal codes
                
ROd_ABSOLUTE
                CMP.B   #%011,D4                * Check for ROR absolute
                BEQ     ROR_ABSOLUTE
                
                CMP.B   #%111,D4                * Check for ROL absolute
                BEQ     ROL_ABSOLUTE
                
                BRA     CODE_1110_OTHER         * no matches, go to normal codes

CODE_1110_OTHER

                CMP.B   #%000,D5                * ASR/ASL
                BEQ     ASd_INS
                
                CMP.B   #%100,D5                * ASR/ASL
                BEQ     ASd_INS
                
                CMP.B   #%001,D5                * LSL/LSR
                BEQ     LSd_INS
                
                CMP.B   #%101,D5                * LSL/LSR
                BEQ     LSd_INS
                
                CMP.B   #%011,D5                * ROR
                BEQ     ROd_INS
                
                CMP.B   #%111,D5                * ROL
                BEQ     ROd_INS
                
                BRA     INVALID_OPCODE
                
ASd_INS
                CMP.B   #%000,D4                * ASR_BYTE
                BEQ     ASR_BYTE
                
                CMP.B   #%001,D4                * ASR_WORD
                BEQ     ASR_WORD
                
                CMP.B   #%010,D4                * ASR_LONG
                BEQ     ASR_LONG
                
                BRA     INVALID_OPCODE
                
ASR_BYTE
                MOVE.B  #'A',(A1)+              * Add ASR.B to buffer
                MOVE.B  #'S',(A1)+
                MOVE.B  #'R',(A1)+
                JSR     ADD_DOT_B
                
                CMP.B   #%100,D5                * Rotation is a register
                BEQ     CODE_1110_REGISTER
                
                CMP.B   #%000,D5                * Rotation is immediate data
                BEQ     CODE_1110_IMMEDIATE
                
                BRA     INVALID_OPCODE

ASR_ABSOLUTE
                MOVE.B  #'A',(A1)+              * Add ASR.W to buffer
                MOVE.B  #'S',(A1)+
                MOVE.B  #'R',(A1)+
                JSR     ADD_DOT_W
                
                BRA     CODE_1110_ABSOLUTE_ADDRESS

ASR_WORD
                MOVE.B  #'A',(A1)+              * Add ASR.W to buffer
                MOVE.B  #'S',(A1)+
                MOVE.B  #'R',(A1)+
                JSR     ADD_DOT_W
                
                CMP.B   #%100,D5                * Rotation is a register
                BEQ     CODE_1110_REGISTER
                
                CMP.B   #%000,D5                * Rotation is immediate data
                BEQ     CODE_1110_IMMEDIATE
                
                BRA     INVALID_OPCODE
                
ASR_LONG
                MOVE.B  #'A',(A1)+              * Add ASR.L to buffer
                MOVE.B  #'S',(A1)+
                MOVE.B  #'R',(A1)+
                JSR     ADD_DOT_L
                
                CMP.B   #%100,D5                * Rotation is a register
                BEQ     CODE_1110_REGISTER
                
                CMP.B   #%000,D5                * Rotation is immediate data
                BEQ     CODE_1110_IMMEDIATE
                
                BRA     INVALID_OPCODE

CODE_1110_ABSOLUTE_ADDRESS
                
                CMP.B   #%000,D6                * Changing absolute address (word)
                BEQ     CODE_1110_ABSOLUTE_ADDRESS_SHORT
                
                CMP.B   #%001,D6                * Changing absolute address (long)
                BEQ     CODE_1110_ABSOLUTE_ADDRESS_LONG
                
                BRA     INVALID_OPCODE

CODE_1110_ABSOLUTE_ADDRESS_SHORT
                MOVE.B  #'$',(A1)+
                MOVE.B  #0,(A1)+            * Terminate string with 0
                MOVE.L  #0,A1
                MOVE.B  #14,D0
                TRAP    #15                 * Print
                
                CLR.L   D6                  * Clear D6 for use later
                MOVEA.L #zeroAddr,A1        * Zero out A1 before use
                CLR.L   D0                  * Zero out the data register
                MOVE.W  (A5)+,D0            * Store current address
                
                MOVE.B  #4,D2               * Counter for current byte
                JSR     DECODE_ADDRESS      * Convert D0 to ASCII and store in D1
                MOVE.L  D1,(A1)+            * Move decoded address to A1
                
                MOVE.B  #0,(A1)+            * Terminate string with 0
                MOVE.L  #0,A1
                MOVE.B  #14,D0
                TRAP    #15                 * Print
                
                BRA     TEST_OUTPUT
                
CODE_1110_ABSOLUTE_ADDRESS_LONG
                MOVE.B  #'$',(A1)+
                MOVE.B  #0,(A1)+            * Terminate string with 0
                MOVE.L  #0,A1
                MOVE.B  #14,D0
                TRAP    #15                 * Print
                
                CLR.L   D6                  * Clear D6 for use later
                MOVEA.L #zeroAddr,A1        * Zero out A1 before use
                CLR.L   D0                  * Zero out the data register
                MOVE.W  (A5)+,D0            * Store current address
                
                MOVE.B  #4,D2               * Counter for current byte
                JSR     DECODE_ADDRESS      * Convert D0 to ASCII and store in D1
                MOVE.L  D1,(A1)+            * Move decoded address to A1
                
                MOVE.B  #0,(A1)+            * Terminate string with 0
                MOVE.L  #0,A1
                MOVE.B  #14,D0
                TRAP    #15                 * Print
                
                CLR.L   D6                  * Clear D6 for use later
                MOVEA.L #zeroAddr,A1        * Zero out A1 before use
                CLR.L   D0                  * Zero out the data register
                MOVE.W  (A5)+,D0            * Store current address
                
                MOVE.B  #4,D2               * Counter for current byte
                JSR     DECODE_ADDRESS      * Convert D0 to ASCII and store in D1
                MOVE.L  D1,(A1)+            * Move decoded address to A1
                
                MOVE.B  #0,(A1)+            * Terminate string with 0
                MOVE.L  #0,A1
                MOVE.B  #14,D0
                TRAP    #15                 * Print
                
                BRA     TEST_OUTPUT
                
                
CODE_1110_REGISTER
                MOVE.B  #'D',(A1)+
                
                * Convert D3 into char
                MOVEM.L D0/D1,-(SP)                 * Save D0/D1 because they'll be used
                CLR.L   D1
                MOVE.B  D3,D0
                
                JSR     CONVERT_REGISTER_TO_ASCII   * !!!: USES D0/D1
                MOVEM.L (SP)+,D0/D1                 * Restore D0/D1
                
                BRA     CODE_1110_REST              * Decode the rest of the instruction
                
CODE_1110_IMMEDIATE
                MOVE.B  #'#',(A1)+
                
                * Convert D3 into char
                MOVEM.L D0/D1,-(SP)                 * Save D0/D1 because they'll be used
                CLR.L   D1
                MOVE.B  D3,D0
                
                JSR     CONVERT_REGISTER_TO_ASCII   * !!!: USES D0/D1
                MOVEM.L (SP)+,D0/D1                 * Restore D0/D1
                
                BRA     CODE_1110_REST              * Decode the rest of the instruction
                
CODE_1110_REST
                MOVE.B  #',',(A1)+
                MOVE.B  #'D',(A1)+
                
                * Convert D6 into char
                MOVEM.L D0/D1,-(SP)                 * Save D0/D1 because they'll be used
                CLR.L   D1
                MOVE.B  D6,D0
                
                JSR     CONVERT_REGISTER_TO_ASCII   * !!!: USES D0/D1
                MOVEM.L (SP)+,D0/D1                 * Restore D0/D1
                
                BRA     TEST_OUTPUT
                
LSd_INS                                         * Logical shift instruction
                CMP.B   #%100,D4                * LSL_BYTE
                BEQ     LSL_BYTE
                
                CMP.B   #%101,D4                * LSL_WORD
                BEQ     LSL_WORD
                
                CMP.B   #%110,D4                * LSL_LONG
                BEQ     LSL_LONG
                
                BRA     INVALID_OPCODE

LSL_BYTE
                MOVE.B  #'L',(A1)+              * Add ASR.B to buffer
                MOVE.B  #'S',(A1)+
                MOVE.B  #'L',(A1)+
                JSR     ADD_DOT_B
                
                CMP.B   #%101,D5                * Rotation is a register
                BEQ     CODE_1110_REGISTER
                
                CMP.B   #%001,D5                * Rotation is immediate data
                BEQ     CODE_1110_IMMEDIATE
                
                BRA     INVALID_OPCODE

LSL_ABSOLUTE
                MOVE.B  #'L',(A1)+              * Add LSL.W to buffer
                MOVE.B  #'S',(A1)+
                MOVE.B  #'L',(A1)+
                JSR     ADD_DOT_W
                
                BRA     CODE_1110_ABSOLUTE_ADDRESS

LSL_WORD
                MOVE.B  #'L',(A1)+              * Add LSL.W to buffer
                MOVE.B  #'S',(A1)+
                MOVE.B  #'L',(A1)+
                JSR     ADD_DOT_W
                
                CMP.B   #%101,D5                * Rotation is a register
                BEQ     CODE_1110_REGISTER
                
                CMP.B   #%001,D5                * Rotation is immediate data
                BEQ     CODE_1110_IMMEDIATE
                
                BRA     INVALID_OPCODE
                
LSL_LONG
                MOVE.B  #'L',(A1)+              * Add LSL.L to buffer
                MOVE.B  #'S',(A1)+
                MOVE.B  #'L',(A1)+
                JSR     ADD_DOT_L
                
                CMP.B   #%101,D5                * Rotation is a register
                BEQ     CODE_1110_REGISTER
                
                CMP.B   #%001,D5                * Rotation is immediate data
                BEQ     CODE_1110_IMMEDIATE
                
                BRA     INVALID_OPCODE

ROd_INS                                         * Rotate instruction
                
                CMP.B   #%000,D4                * ROL_BYTE
                BEQ     ROL_BYTE
                
                CMP.B   #%001,D4                * ROL_WORD
                BEQ     ROL_WORD
                
                CMP.B   #%010,D4                * ROL_LONG
                BEQ     ROL_LONG
                
                CMP.B   #%000,D4                * ROR_BYTE
                BEQ     ROR_BYTE
                
                CMP.B   #%001,D4                * ROR_WORD
                BEQ     ROR_WORD
                
                CMP.B   #%010,D4                * ROR_LONG
                BEQ     ROR_LONG
                
                BRA     INVALID_OPCODE
                
ROL_BYTE
                MOVE.B  #'R',(A1)+              * Add ROL.B to buffer
                MOVE.B  #'O',(A1)+
                MOVE.B  #'L',(A1)+
                JSR     ADD_DOT_B
                
                CMP.B   #%011,D5                * Rotation is immediate data
                BEQ     CODE_1110_IMMEDIATE
                
                CMP.B   #%111,D5                * Rotation is a register
                BEQ     CODE_1110_REGISTER
                
                BRA     INVALID_OPCODE

ROL_ABSOLUTE
                MOVE.B  #'R',(A1)+              * Add ROL.W to buffer
                MOVE.B  #'O',(A1)+
                MOVE.B  #'L',(A1)+
                JSR     ADD_DOT_W
                
                BRA     CODE_1110_ABSOLUTE_ADDRESS
                
ROL_WORD 
                MOVE.B  #'R',(A1)+              * Add ROL.W to buffer
                MOVE.B  #'O',(A1)+
                MOVE.B  #'L',(A1)+
                JSR     ADD_DOT_W

                CMP.B   #%011,D5                * Rotation is immediate data
                BEQ     CODE_1110_IMMEDIATE
                
                CMP.B   #%111,D5                * Rotation is a register
                BEQ     CODE_1110_REGISTER
                
                BRA     INVALID_OPCODE
                
ROL_LONG
                MOVE.B  #'R',(A1)+              * Add ROL.L to buffer
                MOVE.B  #'O',(A1)+
                MOVE.B  #'L',(A1)+
                JSR     ADD_DOT_L
                
                CMP.B   #%011,D5                * Rotation is immediate data
                BEQ     CODE_1110_IMMEDIATE
                
                CMP.B   #%111,D5                * Rotation is a register
                BEQ     CODE_1110_REGISTER
                
                BRA     INVALID_OPCODE
                
ROR_BYTE
                MOVE.B  #'R',(A1)+              * Add ROR.B to buffer
                MOVE.B  #'O',(A1)+
                MOVE.B  #'R',(A1)+
                JSR     ADD_DOT_B
                
                CMP.B   #%011,D5                * Rotation is immediate data
                BEQ     CODE_1110_IMMEDIATE
                
                CMP.B   #%111,D5                * Rotation is a register
                BEQ     CODE_1110_REGISTER
                
                BRA     INVALID_OPCODE

ROR_ABSOLUTE
                MOVE.B  #'R',(A1)+              * Add ROR.W to buffer
                MOVE.B  #'O',(A1)+
                MOVE.B  #'R',(A1)+
                JSR     ADD_DOT_W
                
                BRA     CODE_1110_ABSOLUTE_ADDRESS
        
ROR_WORD
                MOVE.B  #'R',(A1)+              * Add ROR.W to buffer
                MOVE.B  #'O',(A1)+
                MOVE.B  #'R',(A1)+
                JSR     ADD_DOT_W

                CMP.B   #%011,D5                * Rotation is immediate data
                BEQ     CODE_1110_IMMEDIATE
                
                CMP.B   #%111,D5                * Rotation is a register
                BEQ     CODE_1110_REGISTER
                
                BRA     INVALID_OPCODE
                
ROR_LONG
                MOVE.B  #'R',(A1)+              * Add ROR.L to buffer
                MOVE.B  #'O',(A1)+
                MOVE.B  #'R',(A1)+
                JSR     ADD_DOT_L
                
                CMP.B   #%011,D5                * Rotation is immediate data
                BEQ     CODE_1110_IMMEDIATE
                
                CMP.B   #%111,D5                * Rotation is a register
                BEQ     CODE_1110_REGISTER
                
                BRA     INVALID_OPCODE
                
*-----------------------------------------------------------
* MOVE_INS: Move instruction
*
* MOVE(.B/W/L)
* <ea>,<ea>
*
* A5 is the current address
* D0 stores a word of data
* D1 stores the instruction (bits 15 - 12)
* D3 will hold bits 11 - 9
* D4 will hold bits 8 - 6
* D5 will hold bits 5 - 3
* D6 will hold bits 2 - 0
*-----------------------------------------------------------
MOVE_INS
                CMP.B   #%001,D4            * MOVEA not required
                BEQ     INVALID_OPCODE
                
                CMP.B   #%0001,D1           * Size == byte
                BEQ     MOVE_INS_CONTINUED
                
                CMP.B   #%0011,D1           * Size == word
                BEQ     MOVE_INS_CONTINUED
                
                CMP.B   #%0010,D1           * Size == long
                BEQ     MOVE_INS_CONTINUED
                
                BRA     INVALID_OPCODE
                
MOVE_INS_CONTINUED
                CMP.B   #%101,D5
                BEQ     INVALID_OPCODE
                
                CMP.B   #%110,D5
                BEQ     INVALID_OPCODE
                
                MOVE.B  #'M',(A1)+
                MOVE.B  #'O',(A1)+
                MOVE.B  #'V',(A1)+
                MOVE.B  #'E',(A1)+
                
                CMP.B   #%0001,D1           * Size == byte
                BEQ     OPMODE_EA_EA_BYTE
                
                CMP.B   #%0011,D1           * Size == word
                BEQ     OPMODE_EA_EA_WORD
                
                CMP.B   #%0010,D1           * Size == long
                BEQ     OPMODE_EA_EA_LONG
                
                BRA     INVALID_OPCODE


*-----------------------------------------------------------
* Beginning of EA section
*
* A5 is the current address
* D0 stores a word of data
* D1 stores the instruction (bits 15 - 12)
* D3 will hold bits 11 - 9
* D4 will hold bits 8 - 6
* D5 will hold bits 5 - 3
* D6 will hold bits 2 - 0
*-----------------------------------------------------------

*-----------------------------------------------------------
* OPMODE_EA_DN (byte)
* <ea>,Dn
*
* A5 is the current address
* D0 stores a word of data
* D1 stores the instruction (bits 15 - 12)
* D3 will hold bits 11 - 9
* D4 will hold bits 8 - 6
* D5 will hold bits 5 - 3
* D6 will hold bits 2 - 0
*-----------------------------------------------------------
OPMODE_EA_DN_BYTE
                JSR     ADD_DOT_B                   * Add .B to output buffer
                
                BRA     EA_DN_Byte
                
*-----------------------------------------------------------
* OPMODE_EA_DN (word)
* <ea>,Dn
*-----------------------------------------------------------
OPMODE_EA_DN_WORD
                JSR     ADD_DOT_W                   * Add .W to output buffer
                
                BRA     EA_DN_Word
                
*-----------------------------------------------------------
* OPMODE_EA_DN (long)
* <ea>,Dn
*-----------------------------------------------------------
OPMODE_EA_DN_LONG
                JSR     ADD_DOT_L                   * Add .L to output buffer
                
                BRA     EA_DN_Long

*-----------------------------------------------------------
* OPMODE_DN_EA (byte)
* Dn,<ea>
*
* A5 is the current address
* D0 stores a word of data
* D1 stores the instruction (bits 15 - 12)
* D3 will hold bits 11 - 9
* D4 will hold bits 8 - 6
* D5 will hold bits 5 - 3
* D6 will hold bits 2 - 0
*-----------------------------------------------------------
OPMODE_DN_EA_BYTE
                JSR     ADD_DOT_B                   * Add .B to output buffer
                
                BRA     DN_EA_Byte

*-----------------------------------------------------------
* OPMODE_DN_EA (word)
* Dn,<ea>
*-----------------------------------------------------------
OPMODE_DN_EA_WORD
                JSR     ADD_DOT_W                   * Add .W to output buffer
                
                BRA     DN_EA_Word
                
*-----------------------------------------------------------
* OPMODE_DN_EA (long)
* Dn,<ea>
*-----------------------------------------------------------
OPMODE_DN_EA_LONG
                JSR     ADD_DOT_L                   * Add .L to output buffer
                
                BRA     DN_EA_Long
                
*-----------------------------------------------------------
* OPMODE_EA_AN (byte)
* <ea>,An
*
* A5 is the current address
* D0 stores a word of data
* D1 stores the instruction (bits 15 - 12)
* D3 will hold bits 11 - 9
* D4 will hold bits 8 - 6
* D5 will hold bits 5 - 3
* D6 will hold bits 2 - 0
*-----------------------------------------------------------
OPMODE_EA_AN_BYTE
                JSR     ADD_DOT_B                   * Add .B to output buffer
                
                BRA     EA_AN_Byte
              
*-----------------------------------------------------------
* OPMODE_EA_AN (word)
* <ea>,An
*-----------------------------------------------------------
OPMODE_EA_AN_WORD
                JSR     ADD_DOT_W                   * Add .W to output buffer
                
                BRA     EA_AN_Word
                
*-----------------------------------------------------------
* OPMODE_EA_AN (long)
* <ea>,An
*-----------------------------------------------------------
OPMODE_EA_AN_LONG
                JSR     ADD_DOT_L                   * Add .L to output buffer
                
                BRA     EA_AN_Long

*-----------------------------------------------------------
* OPMODE_DATA_EA (byte)
* #<data>,<ea>
*
* A5 is the current address
* D0 stores a word of data
* D1 stores the instruction (bits 15 - 12)
* D3 will hold bits 11 - 9
* D4 will hold bits 8 - 6
* D5 will hold bits 5 - 3
* D6 will hold bits 2 - 0
*-----------------------------------------------------------
OPMODE_DATA_EA_BYTE
                JSR     ADD_DOT_B                   * Add .B to output buffer
                
                BRA     ID_EA_Byte
                
                
*-----------------------------------------------------------
* OPMODE_DATA_EA (word)
* #<data>,<ea>
*-----------------------------------------------------------
OPMODE_DATA_EA_WORD
                JSR     ADD_DOT_W                   * Add .W to output buffer
                
                BRA     ID_EA_Word
                
                
*-----------------------------------------------------------
* OPMODE_DATA_EA (long)
* #<data>,<ea>
*-----------------------------------------------------------
OPMODE_DATA_EA_LONG
                JSR     ADD_DOT_L                   * Add .L to output buffer
                
                BRA     ID_EA_Long
                
                
 
*-----------------------------------------------------------
* OPMODE_EA_EA (byte)
* <ea>,<ea>
*
* A5 is the current address
* D0 stores a word of data
* D1 stores the instruction (bits 15 - 12)
* D3 will hold bits 11 - 9
* D4 will hold bits 8 - 6
* D5 will hold bits 5 - 3
* D6 will hold bits 2 - 0
*-----------------------------------------------------------
OPMODE_EA_EA_BYTE
                JSR     ADD_DOT_B                   * Add .B to output buffer
                                
                BRA     EA_EA_Byte
                
*-----------------------------------------------------------
* OPMODE_EA_EA (word)
* <ea>,<ea>
*-----------------------------------------------------------
OPMODE_EA_EA_WORD
                JSR     ADD_DOT_W                   * Add .W to output buffer
                
                BRA     EA_EA_Word
                
*-----------------------------------------------------------
* OPMODE_EA_EA (long)
* <ea>,<ea>
*-----------------------------------------------------------
OPMODE_EA_EA_LONG
                JSR     ADD_DOT_L                   * Add .L to output buffer
                
                BRA     EA_EA_Long
                
*-----------------------------------------------------------
* OPMODE_LIST_EA (word)
* <list>,<ea>
*
* For predecrement, the list goes from D0 to D7, A0 to A7 (bits 15-0)
* D0 stores the register list mask
* D1 tells if register is the first to be printed (1 if it is, 0 if not.)
* D2 tells the register type (1 for data, 0 for address).
* D3 stores the register number
*-----------------------------------------------------------
OPMODE_LIST_EA_WORD
                JSR     ADD_DOT_W                   * Add .W to output buffer
                
                CMP.B   #%011,D5                    * Cannot have post incrementing (addressing mode) here
                BEQ     INVALID_OPCODE
                
                MOVE.W  (A5)+,D0                    * Store register list mask in D0
                
                CMP.B   #%100,D5                    * Check which kind of list to output
                BEQ     OPMODE_LIST_EA_WORD_PRE_LIST
                BRA     OPMODE_LIST_EA_WORD_POST_LIST

*-----------------------------------------------------------
* Prints out predecrement list
*-----------------------------------------------------------
OPMODE_LIST_EA_WORD_PRE_LIST
                JSR     PREDECREMENT_LIST
                BRA     OPMODE_LIST_EA_WORD_CONTINUED

*-----------------------------------------------------------
* Prints out postincrement list
*-----------------------------------------------------------
OPMODE_LIST_EA_WORD_POST_LIST
                JSR     POSTINCREMENT_LIST

*-----------------------------------------------------------
* Continue with rest of code
*-----------------------------------------------------------
OPMODE_LIST_EA_WORD_CONTINUED
                MOVE.B  #',',(A1)+
                
                CMP.B   #%111,D5
                BNE     OPMODE_LIST_EA_WORD_CONTINUED2
                
                CMP.B   #%000,D6
                BEQ     LIST_EA_WORD_ABSOLUTE_SHORT
                
                CMP.B   #%001,D6
                BEQ     LIST_EA_WORD_ABSOLUTE_LONG
                
                BRA     INVALID_OPCODE
                
LIST_EA_WORD_ABSOLUTE_SHORT
                MOVE.B  #'$',(A1)+
                JSR     PRINT_NEXT_WORD
                BRA     TEST_OUTPUT
LIST_EA_WORD_ABSOLUTE_LONG
                MOVE.B  #'$',(A1)+
                JSR     PRINT_NEXT_WORD
                JSR     PRINT_NEXT_WORD
                BRA     TEST_OUTPUT
OPMODE_LIST_EA_WORD_CONTINUED2
                BRA     EA_WORD
                
*-----------------------------------------------------------
* PREDECREMENT_LIST checks every bit in D0/D1 to see if the register needs to be enabled.
*
* D0 contains the register mask (a word).
* D1 holds a copy of D0 to be manipulated and compared.
* D2 remembers if the register is the first one seen. (1 is first, 0 otherwise.)
* 
* For predecrement, the list goes from D0 to D7, A0 to A7 (bits 15-0)
*-----------------------------------------------------------
PREDECREMENT_LIST
                CLR.L   D2                          * Clear D2
                MOVE.B  #1,D2                       * Keep track of first register
                
                MOVE.W  D0,D1
                ANDI.W  #mask15,D1
                CMP.W   #$8000,D1
                BEQ     PRE_LIST_D0
                BRA     PRE_LIST_D1_CHECK
                
PRE_LIST_D0
                JSR     PRINT_SLASH
                MOVE.B  #'D',(A1)+
                MOVE.B  #'0',(A1)+
                
PRE_LIST_D1_CHECK
                MOVE.W  D0,D1
                ANDI.W  #mask14,D1
                CMP.W   #0,D1
                BGT     PRE_LIST_D1_OUTPUT
                BRA     PRE_LIST_D2_CHECK
                
PRE_LIST_D1_OUTPUT
                JSR     PRINT_SLASH
                MOVE.B  #'D',(A1)+
                MOVE.B  #'1',(A1)+
                
PRE_LIST_D2_CHECK
                MOVE.W  D0,D1
                ANDI.W  #mask13,D1
                CMP.W   #0,D1
                BGT     PRE_LIST_D2_OUTPUT
                BRA     PRE_LIST_D3_CHECK
PRE_LIST_D2_OUTPUT
                JSR     PRINT_SLASH
                MOVE.B  #'D',(A1)+
                MOVE.B  #'2',(A1)+

PRE_LIST_D3_CHECK
                MOVE.W  D0,D1
                ANDI.W  #mask12,D1
                CMP.W   #0,D1
                BGT     PRE_LIST_D3_OUTPUT
                BRA     PRE_LIST_D4_CHECK

PRE_LIST_D3_OUTPUT
                JSR     PRINT_SLASH
                MOVE.B  #'D',(A1)+
                MOVE.B  #'3',(A1)+

PRE_LIST_D4_CHECK
                MOVE.W  D0,D1
                ANDI.W  #mask11,D1
                CMP.W   #0,D1
                BGT     PRE_LIST_D4_OUTPUT
                BRA     PRE_LIST_D5_CHECK

PRE_LIST_D4_OUTPUT
                JSR     PRINT_SLASH
                MOVE.B  #'D',(A1)+
                MOVE.B  #'4',(A1)+

PRE_LIST_D5_CHECK
                MOVE.W  D0,D1
                ANDI.W  #mask10,D1
                CMP.W   #0,D1
                BGT     PRE_LIST_D5_OUTPUT
                BRA     PRE_LIST_D6_CHECK
                
PRE_LIST_D5_OUTPUT
                JSR     PRINT_SLASH
                MOVE.B  #'D',(A1)+
                MOVE.B  #'5',(A1)+

PRE_LIST_D6_CHECK
                MOVE.W  D0,D1
                ANDI.W  #mask9,D1
                CMP.W   #0,D1
                BGT     PRE_LIST_D6_OUTPUT
                BRA     PRE_LIST_D7_CHECK

PRE_LIST_D6_OUTPUT
                JSR     PRINT_SLASH
                MOVE.B  #'D',(A1)+
                MOVE.B  #'6',(A1)+

PRE_LIST_D7_CHECK
                MOVE.W  D0,D1
                ANDI.W  #mask8,D1
                CMP.W   #0,D1
                BGT     PRE_LIST_D7_OUTPUT
                BRA     PRE_LIST_A0_CHECK
                
PRE_LIST_D7_OUTPUT
                JSR     PRINT_SLASH
                MOVE.B  #'D',(A1)+
                MOVE.B  #'7',(A1)+

PRE_LIST_A0_CHECK
                MOVE.W  D0,D1
                ANDI.W  #mask7,D1
                CMP.W   #0,D1
                BGT     PRE_LIST_A0_OUTPUT
                BRA     PRE_LIST_A1_CHECK
                
PRE_LIST_A0_OUTPUT
                JSR     PRINT_SLASH
                MOVE.B  #'A',(A1)+
                MOVE.B  #'0',(A1)+
                
PRE_LIST_A1_CHECK
                MOVE.W  D0,D1
                ANDI.W  #mask6,D1
                CMP.W   #0,D1
                BGT     PRE_LIST_A1_OUTPUT
                BRA     PRE_LIST_A2_CHECK
                
PRE_LIST_A1_OUTPUT
                JSR     PRINT_SLASH
                MOVE.B  #'A',(A1)+
                MOVE.B  #'1',(A1)+
                
PRE_LIST_A2_CHECK
                MOVE.W  D0,D1
                ANDI.W  #mask5,D1
                CMP.W   #0,D1
                BGT     PRE_LIST_A2_OUTPUT
                BRA     PRE_LIST_A3_CHECK
PRE_LIST_A2_OUTPUT
                JSR     PRINT_SLASH
                MOVE.B  #'A',(A1)+
                MOVE.B  #'2',(A1)+

PRE_LIST_A3_CHECK
                MOVE.W  D0,D1
                ANDI.W  #mask4,D1
                CMP.W   #0,D1
                BGT     PRE_LIST_A3_OUTPUT
                BRA     PRE_LIST_A4_CHECK

PRE_LIST_A3_OUTPUT
                JSR     PRINT_SLASH
                MOVE.B  #'A',(A1)+
                MOVE.B  #'3',(A1)+

PRE_LIST_A4_CHECK
                MOVE.W  D0,D1
                ANDI.W  #mask3,D1
                CMP.W   #0,D1
                BGT     PRE_LIST_A4_OUTPUT
                BRA     PRE_LIST_A5_CHECK

PRE_LIST_A4_OUTPUT
                JSR     PRINT_SLASH
                MOVE.B  #'A',(A1)+
                MOVE.B  #'4',(A1)+

PRE_LIST_A5_CHECK
                MOVE.W  D0,D1
                ANDI.W  #mask2,D1
                CMP.W   #0,D1
                BGT     PRE_LIST_A5_OUTPUT
                BRA     PRE_LIST_A6_CHECK
                
PRE_LIST_A5_OUTPUT
                JSR     PRINT_SLASH
                MOVE.B  #'A',(A1)+
                MOVE.B  #'5',(A1)+

PRE_LIST_A6_CHECK
                MOVE.W  D0,D1
                ANDI.W  #mask1,D1
                CMP.W   #0,D1
                BGT     PRE_LIST_A6_OUTPUT
                BRA     PRE_LIST_A7_CHECK

PRE_LIST_A6_OUTPUT
                JSR     PRINT_SLASH
                MOVE.B  #'A',(A1)+
                MOVE.B  #'6',(A1)+

PRE_LIST_A7_CHECK
                MOVE.W  D0,D1
                ANDI.W  #mask0,D1
                CMP.W   #0,D1
                BGT     PRE_LIST_A7_OUTPUT
                BRA     PRE_LIST_DONE
                
PRE_LIST_A7_OUTPUT
                JSR     PRINT_SLASH
                MOVE.B  #'A',(A1)+
                MOVE.B  #'7',(A1)+

PRE_LIST_DONE
                RTS

*-----------------------------------------------------------
* POSTINCREMENT_LIST checks every bit in D0/D1 to see if the register needs to be enabled.
*
* D0 contains the register mask (a word).
* D1 holds a copy of D0 to be manipulated and compared.
* D2 remembers if the register is the first one seen. (1 is first, 0 otherwise.)
* 
* For postincrement, the list goes from A7 to A0, D7 to D0 (bits 15-0)
*-----------------------------------------------------------
POSTINCREMENT_LIST
                CLR.L   D2                          * Clear D2
                MOVE.B  #1,D2                       * Keep track of first register
                
                MOVE.W  D0,D1
                ANDI.W  #mask0,D1
                CMP.W   #0,D1
                BGT     POST_LIST_D0_OUTPUT
                BRA     POST_LIST_D1_CHECK
                
POST_LIST_D0_OUTPUT
                JSR     PRINT_SLASH
                MOVE.B  #'D',(A1)+
                MOVE.B  #'0',(A1)+
                
POST_LIST_D1_CHECK
                MOVE.W  D0,D1
                ANDI.W  #mask1,D1
                CMP.W   #0,D1
                BGT     POST_LIST_D1_OUTPUT
                BRA     POST_LIST_D2_CHECK
                
POST_LIST_D1_OUTPUT
                JSR     PRINT_SLASH
                MOVE.B  #'D',(A1)+
                MOVE.B  #'1',(A1)+
                
POST_LIST_D2_CHECK
                MOVE.W  D0,D1
                ANDI.W  #mask2,D1
                CMP.W   #0,D1
                BGT     POST_LIST_D2_OUTPUT
                BRA     POST_LIST_D3_CHECK
POST_LIST_D2_OUTPUT
                JSR     PRINT_SLASH
                MOVE.B  #'D',(A1)+
                MOVE.B  #'2',(A1)+

POST_LIST_D3_CHECK
                MOVE.W  D0,D1
                ANDI.W  #mask3,D1
                CMP.W   #0,D1
                BGT     POST_LIST_D3_OUTPUT
                BRA     POST_LIST_D4_CHECK

POST_LIST_D3_OUTPUT
                JSR     PRINT_SLASH
                MOVE.B  #'D',(A1)+
                MOVE.B  #'3',(A1)+

POST_LIST_D4_CHECK
                MOVE.W  D0,D1
                ANDI.W  #mask4,D1
                CMP.W   #0,D1
                BGT     POST_LIST_D4_OUTPUT
                BRA     POST_LIST_D5_CHECK

POST_LIST_D4_OUTPUT
                JSR     PRINT_SLASH
                MOVE.B  #'D',(A1)+
                MOVE.B  #'4',(A1)+

POST_LIST_D5_CHECK
                MOVE.W  D0,D1
                ANDI.W  #mask5,D1
                CMP.W   #0,D1
                BGT     POST_LIST_D5_OUTPUT
                BRA     POST_LIST_D6_CHECK
                
POST_LIST_D5_OUTPUT
                JSR     PRINT_SLASH
                MOVE.B  #'D',(A1)+
                MOVE.B  #'5',(A1)+

POST_LIST_D6_CHECK
                MOVE.W  D0,D1
                ANDI.W  #mask6,D1
                CMP.W   #0,D1
                BGT     POST_LIST_D6_OUTPUT
                BRA     POST_LIST_D7_CHECK

POST_LIST_D6_OUTPUT
                JSR     PRINT_SLASH
                MOVE.B  #'D',(A1)+
                MOVE.B  #'6',(A1)+

POST_LIST_D7_CHECK
                MOVE.W  D0,D1
                ANDI.W  #mask7,D1
                CMP.W   #0,D1
                BGT     POST_LIST_D7_OUTPUT
                BRA     POST_LIST_A0_CHECK
                
POST_LIST_D7_OUTPUT
                JSR     PRINT_SLASH
                MOVE.B  #'D',(A1)+
                MOVE.B  #'7',(A1)+

POST_LIST_A0_CHECK
                MOVE.W  D0,D1
                ANDI.W  #mask8,D1
                CMP.W   #0,D1
                BGT     POST_LIST_A0_OUTPUT
                BRA     POST_LIST_A1_CHECK
                
POST_LIST_A0_OUTPUT
                JSR     PRINT_SLASH
                MOVE.B  #'A',(A1)+
                MOVE.B  #'0',(A1)+
                
POST_LIST_A1_CHECK
                MOVE.W  D0,D1
                ANDI.W  #mask9,D1
                CMP.W   #0,D1
                BGT     POST_LIST_A1_OUTPUT
                BRA     POST_LIST_A2_CHECK
                
POST_LIST_A1_OUTPUT
                JSR     PRINT_SLASH
                MOVE.B  #'A',(A1)+
                MOVE.B  #'1',(A1)+
                
POST_LIST_A2_CHECK
                MOVE.W  D0,D1
                ANDI.W  #mask10,D1
                CMP.W   #0,D1
                BGT     POST_LIST_A2_OUTPUT
                BRA     POST_LIST_A3_CHECK
POST_LIST_A2_OUTPUT
                JSR     PRINT_SLASH
                MOVE.B  #'A',(A1)+
                MOVE.B  #'2',(A1)+

POST_LIST_A3_CHECK
                MOVE.W  D0,D1
                ANDI.W  #mask11,D1
                CMP.W   #0,D1
                BGT     POST_LIST_A3_OUTPUT
                BRA     POST_LIST_A4_CHECK

POST_LIST_A3_OUTPUT
                JSR     PRINT_SLASH
                MOVE.B  #'A',(A1)+
                MOVE.B  #'3',(A1)+

POST_LIST_A4_CHECK
                MOVE.W  D0,D1
                ANDI.W  #mask12,D1
                CMP.W   #0,D1
                BGT     POST_LIST_A4_OUTPUT
                BRA     POST_LIST_A5_CHECK

POST_LIST_A4_OUTPUT
                JSR     PRINT_SLASH
                MOVE.B  #'A',(A1)+
                MOVE.B  #'4',(A1)+

POST_LIST_A5_CHECK
                MOVE.W  D0,D1
                ANDI.W  #mask13,D1
                CMP.W   #0,D1
                BGT     POST_LIST_A5_OUTPUT
                BRA     POST_LIST_A6_CHECK
                
POST_LIST_A5_OUTPUT
                JSR     PRINT_SLASH
                MOVE.B  #'A',(A1)+
                MOVE.B  #'5',(A1)+

POST_LIST_A6_CHECK
                MOVE.W  D0,D1
                ANDI.W  #mask14,D1
                CMP.W   #0,D1
                BGT     POST_LIST_A6_OUTPUT
                BRA     POST_LIST_A7_CHECK

POST_LIST_A6_OUTPUT
                JSR     PRINT_SLASH
                MOVE.B  #'A',(A1)+
                MOVE.B  #'6',(A1)+

POST_LIST_A7_CHECK
                MOVE.W  D0,D1
                ANDI.W  #mask15,D1
                CMP.W   #$8000,D1
                BEQ     POST_LIST_A7_OUTPUT
                BRA     POST_LIST_DONE
                
POST_LIST_A7_OUTPUT
                JSR     PRINT_SLASH
                MOVE.B  #'A',(A1)+
                MOVE.B  #'7',(A1)+

POST_LIST_DONE
                RTS


*-----------------------------------------------------------
* PRINT_SLASH
*
* Print a slash if the register isn't the first in the list.
* D1 holds whether it's the first. 1 is true, 0 is false.
*-----------------------------------------------------------
PRINT_SLASH
                CMP.B   #1,D2                   * first one doesn't print
                BEQ     PRINT_SLASH_CONTINUED
                BRA     PRINT_SLASH_YES
                
PRINT_SLASH_YES
                MOVE.B  #'/',(A1)+              * Move / to buffer
                BRA     PRINT_SLASH_CONTINUED
                
PRINT_SLASH_CONTINUED
                MOVE.B  #0,D2                   * At this point, other registers won't be first
                RTS
                
*-----------------------------------------------------------
* OPMODE_LIST_EA (long)
* <list>,<ea>
*
* For postincrement, the list goes from A7 to A0, D7 to D0 (bits 15-0)
* For predecrement, the list goes from D0 to D7, A0 to A7 (bits 15-0)
*-----------------------------------------------------------
OPMODE_LIST_EA_LONG
                JSR     ADD_DOT_L                   * Add .L to output buffer
                
                CMP.B   #%011,D5                    * Cannot have post incrementing (addressing mode) here
                BEQ     INVALID_OPCODE
                
                MOVE.W  (A5)+,D0                    * Store register list mask in D0
                
                CMP.B   #%100,D5                    * Check which kind of list to output
                BEQ     OPMODE_LIST_EA_LONG_PRE_LIST
                BRA     OPMODE_LIST_EA_LONG_POST_LIST

*-----------------------------------------------------------
* Prints out predecrement list
*-----------------------------------------------------------
OPMODE_LIST_EA_LONG_PRE_LIST
                JSR     PREDECREMENT_LIST
                BRA     OPMODE_LIST_EA_LONG_CONTINUED

*-----------------------------------------------------------
* Prints out postincrement list
*-----------------------------------------------------------
OPMODE_LIST_EA_LONG_POST_LIST
                JSR     POSTINCREMENT_LIST

*-----------------------------------------------------------
* Continue with rest of code
*-----------------------------------------------------------
OPMODE_LIST_EA_LONG_CONTINUED
                MOVE.B  #',',(A1)+
                
                CMP.B   #%111,D5
                BNE     OPMODE_LIST_EA_LONG_CONTINUED2
                
                CMP.B   #%000,D6
                BEQ     LIST_EA_LONG_ABSOLUTE_SHORT
                
                CMP.B   #%001,D6
                BEQ     LIST_EA_LONG_ABSOLUTE_LONG
                
                BRA     INVALID_OPCODE
                
LIST_EA_LONG_ABSOLUTE_SHORT
                MOVE.B  #'$',(A1)+
                JSR     PRINT_NEXT_WORD
                BRA     TEST_OUTPUT
LIST_EA_LONG_ABSOLUTE_LONG
                MOVE.B  #'$',(A1)+
                JSR     PRINT_NEXT_WORD
                JSR     PRINT_NEXT_WORD
                BRA     TEST_OUTPUT
OPMODE_LIST_EA_LONG_CONTINUED2
                BRA     EA_BYTE
                
*-----------------------------------------------------------
* OPMODE_EA_LIST (word)
* <ea>,<list>
*
* For postincrement, the list goes from A7 to A0, D7 to D0 (bits 15-0)
* For predecrement, the list goes from D0 to D7, A0 to A7 (bits 15-0)
*-----------------------------------------------------------
OPMODE_EA_LIST_WORD
                JSR     ADD_DOT_W                   * Add .W to output buffer
                
                CMP.B   #%100,D5                    * <ea>,<list> cannot have predecrementing mode
                BEQ     INVALID_OPCODE
                
                MOVE.W  (A5)+,D0                    * Store register mask
                MOVEM.L D0,-(SP)                    * Save register mask
                
                CMP.B   #%111,D5
                BNE     OPMODE_EA_LIST_WORD2
                
                CMP.B   #%000,D6
                BEQ     EA_LIST_WORD_ABSOLUTE_SHORT
                
                CMP.B   #%001,D6
                BEQ     EA_LIST_WORD_ABSOLUTE_LONG
                
                BRA     INVALID_OPCODE
                
EA_LIST_WORD_ABSOLUTE_SHORT
                MOVE.B  #'$',(A1)+
                JSR     PRINT_NEXT_WORD
                MOVEM.L (SP)+,D0                    * Restore register mask
                BRA     OPMODE_EA_LIST_WORD3
                
EA_LIST_WORD_ABSOLUTE_LONG
                MOVE.B  #'$',(A1)+
                JSR     PRINT_NEXT_WORD
                JSR     PRINT_NEXT_WORD
                MOVEM.L (SP)+,D0                    * Restore register mask
                BRA     OPMODE_EA_LIST_WORD3
                
OPMODE_EA_LIST_WORD2
                JSR     EA_Byte_1                   * Get <ea> information
                MOVEM.L (SP)+,D0                    * Restore register mask
OPMODE_EA_LIST_WORD3
                MOVE.B  #',',(A1)+                  * Separate <ea> and <list> with comma
                
                JSR     POSTINCREMENT_LIST          * Print out postincrement list of registers
                
                BRA     TEST_OUTPUT

                
*-----------------------------------------------------------
* OPMODE_EA_LIST (long)
* <ea>,<list>
*
* For postincrement, the list goes from A7 to A0, D7 to D0 (bits 15-0)
* For predecrement, the list goes from D0 to D7, A0 to A7 (bits 15-0)
*-----------------------------------------------------------
OPMODE_EA_LIST_LONG
                JSR     ADD_DOT_L                   * Add .L to output buffer
                
                CMP.B   #%100,D5                    * <ea>,<list> cannot have predecrementing mode
                BEQ     INVALID_OPCODE
                
                MOVE.W  (A5)+,D0                    * Store register mask
                MOVEM.L D0,-(SP)                    * Save register mask
                
                CMP.B   #%111,D5
                BNE     OPMODE_EA_LIST_LONG2
                
                CMP.B   #%000,D6
                BEQ     EA_LIST_LONG_ABSOLUTE_SHORT
                
                CMP.B   #%001,D6
                BEQ     EA_LIST_LONG_ABSOLUTE_LONG
                
                BRA     INVALID_OPCODE
                
EA_LIST_LONG_ABSOLUTE_SHORT
                MOVE.B  #'$',(A1)+
                JSR     PRINT_NEXT_WORD
                MOVEM.L (SP)+,D0                    * Restore register mask
                BRA     OPMODE_EA_LIST_LONG3
                
EA_LIST_LONG_ABSOLUTE_LONG
                MOVE.B  #'$',(A1)+
                JSR     PRINT_NEXT_WORD
                JSR     PRINT_NEXT_WORD
                MOVEM.L (SP)+,D0                    * Restore register mask
                BRA     OPMODE_EA_LIST_LONG3
                
OPMODE_EA_LIST_LONG2
                JSR     EA_Byte_1                   * Get <ea> information
                MOVEM.L (SP)+,D0                    * Restore register mask
OPMODE_EA_LIST_LONG3
                MOVE.B  #',',(A1)+                  * Separate <ea> and <list> with comma
                
                JSR     POSTINCREMENT_LIST          * Print out postincrement list of registers
                
                BRA     TEST_OUTPUT

*-----------------------------------------------------------
* OPMODE_EA (byte)
* <ea>
*-----------------------------------------------------------
OPMODE_EA_BYTE
                JSR     ADD_DOT_B
                BRA     EA_Byte

*-----------------------------------------------------------
* OPMODE_EA (word)
* <ea>
*-----------------------------------------------------------
OPMODE_EA_WORD
                JSR     ADD_DOT_W
                BRA     EA_Word
                
*-----------------------------------------------------------
* OPMODE_EA (long)
* <ea>
*-----------------------------------------------------------
OPMODE_EA_LONG
                JSR     ADD_DOT_L
                BRA     EA_Long

*-----------------------------------------------------------
* End of EA decoding
*
* A5 is the current address
* D0 stores a word of data
* D1 stores the instruction (bits 15 - 12)
* D3 will hold bits 11 - 9
* D4 will hold bits 8 - 6
* D5 will hold bits 5 - 3
* D6 will hold bits 2 - 0
*-----------------------------------------------------------
DECODE_EA
                BRA     TEST_OUTPUT
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

END_SEG    SIMHALT             ; halt simulator

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
