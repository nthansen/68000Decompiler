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


RTS       EQU     %0100111001110101 
NOP       EQU     %0100111001110001  
    
    
    ORG    $1000
START:                  ; first instruction of program
        LEA     STACK, SP           *Get the stak pointer
        
        JSR     GET_START_ADDR
        JSR     CLEAR_ALL
        
        RTS
        
            
*/////////////////////SUBROUTINES/////////////////////////
DATA_LOOP
        CMP.L   A4,A5
        BEQ     DONE
        MOVE.W (A4)+,D3 
        JSR PRINT_CURRENT_ADDR   
        JSR DECODE_OPCODE
        BRA DATA_LOOP  

PRINT           
        MOVE.B  #$00,(A1)                 * Terminate the string
        CLR.L   D0                        * Clear D0   
        MOVE.B  #13,D0                    * Load task number 14 for printing
        LEA     buffer,A1                 * Load the buffer into A1 
        TRAP    #15                       * Print the buffer              
        RTS

*TEST FOR PRINT SUBROUTINE
DISPLAY_COMMAND 
        CLR.L   D2
        *MOVE.L  #buffer,A1
        *MOVE.B  #'D',(A1)+
        *MOVE.B  #'A',(A1)+
        *MOVE.B  #' ',(A1)+  
        *BRA     PRINT
        RTS

PRINT_CURRENT_ADDR
        CLR.L   D7
        MOVE.L  #buffer,A1      *Load the buffer
        *Get the first number
        MOVE.L  A4,D7           *Get the address
        LSR.L   #$08,D7        
        LSR.L   #$08,D7         
        LSR.L   #$08,D7         
        LSR.L   #$04,D7
        JSR     HEX_TO_CHAR     *Convert HEX to char         
        MOVE.B  D7,(A1)+        *Push to the buffer
        CLR.L   D7              *Clear D7
        *Get the second number
        MOVE.L  A4,D7
        LSL.L   #$04,D7         
        LSR.L   #$08,D7         
        LSR.L   #$08,D7         
        LSR.l   #$08,D7         
        LSR.L   #$04,D7
        JSR     HEX_TO_CHAR     *Convert HEX to char
        MOVE.B  D7,(A1)+ 
        CLR.L   D7              *Clear D7        
        *Get the third number
        MOVE.L  A4,D7           
        LSL.L   #$08,D7         
        LSR.L   #$08,D7         
        LSR.L   #$08,D7         
        LSR.L   #$08,D7         
        LSR.L   #$04,D7
        JSR     HEX_TO_CHAR     *Convert HEX to char         
        MOVE.B  D7,(A1)+
        CLR.L   D7              *Clear D7
        *Get the forth number
        MOVE.L  A4,D7
        LSL.L   #$08,D7         
        LSL.L   #$04,D7         
        LSR.L   #$08,D7         
        LSR.L   #$08,D7         
        LSR.L   #$08,D7         
        LSR.L   #$04,D7
        JSR     HEX_TO_CHAR     *Convert HEX to char         
        MOVE.B  D7,(A1)+
        CLR.L   D7              *Clear D7
        *Get the fifth number
        MOVE.L  A4,D7
        LSL.L   #$08,D7         
        LSL.L   #$08,D7         
        LSR.L   #$08,D7         
        LSR.L   #$08,D7         
        LSR.L   #$08,D7         
        LSR.L   #$04,D7
        JSR     HEX_TO_CHAR     *Convert HEX to char
        MOVE.B  D7,(A1)+
        CLR.L   D7              *Clear D7
        *Get the sixth number
        MOVE.L  A4,D7
        LSL.L   #$08,D7         
        LSL.L   #$08,D7         
        LSL.L   #$04,D7        
        LSR.L   #$08,D7         
        LSR.L   #$08,D7         
        LSR.L   #$08,D7         
        LSR.L   #$04,D7
        JSR     HEX_TO_CHAR     *Convert HEX to char         
        MOVE.B  D7,(A1)+
        CLR.L   D7              *Clear D7 
        *Get the seventh number
        MOVE.L  A4,D7
        LSL.L   #$08,D7        
        LSL.L   #$08,D7         
        LSL.L   #$08,D7         
        LSR.L   #$08,D7         
        LSR.L   #$08,D7         
        LSR.L   #$08,D7         
        LSR.L   #$04,D7
        JSR     HEX_TO_CHAR     *Convert HEX to char
        MOVE.B  D7,(A1)+
        CLR.L   D7              *Clear D7
        *Get the eight number
        MOVE.L  A4,D7
        LSL.L   #$08,D7         
        LSL.L   #$08,D7         
        LSL.L   #$08,D7         
        LSL.L   #$04,D7         
        LSR.L   #$08,D7         
        LSR.L   #$08,D7         
        LSR.L   #$08,D7         
        LSR.L   #$04,D7
        JSR     HEX_TO_CHAR     *Convert HEX to char         
        MOVE.B  D7,(A1)+ 
        CLR.L   D7              *Clear D7        
        BRA     PRINT
        RTS

HEX_TO_CHAR                                                                                                   
        CMP.B   #$9,D7                    *Check if digit                            
        BLE     DIG_TO_ASCII              *Convert digit                 
        BRA     LET_TO_ASCII              *Convert letter
                                                                                                    
DIG_TO_ASCII                                                                                               
        ADDI.b  #$30,D7                                                                  
        RTS
                                                                                                              
LET_TO_ASCII                                                                                            
        ADDI.B  #$37,D7                                                                   
        RTS
        
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
        
        JSR     CLEAR_ALL        
        JSR     GET_ENDING_ADDR
         

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
        
        JSR     CLEAR_ALL
        JSR     DATA_LOOP        
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
        
WRONG_INPUT
        LEA     INPUT_ERR,A1
        MOVE.B  #14,D0
        TRAP    #15
        CLR.L   D3
        JSR     CLEAR_ALL
        BRA     GET_START_ADDR

INPUT_TOO_SHORT
        LEA     INPUT_SHORT_ERR,A1
        MOVE.B  #14,D0
        TRAP    #15
        JSR     CLEAR_ALL
        BRA     GET_START_ADDR

INPUT_TOO_LONG
        LEA     INPUT_LONG_ERR,A1
        MOVE.B  #14,D0
        TRAP    #15
        JSR     CLEAR_ALL
        BRA     GET_START_ADDR

ODD_INPUT
        LEA     ODD_ERR,A1
        MOVE.B  #14,D0
        TRAP    #15
        JSR     CLEAR_ALL
        BRA     GET_START_ADDR

DISPLAY_NEG_ERR
        LEA     NEG_ADDR,A1
        MOVE.B  #14,D0
        TRAP    #15
        JSR     CLEAR_ALL
        BRA     GET_START_ADDR

CLEAR_ALL               *This function clears all of the data registers
        CLR.L   D1      *Clear D1
        CLR.L   D2      *Clear D2
        CLR.L   D3      *Clear D3
        CLR.L   D4      *Clear D4
        CLR.L   D5      *Clear D5
        CLR.L   D6      *Clear D6
        CLR.L   D7      *Clear D7
        RTS  
*////////////////////////////////////////////////////////////////////////////////////////
* OPCODE!!!
*////////////////////////////////////////////////////////////////////////////////////////

SETUP_VALUES:

    MOVE.W      D7,D1                   * For first four values
    MOVE.W      D7,D2                   * For holding Source MODE
    MOVE.W      D7,D3                   * For holding Source REG
    MOVE.W      D7,D4                   * For holding Destination MODE
    MOVE.W      D7,D5                   * For holding Destination REG
    
    ASR.L       #$8,D1                  * Shift to seperate the first four values
    ASR.L       #$4,D1                  * Put in the right spot
    
    LSL         #8,D5                   * Remove starting address
    LSL         #2,D5                   * Remove offset
    LSR         #8,D5                   * Put back into place
    LSR         #5,D5                   * Remove Register     
        
    LSL         #8,D4                   * Remove starting address
    LSL         #5,D4                   * Remove offset
    LSR         #8,D4                   * Put back into place
    LSR         #5,D4                   * Remove Excess     
    
    LSL         #7,D2                   * Remove starting address
    LSR         #8,D2                   * Put back in place
    LSR         #5,D2                   * Remove excess
    
    LSL         #4,D3
    LSR         #8,D3
    LSR         #5,D3
    
    RTS

DECODE_OPCODE 
    JSR SETUP_VALUES        * Setup the data registers to the opcode we received to see what to do
    CMP.W   #$0,D1          
    BEQ     DECODE_0        * Decode all the opcodes that start with 0000
    CMP.W   #$1,D1          
    BEQ     DECODE_1        * Decode all the opcodes that start with 0001
    CMP.W   #$2,D1          
    BEQ     DECODE_2        * Decode all the opcodes that start with 0010
    CMP.W   #$3,D1          
    BEQ     DECODE_3        * Decode all the opcodes that start with 0011
    CMP.W   #$4,D1          
    BEQ     DECODE_4        * Decode all the opcodes that start with 0100
    CMP.W   #$5,D1          
    BEQ     DECODE_5        * Decode all the opcodes that start with 0101
    CMP.W   #$6,D1          
    BEQ     DECODE_6        * Decode all the opcodes that start with 0110
    CMP.W   #$7,D1          
    BEQ     data_error      * None of the required opcodes start with 0111 so throw error
    CMP.W   #$8,D1          
    BEQ     DECODE_8        * Decode all the opcodes that start with 1000
    CMP.W   #$9,D1          
    BEQ     DECODE_9        * Decode all the opcodes that start with 1001
    CMP.W   #$A,D1          
    BEQ     data_error      * None of the required opcodes start with 1010 so throw error
    CMP.W   #$B,D1          
    BEQ     DECODE_B        * Decode all the opcodes that start with 1011
    CMP.W   #$C,D1          
    BEQ     DECODE_C        * Decode all the opcodes that start with 1100
    CMP.W   #$D,D1          
    BEQ     DECODE_D        * Decode all the opcodes that start with 1101
    CMP.W   #$E,D1          
    BEQ     DECODE_E        * Decode all the opcodes that start with 1110
    CMP.W   #$F,D1          
    BEQ     data_error      * None of the required opcodes start with 1111 so throw error

*////////////////////////////////////////////////////////////////////////////////////////
*code0000: Bit manipulation/MOVEP/Immediate
* ORI - CMPI - BCLR
*////////////////////////////////////////////////////////////////////////////////////////    
DECODE_0
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    LSR.B   #2,D0                           * Shift right by 2 bits
    ANDI.B  #$01,D0                         * Get bit 8
    CMP.B   #1,D0                           * Check if 1
    BEQ     BCLR_dynamic_check

    MOVE.W  D7,D0                           * Copy the WORD data to D0
    LSR.W   #6,D0                           * Shift right by 6 bits
    ANDI.W  #$3F,D0                         * Get bits 6-11
    CMP.B   #34,D0                          * Check if 34
    BEQ     is_BCLR_static                        

    CMP.B   #0,D5                           * ORI
    BEQ     is_ORI
    
    CMP.B   #6,D5                           * CMPI
    BEQ     is_CMPI
    
    BRA     data_error                      * Other not required instructions
    
BCLR_dynamic_check    
    CMP.B   #6,D4                           * BCLR dynamic
    BEQ     is_BCLR_dynamic
    
    BRA     data_error                      * Other not required instructions    
    
is_ORI
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error
    MOVE.B  #'O',(A1)+
    MOVE.B  #'R',(A1)+
    MOVE.B  #'I',(A1)+
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bit 6-7 for size
    JSR     get_size                        * Get size
    MOVE.B  #' ',(A1)+                      * Add a space
    CLR.L   D1
    MOVE.B  D0,D1                           * Copy byte size to D1
    JSR     GET_EA_ID                      * Get immediate data
    CLR.L   D0
    MOVE.B  D1,D0                           * Copy byte size back to D0
    MOVE.B  #',',(A1)+
    JSR     GETDESTINATION                      * Get destination EA
    BRA     Print       

is_CMPI
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error
    MOVE.B  #'C',(A1)+
    MOVE.B  #'M',(A1)+
    MOVE.B  #'P',(A1)+
    MOVE.B  #'I',(A1)+
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bit 6-7 for size
    JSR     get_size                        * Get size
    MOVE.B  #' ',(A1)+                      * Add a space
    CLR.L   D1
    MOVE.B  D0,D1                           * Copy byte size to D1
    JSR     GET_EA_ID                       * Get immediate data
    CLR.L   D0
    MOVE.B  D1,D0                           * Copy byte size back to D0
    MOVE.B  #',',(A1)+
    JSR     GETDESTINATION                  * Get destination EA
    BRA     Print    

is_BCLR_dynamic
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error
    MOVE.B  #'B',(A1)+
    MOVE.B  #'C',(A1)+
    MOVE.B  #'L',(A1)+
    MOVE.B  #'R',(A1)+
    MOVE.B  #' ',(A1)+                      * Add a space
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer
    MOVE.B  #',',(A1)+
    JSR     GETDESTINATION                          * Get destination EA        
    BRA     Print    

is_BCLR_static
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error
    MOVE.B  #'B',(A1)+
    MOVE.B  #'C',(A1)+
    MOVE.B  #'L',(A1)+
    MOVE.B  #'R',(A1)+
    MOVE.B  #' ',(A1)+                      * Add a space
    CLR.L   D0
    MOVE.B  #1,D0                           * byte size is 2
    JSR     GET_EA_ID                  * get immediate data
    MOVE.B  #',',(A1)+
    JSR     GETDESTINATION                          * Get destination EA        
    BRA     Print      

*////////////////////////////////////////////////////////////////////////////////////////
*code0001: MOVE Byte
*////////////////////////////////////////////////////////////////////////////////////////  
DECODE_1
    CMP.B   #1,D4                               * Check invalid EA mode
    BEQ     data_error
    MOVE.B  #'M',(A1)+
    MOVE.B  #'O',(A1)+
    MOVE.B  #'V',(A1)+
    MOVE.B  #'E',(A1)+
    MOVE.B  #'.',(A1)+
    MOVE.B  #'B',(A1)+
    MOVE.B  #' ',(A1)+                          * Add a space
    CLR.L   D0                                  *Clear D0
    MOVE.B  #1,D0                               *size is 1 byte   
    JSR     GETSOURCE                      *Jump to EAMode
    MOVE.B  #',',(A1)+ 
    CMP.B   #1,D3                               *An not allowed
    BEQ     data_error
    JSR     GETDESTINATION                           *Jump to EAMode
    
    BRA     Print

*////////////////////////////////////////////////////////////////////////////////////////
*code0001: MOVE Long
*//////////////////////////////////////////////////////////////////////////////////////// 
DECODE_2    
    MOVE.B  #'M',(A1)+
    MOVE.B  #'O',(A1)+
    MOVE.B  #'V',(A1)+
    MOVE.B  #'E',(A1)+ 
    JSR     MOVEA_check                     *Check for MOVEA       
    MOVE.B  #'.',(A1)+
    MOVE.B  #'L',(A1)+
    MOVE.B  #' ',(A1)+                      * Add a space
    CLR.L   D0                              *Clear D0
    MOVE.B  #4,D0                           *size is 4 bytes     
    JSR     GETSOURCE                          *Jump to EAMode 
    MOVE.B  #',',(A1)+  
    CLR.L   D2
    CLR.L   D3
    MOVE.B  D4,D3                           *Get Destination MODE
    MOVE.B  D5,D2                           *Get Source REG
    JSR     GETDESTINATION                          *Jump to EAMode
    
    BRA     Print


*////////////////////////////////////////////////////////////////////////////////////////
*code0011: MOVE Word
*//////////////////////////////////////////////////////////////////////////////////////// 
DECODE_3    
    MOVE.B  #'M',(A1)+
    MOVE.B  #'O',(A1)+
    MOVE.B  #'V',(A1)+
    MOVE.B  #'E',(A1)+  
    JSR     MOVEA_check                     *Check for MOVEA   
    MOVE.B  #'.',(A1)+
    MOVE.B  #'W',(A1)+
    MOVE.B  #' ',(A1)+                      * Add a space
    CLR.L   D0                              *Clear D0
    MOVE.B  #2,D0                           *size is 2 bytes      
    JSR     GETSOURCE                          *Jump to EAMode 
    MOVE.B  #',',(A1)+ 
    CLR.L   D2
    CLR.L   D3
    MOVE.B  D4,D3                           *Get Destination MODE
    MOVE.B  D5,D2                           *Get Source REG
    JSR     GETDESTINATION                          *Jump to EAMode
    
    BRA     Print

*////////////////////////////////////////////////////////////////////////////////////////
*MOVEA_check: check if MOVEA, then add 'A' to print buffer
*D4: hold the Destination MODE for comparison
*//////////////////////////////////////////////////////////////////////////////////////// 
MOVEA_check
    CMP.B   #1,D4                           
    BEQ     is_MOVEA
    RTS

is_MOVEA
    MOVE.B  #'A',(A1)+
    RTS

*////////////////////////////////////////////////////////////////////////////////////////
*code0100: Miscellaneous
* NOP - NEG - RTS - JSR - MOVEM - LEA
*////////////////////////////////////////////////////////////////////////////////////////
DECODE_4
    MOVE.W  D7,D0                      * Copy the WORD data to D0
    CMP.W   #$4E71,D0                       * NOP
    BEQ     is_NOP

    CMP.W   #$4E75,D0                       * RTS
    BEQ     is_RTS

    LSR.W   #8,D0                           * Shift right by 8 bits
    ANDI.W  #$0F,D0                         * Get bits 8-11
    CMP.B   #4,D0                           * Check if 4
    BEQ     is_NEG                          * NEG

    CMP.B   #7,D4                           * LEA
    BEQ     is_LEA

    MOVE.W  D7,D0                      * Copy the WORD data to D0
    LSR.W   #6,D0                           * Shift right by 6 bits
    ANDI.W  #$3F,D0                         * Get bits 6-11
    CMP.B   #58,D0                          * JSR
    BEQ     is_JSR                                          

    CMP.B   #34,D0                          * MOVEM reg to mem word
    BEQ     is_MOVEM_word_reg_to_mem

    CMP.B   #35,D0                          * MOVEM reg to mem long
    BEQ     is_MOVEM_long_reg_to_mem

    CMP.B   #50,D0                          * MOVEM mem to reg word
    BEQ     is_MOVEM_word_mem_to_reg

    CMP.B   #51,D0                          * MOVEM mem to reg long
    BEQ     is_MOVEM_long_mem_to_reg     
    
    BRA     data_error                      * Other not required instructions

is_NOP
    MOVE.B  #'N',(A1)+
    MOVE.B  #'O',(A1)+
    MOVE.B  #'P',(A1)+
    BRA     Print

is_RTS
    MOVE.B  #'R',(A1)+
    MOVE.B  #'T',(A1)+
    MOVE.B  #'S',(A1)+
    BRA     Print

is_NEG
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error
    MOVE.B  #'N',(A1)+
    MOVE.B  #'E',(A1)+
    MOVE.B  #'G',(A1)+        
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bit 6-7 for size
    JSR     get_size                        * Get size
    MOVE.B  #' ',(A1)+                      * Add a space
    JSR     GETDESTINATION                          * Get destination EA
    BRA     Print

is_LEA
    CMP.B   #0,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #3,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #4,D3                           * Check invalid EA mode
    BEQ     data_error
    MOVE.B  #'L',(A1)+
    MOVE.B  #'E',(A1)+
    MOVE.B  #'A',(A1)+
    MOVE.B  #' ',(A1)+                      * Add a space
    JSR     GETDESTINATION                          * Get EA
    MOVE.B  #',',(A1)+
    MOVE.B  #'A',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer
    BRA     Print         

is_JSR
    CMP.B   #0,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #3,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #4,D3                           * Check invalid EA mode
    BEQ     data_error
    MOVE.B  #'J',(A1)+
    MOVE.B  #'S',(A1)+
    MOVE.B  #'R',(A1)+
    MOVE.B  #' ',(A1)+                      * Add a space
    JSR     GETDESTINATION                          * Get EA
    BRA     Print

is_MOVEM_word_reg_to_mem
    CMP.B   #0,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #3,D3                           * Check invalid EA mode
    BEQ     data_error
    MOVE.B  #'M',(A1)+
    MOVE.B  #'O',(A1)+
    MOVE.B  #'V',(A1)+
    MOVE.B  #'E',(A1)+
    MOVE.B  #'M',(A1)+
    MOVE.B  #'.',(A1)+
    MOVE.B  #'W',(A1)+    
    MOVE.B  #' ',(A1)+                      * Add a space
    BRA     reg_to_mem 
                       
is_MOVEM_long_reg_to_mem
    CMP.B   #0,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #3,D3                           * Check invalid EA mode
    BEQ     data_error
    MOVE.B  #'M',(A1)+
    MOVE.B  #'O',(A1)+
    MOVE.B  #'V',(A1)+
    MOVE.B  #'E',(A1)+
    MOVE.B  #'M',(A1)+
    MOVE.B  #'.',(A1)+
    MOVE.B  #'L',(A1)+     
    MOVE.B  #' ',(A1)+                      * Add a space
    BRA     reg_to_mem

is_MOVEM_word_mem_to_reg
    CMP.B   #0,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #4,D3                           * Check invalid EA mode
    BEQ     data_error
    MOVE.B  #'M',(A1)+
    MOVE.B  #'O',(A1)+
    MOVE.B  #'V',(A1)+
    MOVE.B  #'E',(A1)+
    MOVE.B  #'M',(A1)+
    MOVE.B  #'.',(A1)+
    MOVE.B  #'W',(A1)+     
    MOVE.B  #' ',(A1)+                      * Add a space
    BRA     mem_to_reg

is_MOVEM_long_mem_to_reg
    CMP.B   #0,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #4,D3                           * Check invalid EA mode
    BEQ     data_error
    MOVE.B  #'M',(A1)+
    MOVE.B  #'O',(A1)+
    MOVE.B  #'V',(A1)+
    MOVE.B  #'E',(A1)+
    MOVE.B  #'M',(A1)+
    MOVE.B  #'.',(A1)+
    MOVE.B  #'L',(A1)+    
    MOVE.B  #' ',(A1)+                      * Add a space
    BRA     mem_to_reg

reg_to_mem
    CMP.B   #4,D3                           * check for predecrement
    BEQ     reg_to_mem_pre
    LEA     MOVEM_post,A2                   * Not predecrement, then postincrement    

reg_to_mem_cont
    CLR.L   D0
    MOVE.W  (A6)+,D0                        * Get WORD and advance memory pointer
    CLR.L   D1
    MOVE.B  #15,D1                          * Counter for 16 bits
    CLR.L   D7
    MOVE.B  #31,D7                          * Counter for getting registers number   
    CLR.L   D4
    MOVE.B  #30,D4                          * Counter for getting registers letter  
    JSR     MOVEM_mask_loop                 * Get the registers
    MOVE.B  #',',(A1)+
    JSR     GETDESTINATION                          * Get destination EA
    BRA     Print    

reg_to_mem_pre
    LEA     MOVEM_pre,A2                    * Load predecrement string to A2
    BRA     reg_to_mem_cont    

mem_to_reg
    CLR.L   D5
    MOVE.W  (A6)+,D5                        * Save WORD for registers
    JSR     GETDESTINATION                          * Get destination EA    
    MOVE.B  #',',(A1)+
    CMP.B   #4,D3                           * check for predecrement
    BEQ     mem_to_reg_pre
    LEA     MOVEM_post,A2                   * Not predecrement, then postincrement    

mem_to_reg_cont    
    CLR.L   D0
    MOVE.W  D5,D0                           * Get registers WORD
    CLR.L   D1
    MOVE.B  #15,D1                          * Counter for 16 bits
    CLR.L   D7
    MOVE.B  #31,D7                          * Counter for getting registers number   
    CLR.L   D4
    MOVE.B  #30,D4                          * Counter for getting registers letter
    JSR     MOVEM_mask_loop                 * Get the registers
    BRA     Print

mem_to_reg_pre
    LEA     MOVEM_pre,A2                    * Load predecrement string to A2
    BRA     mem_to_reg_cont  

*////////////////////////////////////////////////////////////////////////////////////////
*MOVEM_mask_loop: get the corresponding registers in the operand for MOVEM instruction
*////////////////////////////////////////////////////////////////////////////////////////     
MOVEM_mask_loop
    CLR.L   D5
    MOVE.W  D0,D5                           * Copy D0 to D5
    ANDI.W  #$0001,D5                       * Get the first bit only
    CMP.B   #0,D5
    BNE     MOVEM_get_register              * Bit is not 0    
    SUBI    #2,D7                           * Decrease counter for registers number
    SUBI    #2,D4                           * Decrease counter for registers letter   
   
MOVEM_mask_loop_cont
    LSR.W   #1,D0                           * Shift right by 1 bit
    SUBI    #1,D1                           * Decrease counter    
    CMPI    #0,D1                           * Check counter
    BGE     MOVEM_mask_loop
    MOVE.B  -(A1),D0                        * Get rid of extra '/'
  
    RTS
             
MOVEM_get_register
    MOVE.B  (A2,D4),(A1)+                   * get the register
    SUBI    #2,D4                           * Decrease counter for registers number
    MOVE.B  (A2,D7),(A1)+                   * get the register
    SUBI    #2,D7                           * Decrease counter for registers letter    
    MOVE.B  #'/',(A1)+     
    BRA     MOVEM_mask_loop_cont

*////////////////////////////////////////////////////////////////////////////////////////
*code0101: ADDQ/SUBQ/Scc/DBcc
* SUBQ
*////////////////////////////////////////////////////////////////////////////////////////    
DECODE_5
    CLR.L   D0
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    LSR.B   #2,D0                           * Shift right 2 bits
    ANDI.B  #$01,D0                         * Mask all bits except first
    BNE     check_SUBQ                      * Not 0, may be SUBQ
    
    BRA     data_error
    
check_SUBQ
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get first 2 bits
    CMPI    #3,D0                           * Not 3, then SUBQ
    BNE     is_SUBQ

    BRA     data_error

is_SUBQ
    MOVE.B  #'S',(A1)+
    MOVE.B  #'U',(A1)+
    MOVE.B  #'B',(A1)+
    MOVE.B  #'Q',(A1)+
    JSR     get_size                        * Get size
    MOVE.B  #' ',(A1)+                      * Add a space
    MOVE.B  #'#',(A1)+
    MOVE.B  #'$',(A1)+    
    JSR     SUBQ_data
    MOVE.B  #',',(A1)+
    JSR     GETDESTINATION                          * Get EA destination    
    BRA     Print    
    
SUBQ_data
    CMPI    #0,D5                           * Compare data to 0
    BEQ     SUBQ_data_zero

SUBQ_data_cont    
    ADD     #$30,D5                         *Convert hex number to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer
    RTS   
    
SUBQ_data_zero
    ADDI    #8,D5                           * 0 represents 8
    BRA     SUBQ_data_cont

*////////////////////////////////////////////////////////////////////////////////////////
*code0110: BSR,BRA,Bcc
* BRA - BCS - BVC - BGE - BLT
*////////////////////////////////////////////////////////////////////////////////////////           
DECODE_6
    CLR.L   D0
    MOVE.W  D7,D0                      * Copy the WORD data to D0
    LSR.W   #8,D0                           * Shift right 8 bits
    ANDI.W  #$0F,D0                         * Get bits 8-11
    
    CMP.B   #0,D0                           * BRA
    BEQ     is_BRA
    
    CMP.B   #5,D0                           * BCS
    BEQ     is_BCS

    CMP.B   #8,D0                           * BVC
    BEQ     is_BVC    

    CMP.B   #12,D0                          * BGE
    BEQ     is_BGE

    CMP.B   #13,D0                          * BLT
    BEQ     is_BLT
    
    BRA     data_error                      * Other not required instructions
    
is_BRA
    MOVE.B  #'B',(A1)+
    MOVE.B  #'R',(A1)+
    MOVE.B  #'A',(A1)+
    MOVE.B  #' ',(A1)+                      * Add a space
    JSR     displacement_check
    MOVE.B  #'$',(A1)+     
    JSR     hex_to_char                    * get the displacement        
    BRA     Print

is_BCS
    MOVE.B  #'B',(A1)+
    MOVE.B  #'C',(A1)+
    MOVE.B  #'S',(A1)+
    MOVE.B  #' ',(A1)+                      * Add a space
    JSR     displacement_check
    MOVE.B  #'$',(A1)+     
    JSR     hex_to_char                    * get the displacement  
    BRA     Print

is_BVC
    MOVE.B  #'B',(A1)+
    MOVE.B  #'V',(A1)+
    MOVE.B  #'C',(A1)+
    MOVE.B  #' ',(A1)+                      * Add a space
    JSR     displacement_check
    MOVE.B  #'$',(A1)+     
    JSR     hex_to_char                    * get the displacement  
    BRA     Print

is_BGE
    MOVE.B  #'B',(A1)+
    MOVE.B  #'G',(A1)+
    MOVE.B  #'E',(A1)+
    MOVE.B  #' ',(A1)+                      * Add a space
    JSR     displacement_check
    MOVE.B  #'$',(A1)+     
    JSR     hex_to_char                    * get the displacement  
    BRA     Print

is_BLT
    MOVE.B  #'B',(A1)+
    MOVE.B  #'L',(A1)+
    MOVE.B  #'T',(A1)+
    MOVE.B  #' ',(A1)+                      * Add a space
    JSR     displacement_check
    MOVE.B  #'$',(A1)+    
    JSR     hex_to_char                    * get the displacement  
    BRA     Print    


*////////////////////////////////////////////////////////////////////////////////////////
*displacement_check: check the 8 bits displacement and return value in D1
*D1: holds 1, 2, 4 for byte, word, long word displacement respectively
*////////////////////////////////////////////////////////////////////////////////////////
displacement_check
    CLR.L   D0
    CLR.L   D1
    MOVE.W  D7,D0                      * Copy the WORD data to D0    
    ANDI.W  #$FF,D0                         * Get 8 bits displacement
    
    CMP.B   #$00,D0                         * 16-bits displacement
    BEQ     displacement_word
    
    CMP.B   #$FF,D0                         * 32-bits displacement
    BEQ     displacement_long
    
    BRA     displacement_byte               * no need additional data for displacement  
        
displacement_byte
    MOVE.L  A6,D3                           * Get PC D3
    ADD.B   D0,D3                           * Get target address
    CLR.L   D0    
    MOVE.L  D3,D0                           * Copy to D0                              

    CLR.L   D1
    MOVE.B  #4,D1                           * byte size for address is 4
    RTS              
    
displacement_word
    MOVE.L  A6,D3                           * Get PC D3
    MOVE.W  (A6)+,D0                        * Get displacement word from memory  
    ADD.W   D0,D3                           * Get target address
    CLR.L   D0
    MOVE.L  D3,D0                           * Copy to D0                              

    CLR.L   D1
    MOVE.B  #4,D1                           * byte size for address is 4  
    RTS
    
displacement_long
    MOVE.L  A6,D3                           * Get PC D3
    MOVE.L  (A6)+,D0                        * Get displacement long word from memory
    ADD.L   D0,D3                           * Get target address
    CLR.L   D0    
    MOVE.L  D3,D0                           * Copy to D0                              

    CLR.L   D1
    MOVE.B  #4,D1                           * byte size for address is 4    
    RTS 
        
      

*////////////////////////////////////////////////////////////////////////////////////////
*code1000: OR/DIV/SBCD
* OR - DIVS
*////////////////////////////////////////////////////////////////////////////////////////     
DECODE_8
    CMP.B   #7,D4                           * DIVS
    BEQ     is_DIVS
    
    CMP.B   #3,D4                           * DIVU
    BEQ     data_error                      * Other not required instructions    
    
    CLR.L   D0
    CLR.L   D1
    MOVE.W  D7,D0                      * Copy the WORD data to D0         
    LSR.W   #4,D0                           * Shift right by 4 bits
    ANDI.W  #$1F,D0                         * Get bits 4-8
    CMP.B   #16,D0                          * SBCD
    BEQ     data_error                      * Other not required instructions
    
    BRA     is_OR                           * instruction should be OR    

is_DIVS
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error
    MOVE.B  #'D',(A1)+
    MOVE.B  #'I',(A1)+
    MOVE.B  #'V',(A1)+
    MOVE.B  #'S',(A1)+
    MOVE.B  #'.',(A1)+
    MOVE.B  #'W',(A1)+    
    MOVE.B  #' ',(A1)+                      * Add a space
    MOVE.B  #2,D0                           * Byte size is 2    
    JSR     GETSOURCE                          * Get source EA
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer
    BRA     Print         

is_OR
    MOVE.B  #'O',(A1)+
    MOVE.B  #'R',(A1)+
    CLR.L   D0
    CLR.L   D1
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bits 6-7
    JSR     get_size                        * Get the size
    MOVE.B  #' ',(A1)+                      * Add a space
    MOVE.B  D4,D1                           * Copy bits 6-8 to D1
    ANDI.B  #$04,D1                         * Get bits 8
    CMP.B   #0,D1                           * if 0
    BEQ     OR_ea_to_Dn

    BRA     OR_Dn_to_ea    
        
OR_ea_to_Dn
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error
    JSR     GETSOURCE                          * get source EA
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer        
    BRA     Print

OR_Dn_to_ea
    CMP.B   #0,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error    
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer           
    MOVE.B  #',',(A1)+
    JSR     GETSOURCE                          * get source EA
    BRA     Print
    
*////////////////////////////////////////////////////////////////////////////////////////
*code1001: SUB/SUBX
* SUB
*////////////////////////////////////////////////////////////////////////////////////////
DECODE_9
    CLR.L   D0
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bits 6-7
    CMP.B   #3,D0                           * SUBA
    BEQ     data_error                      * Other not required instructions

    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$04,D0                         * Get bits 8
    CMP.B   #1,D0                           * May be SUBX
    BEQ     check_SUBX

    BRA     is_SUB     
     
check_SUBX
    MOVE.B  D3,D0                           * Copy bits 3-5 to D0
    LSR.B   #1,D0                           * Shift right 1 bit
    ANDI.B  #3,D0                           * Get bits 4-5
    CMP.B   0,D0                            * SUBX
    BEQ     data_error                      * Other not required instructions

    BRA     is_SUB                          * Instruction should be SUB

is_SUB
    MOVE.B  #'S',(A1)+
    MOVE.B  #'U',(A1)+
    MOVE.B  #'B',(A1)+    
    CLR.L   D0
    CLR.L   D1
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bits 6-7
    JSR     get_size                        * Get the size
    MOVE.B  #' ',(A1)+                      * Add a space
    MOVE.B  D4,D1                           * Copy bits 6-8 to D1
    ANDI.B  #$04,D1                         * Get bits 8
    CMP.B   #0,D1                           * if 0
    BEQ     SUB_ea_to_Dn

    BRA     SUB_Dn_to_ea                              

SUB_ea_to_Dn
    JSR     GETSOURCE                          * get source EA
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer        
    BRA     Print

SUB_Dn_to_ea
    CMP.B   #0,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer           
    MOVE.B  #',',(A1)+
    JSR     GETSOURCE                          * get source EA
    BRA     Print


*////////////////////////////////////////////////////////////////////////////////////////
*code1011: CMP/EOR
* CMP - EOR
*////////////////////////////////////////////////////////////////////////////////////////
DECODE_B
    CLR.L   D0
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    LSR.B   #2,D0                           * Get bit 8
    CMPI.B  #0,D0                           * May be CMP / CMPA
    BEQ     CMPA_check
    
    CMP.B   #1,D3                           * CMPM
    BEQ     data_error                      * Other not required instructions
    
    BRA     is_EOR                          * instruction should be EOR
    
CMPA_check
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bits 6-7
    CMPI.B  #3,D0                           * CMPA
    BEQ     data_error                      * Other not required instructions
    BRA     is_CMP                          * instruction should be CMP

is_CMP
    MOVE.B  #'C',(A1)+
    MOVE.B  #'M',(A1)+
    MOVE.B  #'P',(A1)+    
    CLR.L   D0
    CLR.L   D1
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bits 6-7
    JSR     get_size                        * Get the size
    MOVE.B  #' ',(A1)+                      * Add a space
    JSR     GETSOURCE                          * get source EA
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer        
    BRA     Print    
          
is_EOR
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error
    MOVE.B  #'E',(A1)+
    MOVE.B  #'O',(A1)+
    MOVE.B  #'R',(A1)+    
    CLR.L   D0
    CLR.L   D1
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bits 6-7
    JSR     get_size                        * Get the size
    MOVE.B  #' ',(A1)+                      * Add a space
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer           
    MOVE.B  #',',(A1)+
    JSR     GETDESTINATION                          * get destination EA
    BRA     Print    


*////////////////////////////////////////////////////////////////////////////////////////
*code1100: AND/MUL/ABCD/EXG
* MULS
*////////////////////////////////////////////////////////////////////////////////////////
DECODE_C
    CMP.B   #7,D4                           * MULS
    BEQ     is_MULS
    
    BRA     data_error                      * Other not required instructions
    
is_MULS
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error
    MOVE.B  #'M',(A1)+
    MOVE.B  #'U',(A1)+
    MOVE.B  #'L',(A1)+
    MOVE.B  #'S',(A1)+
    MOVE.B  #'.',(A1)+
    MOVE.B  #'W',(A1)+    
    MOVE.B  #' ',(A1)+                      * Add a space
    MOVE.B  #2,D0                           * Byte size is 2
    JSR     GETSOURCE                          * Get source EA
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer
    BRA     Print         


*////////////////////////////////////////////////////////////////////////////////////////
*code1101: ADD/ADDA/ADDX
* ADD - ADDA
*////////////////////////////////////////////////////////////////////////////////////////
DECODE_D
    CLR.L   D0
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bits 6-7
    CMPI.B  #3,D0                           * ADDA
    BEQ     is_ADDA
    
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    LSR.B   #2,D0                           * Get bit 8
    CMP.B   #1,D0                           * May be ADDX
    BEQ     ADDX_check
    BRA     is_ADD                          * Instruction should be ADD
    
ADDX_check
    MOVE.B  D3,D0                           * Copy bits 3-5 to D0
    LSR.B   #1,D0                           * Get bits 4-5
    CMP.B   #0,D0                           * ADDX
    BEQ     data_error                      * Other not required instructions
    BRA     is_ADD                          * Instruction should be ADD
    
is_ADDA
    MOVE.B  #'A',(A1)+
    MOVE.B  #'D',(A1)+
    MOVE.B  #'D',(A1)+
    MOVE.B  #'A',(A1)+
    CMP.B   #3,D4                           * Word operation
    BEQ     ADDA_Word
    BRA     ADDA_Long                       * Long operation

ADDA_cont   
    MOVE.B  #' ',(A1)+                      * Add a space
    JSR     GETSOURCE                          * Get source EA
    MOVE.B  #',',(A1)+
    MOVE.B  #'A',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer
    BRA     Print    

ADDA_Word
    MOVE.B  #'.',(A1)+
    MOVE.B  #'W',(A1)+
    MOVE.B  #2,D0                           * Byte size is 2
    BRA     ADDA_cont

ADDA_Long
    MOVE.B  #'.',(A1)+
    MOVE.B  #'L',(A1)+
    MOVE.B  #4,D0                           * Byte size is 4
    BRA     ADDA_cont         

is_ADD    
    MOVE.B  #'A',(A1)+
    MOVE.B  #'D',(A1)+
    MOVE.B  #'D',(A1)+    
    CLR.L   D0
    CLR.L   D1
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bits 6-7
    JSR     get_size                        * Get the size
    MOVE.B  #' ',(A1)+                      * Add a space
    MOVE.B  D4,D1                           * Copy bits 6-8 to D1
    ANDI.B  #$04,D1                         * Get bits 8
    CMP.B   #0,D1                           * if 0
    BEQ     ADD_ea_to_Dn

    BRA     ADD_Dn_to_ea                              

ADD_ea_to_Dn
    JSR     GETSOURCE                          * get source EA
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer        
    BRA     Print

ADD_Dn_to_ea
    CMP.B   #0,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error    
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer           
    MOVE.B  #',',(A1)+
    JSR     GETSOURCE                          * get source EA
    BRA     Print


*////////////////////////////////////////////////////////////////////////////////////////
*code1110: Shift/Rotate
* LSR - LSL - ASR - ASL - ROR - ROL
*////////////////////////////////////////////////////////////////////////////////////////
DECODE_E
    CLR.L   D0
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bits 6-7
    CMP.B   #3,D0                           * Memory shift
    BEQ     memory_shift
    
    MOVE.B  D3,D0                           * Copy bits 3-5 to D0
    ANDI.B  #$03,D0                         * Get bits 3-4
    
    CMP.B   #0,D0                           * ASd register
    BEQ     ASd_check_register_shift
    
    CMP.B   #1,D0                           * LSd register
    BEQ     LSd_check_register_shift

    CMP.B   #3,D0                           * ROd register
    BEQ     ROd_check_register_shift 

    BRA     data_error                      * Other not required instructions   

memory_shift
    CMP.B   #0,D5                           * ASd
    BEQ     ASd_check_memory_shift
    
    CMP.B   #1,D5                           * LSd
    BEQ     LSd_check_memory_shift

    CMP.B   #3,D5                           * ROd
    BEQ     ROd_check_memory_shift 

    BRA     data_error                      * Other not required instructions
    
ASd_check_memory_shift
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    LSR.B   #2,D0                           * Get bit 8
    CMP.B   #0,D0                           * ASR
    BEQ     ASR_memory_shift
    BRA     ASL_memory_shift

ASR_memory_shift
    CMP.B   #0,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error    
    MOVE.B  #'A',(A1)+
    MOVE.B  #'S',(A1)+
    MOVE.B  #'R',(A1)+
    MOVE.B  #'.',(A1)+
    MOVE.B  #'W',(A1)+
    MOVE.B  #' ',(A1)+                      * Add a space
    JSR     GETSOURCE                          * Get EA source
    BRA     Print            

ASL_memory_shift
    CMP.B   #0,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error  
    MOVE.B  #'A',(A1)+
    MOVE.B  #'S',(A1)+
    MOVE.B  #'L',(A1)+
    MOVE.B  #'.',(A1)+
    MOVE.B  #'W',(A1)+
    MOVE.B  #' ',(A1)+                      * Add a space
    JSR     GETSOURCE                          * Get EA source
    BRA     Print        

LSd_check_memory_shift
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    LSR.B   #2,D0                           * Get bit 8
    CMP.B   #0,D0                           * LSR
    BEQ     LSR_memory_shift
    BRA     LSL_memory_shift

LSR_memory_shift
    CMP.B   #0,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error  
    MOVE.B  #'L',(A1)+
    MOVE.B  #'S',(A1)+
    MOVE.B  #'R',(A1)+
    MOVE.B  #'.',(A1)+
    MOVE.B  #'W',(A1)+
    MOVE.B  #' ',(A1)+                      * Add a space
    JSR     GETSOURCE                          * Get EA source
    BRA     Print            

LSL_memory_shift
    CMP.B   #0,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error  
    MOVE.B  #'L',(A1)+
    MOVE.B  #'S',(A1)+
    MOVE.B  #'L',(A1)+
    MOVE.B  #'.',(A1)+
    MOVE.B  #'W',(A1)+
    MOVE.B  #' ',(A1)+                      * Add a space
    JSR     GETSOURCE                          * Get EA source
    BRA     Print

ROd_check_memory_shift
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    LSR.B   #2,D0                           * Get bit 8
    CMP.B   #0,D0                           * ROR
    BEQ     ROR_memory_shift
    BRA     ROL_memory_shift

ROR_memory_shift
    CMP.B   #0,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error  
    MOVE.B  #'R',(A1)+
    MOVE.B  #'O',(A1)+
    MOVE.B  #'R',(A1)+
    MOVE.B  #'.',(A1)+
    MOVE.B  #'W',(A1)+
    MOVE.B  #' ',(A1)+                      * Add a space
    JSR     GETSOURCE                          * Get EA source
    BRA     Print            

ROL_memory_shift
    CMP.B   #0,D3                           * Check invalid EA mode
    BEQ     data_error
    CMP.B   #1,D3                           * Check invalid EA mode
    BEQ     data_error  
    MOVE.B  #'R',(A1)+
    MOVE.B  #'O',(A1)+
    MOVE.B  #'L',(A1)+
    MOVE.B  #'.',(A1)+
    MOVE.B  #'W',(A1)+
    MOVE.B  #' ',(A1)+                      * Add a space
    JSR     GETSOURCE                          * Get EA source
    BRA     Print  

ASd_check_register_shift
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    LSR.B   #2,D0                           * Get bit 8
    CMP.B   #0,D0                           * ASR
    BEQ     ASR_register_shift
    BRA     ASL_register_shift
    
ASR_register_shift
    MOVE.B  #'A',(A1)+
    MOVE.B  #'S',(A1)+
    MOVE.B  #'R',(A1)+
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bits 6-7
    JSR     get_size                        * Get the size
    MOVE.B  #' ',(A1)+                      * Add a space
    MOVE.B  D3,D0                           * Copy bits 3-5 to D0
    LSR.B   #2,D0                           * Shift right 2 bits
    CMP.B   #0,D0                           * Immediate
    BNE     ASR_register_shift_register
    BRA     ASR_register_shift_immediate

ASR_register_shift_register
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer           
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D2                         *Convert REG# to ASCII
    MOVE.B  D2,(A1)+                        *Add to buffer     
    BRA     Print        

ASR_register_shift_immediate
    MOVE.B  #'#',(A1)+
    MOVE.B  #'$',(A1)+
    JSR     shift_immediate_data
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D2                         *Convert REG# to ASCII
    MOVE.B  D2,(A1)+                        *Add to buffer     
    BRA     Print    

ASL_register_shift
    MOVE.B  #'A',(A1)+
    MOVE.B  #'S',(A1)+
    MOVE.B  #'L',(A1)+
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bits 6-7
    JSR     get_size                        * Get the size
    MOVE.B  #' ',(A1)+                      * Add a space
    MOVE.B  D3,D0                           * Copy bits 3-5 to D0
    LSR.B   #2,D0                           * Shift right 2 bits
    CMP.B   #0,D0                           * Immediate
    BNE     ASL_register_shift_register
    BRA     ASL_register_shift_immediate

ASL_register_shift_register
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer           
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D2                         *Convert REG# to ASCII
    MOVE.B  D2,(A1)+                        *Add to buffer     
    BRA     Print        

ASL_register_shift_immediate
    MOVE.B  #'#',(A1)+
    MOVE.B  #'$',(A1)+
    JSR     shift_immediate_data
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D2                         *Convert REG# to ASCII
    MOVE.B  D2,(A1)+                        *Add to buffer     
    BRA     Print    

LSd_check_register_shift
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    LSR.B   #2,D0                           * Get bit 8
    CMP.B   #0,D0                           * LSR
    BEQ     LSR_register_shift
    BRA     LSL_register_shift
    
LSR_register_shift
    MOVE.B  #'L',(A1)+
    MOVE.B  #'S',(A1)+
    MOVE.B  #'R',(A1)+
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bits 6-7
    JSR     get_size                        * Get the size
    MOVE.B  #' ',(A1)+                      * Add a space
    MOVE.B  D3,D0                           * Copy bits 3-5 to D0
    LSR.B   #2,D0                           * Shift right 2 bits
    CMP.B   #0,D0                           * Immediate
    BNE     LSR_register_shift_register
    BRA     LSR_register_shift_immediate

LSR_register_shift_register
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer           
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D2                         *Convert REG# to ASCII
    MOVE.B  D2,(A1)+                        *Add to buffer     
    BRA     Print        

LSR_register_shift_immediate
    MOVE.B  #'#',(A1)+
    MOVE.B  #'$',(A1)+
    JSR     shift_immediate_data
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D2                         *Convert REG# to ASCII
    MOVE.B  D2,(A1)+                        *Add to buffer     
    BRA     Print    

LSL_register_shift
    MOVE.B  #'L',(A1)+
    MOVE.B  #'S',(A1)+
    MOVE.B  #'L',(A1)+
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bits 6-7
    JSR     get_size                        * Get the size
    MOVE.B  #' ',(A1)+                      * Add a space
    MOVE.B  D3,D0                           * Copy bits 3-5 to D0
    LSR.B   #2,D0                           * Shift right 2 bits
    CMP.B   #0,D0                           * Immediate
    BNE     LSL_register_shift_register
    BRA     LSL_register_shift_immediate

LSL_register_shift_register
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer           
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D2                         *Convert REG# to ASCII
    MOVE.B  D2,(A1)+                        *Add to buffer     
    BRA     Print        

LSL_register_shift_immediate
    MOVE.B  #'#',(A1)+
    MOVE.B  #'$',(A1)+
    JSR     shift_immediate_data
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D2                         *Convert REG# to ASCII
    MOVE.B  D2,(A1)+                        *Add to buffer     
    BRA     Print    

ROd_check_register_shift
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    LSR.B   #2,D0                           * Get bit 8
    CMP.B   #0,D0                           * ROR
    BEQ     ROR_register_shift
    BRA     ROL_register_shift
    
ROR_register_shift
    MOVE.B  #'R',(A1)+
    MOVE.B  #'O',(A1)+
    MOVE.B  #'R',(A1)+
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bits 6-7
    JSR     get_size                        * Get the size
    MOVE.B  #' ',(A1)+                      * Add a space
    MOVE.B  D3,D0                           * Copy bits 3-5 to D0
    LSR.B   #2,D0                           * Shift right 2 bits
    CMP.B   #0,D0                           * Immediate
    BNE     ROR_register_shift_register
    BRA     ROR_register_shift_immediate

ROR_register_shift_register
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer           
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D2                         *Convert REG# to ASCII
    MOVE.B  D2,(A1)+                        *Add to buffer     
    BRA     Print        

ROR_register_shift_immediate
    MOVE.B  #'#',(A1)+
    MOVE.B  #'$',(A1)+
    JSR     shift_immediate_data
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D2                         *Convert REG# to ASCII
    MOVE.B  D2,(A1)+                        *Add to buffer     
    BRA     Print    

ROL_register_shift
    MOVE.B  #'R',(A1)+
    MOVE.B  #'O',(A1)+
    MOVE.B  #'L',(A1)+
    MOVE.B  D4,D0                           * Copy bits 6-8 to D0
    ANDI.B  #$03,D0                         * Get bits 6-7
    JSR     get_size                        * Get the size
    MOVE.B  #' ',(A1)+                      * Add a space
    MOVE.B  D3,D0                           * Copy bits 3-5 to D0
    LSR.B   #2,D0                           * Shift right 2 bits
    CMP.B   #0,D0                           * Immediate
    BNE     ROL_register_shift_register
    BRA     ROL_register_shift_immediate

ROL_register_shift_register
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D5                         *Convert REG# to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer           
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D2                         *Convert REG# to ASCII
    MOVE.B  D2,(A1)+                        *Add to buffer     
    BRA     Print        

ROL_register_shift_immediate
    MOVE.B  #'#',(A1)+
    MOVE.B  #'$',(A1)+
    JSR     shift_immediate_data
    MOVE.B  #',',(A1)+
    MOVE.B  #'D',(A1)+                  
    ADD     #$30,D2                         *Convert REG# to ASCII
    MOVE.B  D2,(A1)+                        *Add to buffer     
    BRA     Print    
    
shift_immediate_data
    CMPI    #0,D5                           * Compare data to 0
    BEQ     shift_immediate_zero

shift_immediate_cont    
    ADD     #$30,D5                         *Convert hex number to ASCII
    MOVE.B  D5,(A1)+                        *Add to buffer
    RTS   
    
shift_immediate_zero
    ADDI    #8,D5                           * 0 represents 8
    BRA     shift_immediate_cont
    


*////////////////////////////////////////////////////////////////////////////////////////
*data_error: D3 WORD couldn't be decoded, print the WORD data
*//////////////////////////////////////////////////////////////////////////////////////// 
data_error
    MOVE.L  #buffer,A1                      * Set A1 to point to the print buffer
    MOVE.B  #'D',(A1)+
    MOVE.B  #'A',(A1)+
    MOVE.B  #'T',(A1)+
    MOVE.B  #'A',(A1)+
    MOVE.B  #' ',(A1)+                      * Add a space
    CLR.L   D0
    MOVE.W  A4,D0                            * Copy the WORD data to D0
    CLR.L   D1
    MOVE.B  #2,D1                           * Byte size is 2               
    JSR     hex_to_char
    BRA     Print             
    
get_size
    CMP.B   #0,D0
    BEQ     byte_size
    CMP.B   #1,D0
    BEQ     word_size
    CMP.B   #2,D0
    BEQ     long_size
    
byte_size
    MOVE.B  #'.',(A1)+
    MOVE.B  #'B',(A1)+
    MOVE.B  #1,D0                           * Put 1 in D0 for 1 byte
    RTS

word_size
    MOVE.B  #'.',(A1)+
    MOVE.B  #'W',(A1)+
    MOVE.B  #2,D0                           * Put 2 in D0 for 2 bytes
    RTS    
    
long_size
    MOVE.B  #'.',(A1)+
    MOVE.B  #'L',(A1)+
    MOVE.B  #4,D0                           * Put 4 in D0 for 1 bytes     
    RTS     

        

        
*////////////////////////////////////////////////////////////////////////////////////////
* EA: This is the section for decoding EA
*////////////////////////////////////////////////////////////////////////////////////////

GETSOURCE:
    JSR PRINT_SOURCE_MODE
    JSR PRINT_SOURCE_REGISTER
    RTS
    
GETDESTINATION:
    JSR PRINT_DESTINATION_MODE
    JSR PRINT_DESTINATION_REGISTER
    RTS

PRINT_SOURCE_MODE:
    CMP.B #MDRD,D2  
    BEQ PRINT_EA_DRD                ; Prints out D
    CMP.B #MARD,D2
    BEQ PRINT_EA_ARD                ; Prints out A
    CMP.B #MARI,D2
    BEQ PRINT_EA_ARI                ; Prints out (A                
    CMP.B #MARIP,D2
    BEQ PRINT_EA_ARIP               ; Prints out (A
    CMP.B #MARIM,D2
    BEQ PRINT_EA_ARIM               ; Prints out -(A
    CMP.B #MAWA,D2
    RTS
    
    ; create function for last three
    
PRINT_SOURCE_REGISTER:
    CMP.B   #MDRD,D2                ; If the mode is a Dn then we just print the value in the register
    BEQ     PRINT_EA_REG_VALUE
    CMP.B   #MARD,D2                ; If the mode is a An then we just print the value in the register
    BEQ     PRINT_EA_REG_VALUE
    CMP.B   #MARI,D2                ; If the mode is a (An) we need to print the reg value and )
    BEQ     PRINT_EA_ARI_REG
    CMP.B   #MARIP,D2               ; If the mode is a (An)+ we need to print the reg value and )+
    BEQ     PRINT_EA_ARIP_REG           
    CMP.B   #MARIM,D2               ; If the mode is a -(SP) we need to print the reg value and )
    BEQ     PRINT_EA_ARI_REG
    CMP.B   #RAWA,D2                ; The reg is a .w so we need to print the address and ).W
    BEQ     PRINT_EA_AWA_REG
    CMP.B   #RALA,D2                ; The reg is a .l so we need to print the address and ).L
    BEQ     PRINT_EA_ALA_REG
    CMP.B   #RID,D2                ; The reg can be several different lengths so go to our operation and compare address mode, print address and >
    BEQ     PRINT_EA_ID_REG
    
PRINT_DESTINATION_MODE:
    CMP.B #MDRD,D4  
    BEQ PRINT_EA_DRD                ; Prints out D
    CMP.B #MARD,D4
    BEQ PRINT_EA_ARD                ; Prints out A
    CMP.B #MARI,D4
    BEQ PRINT_EA_ARI                ; Prints out (A                
    CMP.B #MARIP,D4
    BEQ PRINT_EA_ARIP               ; Prints out (A
    CMP.B #MARIM,D4
    BEQ PRINT_EA_ARIM               ; Prints out -(A
    CMP.B #MAWA,D4
    RTS
    
    ; create function for last three
    
PRINT_DESTINATION_REGISTER:
    CMP.B   #MDRD,D5                ; If the mode is a Dn then we just print the value in the register
    BEQ     PRINT_EA_REG_VALUE
    CMP.B   #MARD,D5                ; If the mode is a An then we just print the value in the register
    BEQ     PRINT_EA_REG_VALUE
    CMP.B   #MARI,D5                ; If the mode is a (An) we need to print the reg value and )
    BEQ     PRINT_EA_ARI_REG
    CMP.B   #MARIP,D5               ; If the mode is a (An)+ we need to print the reg value and )+
    BEQ     PRINT_EA_ARIP_REG           
    CMP.B   #MARIM,D5               ; If the mode is a -(SP) we need to print the reg value and )
    BEQ     PRINT_EA_ARI_REG
    CMP.B   #RAWA,D5                ; The reg is a .w so we need to print the address and ).W
    BEQ     PRINT_EA_AWA_REG
    CMP.B   #RALA,D5                ; The reg is a .l so we need to print the address and ).L
    BEQ     PRINT_EA_ALA_REG
    CMP.B   #RID,D5                ; The reg can be several different lengths so go to our operation and compare address mode, print address and >
    BEQ     PRINT_EA_ID_REG

    

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
    RTS 

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
    RTS 


PRINT_EA_ALA_REG:
    MOVE.L  (A5)+,D1
    MOVE.B  #15,D0
    MOVE.B  #16,D2
    TRAP    #15 
    LEA     ALA_END_TEXT,A1
    MOVE.B  #14,D0
    TRAP    #15
    RTS 
        
PRINT_EA_ID_REG:
    CMP.B   #0,D4
    BEQ     PRINT_EA_ID_REG_W
    CMP.B   #2,D4
    BEQ     PRINT_EA_ID_REG_W
    CMP.B   #3,D4
    BEQ     PRINT_EA_ID_REG_L

PRINT_EA_ID_REG_B:   
    MOVE.W  (A5)+,D1
    MOVE.B  #15,D0
    MOVE.B  #16,D2
    TRAP    #15
    LEA     ID_END_TEXT,A1
    MOVE.B  #14,D0
    TRAP    #15
    RTS 
    
PRINT_EA_ID_REG_W:   
    MOVE.W  (A5)+,D1
    MOVE.B  #15,D0
    MOVE.B  #16,D2
    TRAP    #15
    LEA     ID_END_TEXT,A1
    MOVE.B  #14,D0
    TRAP    #15
    RTS 
    
PRINT_EA_ID_REG_L:
    MOVE.L  (A5)+,D1
    MOVE.B  #15,D0
    MOVE.B  #16,D2
    TRAP    #15
    LEA     ID_END_TEXT,A1
    MOVE.B  #14,D0
    TRAP    #15
    RTS 
    
PRINT_EA_DRD
    LEA DRD_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    RTS 
    
PRINT_EA_ARD
    LEA ARD_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    RTS 
    
PRINT_EA_ARI
    LEA ARI_TEXT,A1
    MOVE.B  #14,D0
    TRAP #15
    RTS 
    
PRINT_EA_ARIP
    LEA ARIP_TEXT,A1
    MOVE.B  #14,D0
    TRAP #15
    RTS 
    
PRINT_EA_ARIM
    LEA ARIM_TEXT,A1
    MOVE.B  #14,D0
    TRAP #15
    RTS 

    
PRINT_EA_ID
    LEA ID_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    RTS 
    
PRINT_EA_ALA
    LEA ALA_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    RTS 
    
PRINT_EA_AWA
    LEA AWA_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    RTS 
    
*immediate_data: get the immediate data from memory and put in the print buffer
*A1: pointer to the print buffer
*D0: hold the size
*////////////////////////////////////////////////////////////////////////////////////////
GET_EA_ID    
    MOVE.B  #'#',(A1)+
    CMP.B   #2,D0                           *Is the size WORD
    BEQ     PRINT_EA_ID_REG_W    
    CMP.B   #4,D0                           *Is the size LONG WORD
    BEQ     PRINT_EA_ID_REG_L
    CMP.B   #1,D0                           *Is the size BYTE
    BEQ     PRINT_EA_ID_REG_B

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

MOVEM_post      DC.B	'A7','A6','A5','A4','A3','A2','A1','A0','D7','D6','D5','D4','D3','D2','D1','D0',0
MOVEM_pre       DC.B    'D0','D1','D2','D3','D4','D5','D6','D7','A0','A1','A2','A3','A4','A5','A6','A7',0

 
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

    


    END    START        ; last line of source
   




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
