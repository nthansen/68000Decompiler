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
BEGIN   EQU $00003000
END     EQU $00FFFFFE   
    
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
        MOVE.B  #14,D0                    * Load task number 14 for printing
        LEA     buffer,A1                 * Load the buffer into A1 
        TRAP    #15                       * Print the buffer              
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
        MOVE.B  #' ',(A1)+
        MOVE.B  #' ',(A1)+    
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
        
SETUP_VALUES:
    MOVE.W      D3,D1                   * For first four values
    LSR.L       #8,D1                   * Shift 12 bits to the right 
    LSR.L       #4,D1
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
    
DECODE_0      *ORI: DONE, CMPI:DONE , BCLEAR (DYNAMIC:DONE and STATIC:DONE)
    MOVE.L  D3,D1
    
    ; FIX ORI
    LSL     #4,D1       Shift to be able to find out if it's ORI or CMPI
    LSR     #8,D1
    LSR     #4,D1

    CMP.B   #$0,D1
    BEQ     DECODE_ORI
    
    CMP.B   #$C,D1
    BEQ     DECODE_CMPI
    
    MOVE.L  D3,D1
    LSR     #6,D1         Shift to be able to find out if it's BCLR STATIC
    CMP.B   #%0000100010,D1
    BEQ     DECODE_STATIC_BCLR
    
    JSR GETDESTINATIONMODE
    CMP.B   #6,D6       
    BEQ     DECODE_DYNAMIC_BCLR
    
    BRA     data_error
    
DECODE_1    *MOVE.B; DONE

    MOVE.L  #buffer,A1
    MOVE.B #'M',(A1)+
    MOVE.B #'O',(A1)+
    MOVE.B #'V',(A1)+
    MOVE.B #'E',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'B',(A1)+
    MOVE.B #' ',(A1)+

    MOVE.B #0,D4                ; Set to zero so if it's immediate code it knows to grab a byte
    JSR GETSOURCE
    MOVE.B  #',',(A1)+
    JSR GETDESTINATION
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS  
    

DECODE_2    *MOVE.L: DONE, MOVEA.L:DONE COULD BE DONE MORE EFFICIENTLY THOUGH

    JSR     GETDESTINATIONMODE
    CMP.B   #$1,D6              
    BEQ     DECODE_MOVEA_L           ; If the mode equals 001 then we know it's MOVEA otherwise its just move
    BRA     DECODE_MOVE_L
 

DECODE_3    *MOVE.W: DONE, MOVEA.W: DONE COULD BE DONE MORE EFFICIENTLY THOUGH
 
    JSR     GETDESTINATIONMODE
    CMP.B   #$1,D6              
    BEQ     DECODE_MOVEA_W           ; If the mode equals 001 then we know it's MOVEA otherwise its just move
    BRA     DECODE_MOVE_W

DECODE_4            *NOP: DONE, RTS:DONE, NEG:DONE, JSR:DONE, LEA:DONE, MOVEM
    CMP.W   #$4E71,D3           * NOP
    BEQ     DECODE_NOP

    CMP.W   #$4E75,D3           * RTS
    BEQ     DECODE_RTS
        
        
    MOVE.L  D3,D1               * NEG
    LSR.L   #8,D1               * Shift so we can check with NED

    CMP.B   #%01000100,D1       * For NEG
    BEQ     DECODE_NEG
    
    MOVE.L  D3,D1               * JSR check
    LSR.L   #6,D1               * Shift

    CMP.W   #%0100111010,D1
    BEQ     DECODE_JSR
    
    JSR CHECK_LEA_OR_MOVEM      * Should make a check function to check for LEA and MOVEM 
    RTS
   
DECODE_5    * SUBQ: DONE
    
    JSR     GETDESTINATIONMODE
    
    CMP.B   #$4,D6
    BEQ     DECODE_SUBQ_B
    CMP.B   #$5,D6
    BEQ     DECODE_SUBQ_W
    CMP.B   #$6,D6
    BEQ     DECODE_SUBQ_L
    
    BRA     data_error
        
DECODE_6    * Bcc: DONE, BRA: DONE
	
	MOVE.W  D3,D1
	LSR     #8,D1
	
	CMP.B   #$60,D1
	BEQ     DECODE_BRA
	CMP.B   #$62,D1
	BEQ     DECODE_BCC_HI
	CMP.B   #$63,D1
	BEQ     DECODE_BCC_LS
	CMP.B   #$64,D1
	BEQ     DECODE_BCC_CCHI
	CMP.B   #$65,D1
	BEQ     DECODE_BCC_CCLO
	CMP.B   #$66,D1
	BEQ     DECODE_BCC_NE
	CMP.B   #$67,D1
	BEQ     DECODE_BCC_EQ
    CMP.B   #$68,D1
    BEQ     DECODE_BCC_VC
    CMP.B   #$69,D1
    BEQ     DECODE_BCC_VS
    CMP.B   #$6A,D1
    BEQ    DECODE_BCC_PL
    CMP.B   #$6B,D1
    BEQ     DECODE_BCC_MI
    CMP.B   #$6C,D1
    BEQ     DECODE_BCC_GE
    CMP.B   #$6D,D1
    BEQ     DECODE_BCC_LT
    CMP.B   #$6E,D1
    BEQ     DECODE_BCC_GT
    CMP.B   #$6F,D1
    BEQ     DECODE_BCC_LE
	
    BRA     data_error
        
          
DECODE_8    * DIVU: DONE, DIVS: DONE, : DONE
    JSR     GETDESTINATIONMODE
    CMP.B   #0,D6
    BEQ     DECODE_OR_EA_DN_B
    CMP.B   #1,D6
    BEQ     DECODE_OR_EA_DN_W
    CMP.B   #2,D6
    BEQ     DECODE_OR_EA_DN_L
    CMP.B   #3,D6
    BEQ     DECODE_DIVU
    CMP.B   #4,D6
    BEQ     DECODE_OR_DN_EA_B
    CMP.B   #5,D6
    BEQ     DECODE_OR_DN_EA_W
    CMP.B   #6,D6
    BEQ     DECODE_OR_DN_EA_L
    CMP.B   #7,D6
    BEQ     DECODE_DIVS
    
    BRA     data_error
    
DECODE_9    * SUB: DONE
    
    JSR     GETDESTINATIONMODE
    CMP.B   #0,D6
    BEQ     DECODE_SUB_EA_DN_B
    CMP.B   #1,D6
    BEQ     DECODE_SUB_EA_DN_W
    CMP.B   #2,D6
    BEQ     DECODE_SUB_EA_DN_L
    CMP.B   #4,D6
    BEQ     DECODE_SUB_DN_EA_B
    CMP.B   #5,D6
    BEQ     DECODE_SUB_DN_EA_W
    CMP.B   #6,D6
    BEQ     DECODE_SUB_DN_EA_L
    
    BRA     data_error

DECODE_B    * EOR: DONE, CMP: DONE
    
    JSR     GETDESTINATIONMODE
    
    CMP.B   #0,D6
    BEQ     DECODE_CMP_B
    CMP.B   #1,D6
    BEQ     DECODE_CMP_W
    CMP.B   #2,D6
    BEQ     DECODE_CMP_L
    CMP.B   #4,D6
    BEQ     DECODE_EOR_B
    CMP.B   #5,D6
    BEQ     DECODE_EOR_W
    CMP.B   #6,D6
    BEQ     DECODE_EOR_L
    
    BRA     data_error


DECODE_C    * MULU: DONE MULS: DONE
    JSR GETDESTINATIONMODE
    CMP.B   #3,D6
    BEQ     DECODE_MULU
    CMP.B   #7,D6
    BEQ     DECODE_MULS
    BRA     data_error


DECODE_D    * ADD: DONE, ADDA: DONE
    JSR GETDESTINATIONMODE
    CMP.B   #0,D6
    BEQ     DECODE_ADD_EA_DN_B
    CMP.B   #1,D6
    BEQ     DECODE_ADD_EA_DN_W
    CMP.B   #2,D6
    BEQ     DECODE_ADD_EA_DN_L 
    CMP.B   #3,D6
    BEQ     DECODE_ADDA_W
    CMP.B   #4,D6
    BEQ     DECODE_ADD_DN_EA_B
    CMP.B   #5,D6
    BEQ     DECODE_ADD_DN_EA_W
    CMP.B   #6,D6
    BEQ     DECODE_ADD_DN_EA_L
    CMP.B   #7,D6
    BEQ     DECODE_ADDA_L
    
    BRA     data_error

DECODE_E    * LSL: DONE, LSR: DONE, ASL: DONE, ASR: DONE, ROL: DONE, ROR: DONE    
    BRA CHECK_TYPE_ROTATE
    

DECODE_MOVEM_REGTOMEM
    
    JSR GETDESTINATIONMODE
    
    CMP.B   #2,D6
    BEQ DECODE_MOVEM_REGTOMEM_W
    CMP.B   #3,D6
    BEQ DECODE_MOVEM_REGTOMEM_L
    
    BRA data_error
    

DECODE_MOVEM_MEMTOREG
    JSR GETDESTINATIONMODE
    
    CMP.B   #2,D6
    BEQ DECODE_MOVEM_MEMTOREG_W
    CMP.B   #3,D6
    BEQ DECODE_MOVEM_MEMTOREG_L
    
    BRA data_error
    
DECODE_MOVEM_REGTOMEM_W

    MOVE.L  #buffer,A1
    MOVE.B #'M',(A1)+
    MOVE.B #'O',(A1)+
    MOVE.B #'V',(A1)+
    MOVE.B #'E',(A1)+
    MOVE.B #'M',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'W',(A1)+
    MOVE.B #' ',(A1)+
    
    JSR DECODE_MOVEM_MASK_PRE_CHECK
    MOVE.B #',',(A1)+
    JSR GETSOURCE
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_MOVEM_REGTOMEM_L

    MOVE.L  #buffer,A1
    MOVE.B #'M',(A1)+
    MOVE.B #'O',(A1)+
    MOVE.B #'V',(A1)+
    MOVE.B #'E',(A1)+
    MOVE.B #'M',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'L',(A1)+
    MOVE.B #' ',(A1)+
    
    JSR DECODE_MOVEM_MASK_PRE_CHECK
    MOVE.B #',',(A1)+
    JSR GETSOURCE
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_MOVEM_MEMTOREG_W
    
    MOVE.L  #buffer,A1
    MOVE.B #'M',(A1)+
    MOVE.B #'O',(A1)+
    MOVE.B #'V',(A1)+
    MOVE.B #'E',(A1)+
    MOVE.B #'M',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'W',(A1)+
    MOVE.B #' ',(A1)+
    
    JSR DECODE_MOVEM_EA_CHECK
    MOVE.B #',',(A1)+
    JSR DECODE_MOVEM_MASK_POST
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_MOVEM_MEMTOREG_L
    
    MOVE.L  #buffer,A1
    MOVE.B #'M',(A1)+
    MOVE.B #'O',(A1)+
    MOVE.B #'V',(A1)+
    MOVE.B #'E',(A1)+
    MOVE.B #'M',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'L',(A1)+
    MOVE.B #' ',(A1)+
    
    JSR DECODE_MOVEM_EA_CHECK
    MOVE.B #',',(A1)+
    JSR DECODE_MOVEM_MASK_POST
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS

DECODE_MOVEM_MASK_PRE_CHECK
    JSR GETSOURCEMODE
    CMP.B   #4,D6
    BEQ DECODE_MOVEM_MASK_PRE
    BRA DECODE_MOVEM_MASK_POST
    
DECODE_MOVEM_MASK_PRE
    MOVE.B  (A4)+,D2
    JSR DECODE_MOVEM_MASK_AN_PRE
    MOVE.B  #'/',(A1)+
    MOVE.B  (A4)+,D2
    JSR DECODE_MOVEM_MASK_DN_PRE
    RTS
    
DECODE_MOVEM_EA_CHECK
    JSR GETSOURCEMODE
    CMP.B #7,D7             ; Means we gotta grab data so we need to do that first
    BEQ GRAB_MOVEM_DATA     ; Before we figure out the bitmask
    JSR GETSOURCE           ; Otherwise just get the source
    RTS                     ; then return
    
GRAB_MOVEM_DATA
                ; gets the 16 bits for the register mask so we can grab the EA
    RTS
    
DECODE_MOVEM_MASK_POST
    MOVE.B  (A4)+,D2
    JSR DECODE_MOVEM_MASK_AN_POST
    MOVE.B  #'/',(A1)+    
    MOVE.B  (A4)+,D2
    JSR DECODE_MOVEM_MASK_DN_POST
    RTS
    
DECODE_MOVEM_MASK_AN_PRE
    CLR.L       D4
    MOVE.B      #1,D5           ; to let the print know it's a An
    BRA         DECODE_MOVEM_MASK_PRE_DATA

    
DECODE_MOVEM_MASK_AN_POST
    CLR.L       D4
    MOVE.B      #1,D5           ; to let the print know it's a An
    BRA         DECODE_MOVEM_MASK_POST_DATA
    RTS
    
DECODE_MOVEM_MASK_DN_PRE
    CLR.L       D4
    MOVE.B      #0,D5           ; to let the print know it's a Dn
    BRA         DECODE_MOVEM_MASK_PRE_DATA
    RTS

DECODE_MOVEM_MASK_DN_POST
    CLR.L       D4
    MOVE.B      #0,D5           ; to let the print know it's a Dn
    BRA         DECODE_MOVEM_MASK_POST_DATA
    RTS

DECODE_MOVEM_MASK_POST_DATA
    MOVE.B      D2,D1
    LSR         #7,D1           ; Shifting everything to the right 
    MOVE.B      #7,D0           ; For knowing what register this is
    JSR DECODE_MOVEM_VALUE
    MOVE.B      D2,D1
    LSL.B       #1,D1
    LSR.B       #7,D1
    MOVE.B      #6,D0           ; For knowing what register this is
    JSR DECODE_MOVEM_VALUE 
    MOVE.B      D2,D1   
    LSL.B       #2,D1
    LSR.B       #7,D1         
    MOVE.B      #5,D0           ; For knowing what register this is
    JSR DECODE_MOVEM_VALUE    
    MOVE.B      D2,D1
    LSL.B       #3,D1
    LSR.B       #7,D1
    MOVE.B      #4,D0           ; For knowing what register this is
    JSR DECODE_MOVEM_VALUE    
    MOVE.B      D2,D1    
    LSL.B       #4,D1
    LSR.B       #7,D1
    MOVE.B      #3,D0           ; For knowing what register this is
    JSR DECODE_MOVEM_VALUE    
    MOVE.B      D2,D1     
    LSL.B       #5,D1
    LSR.B       #7,D1    
    MOVE.B      #2,D0           ; For knowing what register this is
    JSR DECODE_MOVEM_VALUE  
    MOVE.B      D2,D1           
    LSL.B       #6,D1
    LSR.B       #7,D1    
    MOVE.B      #1,D0           ; For knowing what register this is
    JSR DECODE_MOVEM_VALUE    
    MOVE.B      D2,D1       
    LSL.B       #7,D1
    LSR.B       #7,D1
    MOVE.B      #0,D0           ; For knowing what register this is
    JSR DECODE_MOVEM_FINAL_VALUE      
    RTS

DECODE_MOVEM_MASK_PRE_DATA
    MOVE.B      D2,D1
    LSR         #7,D1           ; Shifting everything to the right 
    MOVE.B      #0,D0           ; For knowing what register this is
    JSR DECODE_MOVEM_VALUE
    MOVE.B      D2,D1
    LSL.B       #1,D1
    LSR.B       #7,D1
    MOVE.B      #1,D0           ; For knowing what register this is
    JSR DECODE_MOVEM_VALUE 
    MOVE.B      D2,D1   
    LSL.B       #2,D1
    LSR.B       #7,D1         
    MOVE.B      #2,D0           ; For knowing what register this is
    JSR DECODE_MOVEM_VALUE    
    MOVE.B      D2,D1
    LSL.B       #3,D1
    LSR.B       #7,D1
    MOVE.B      #3,D0           ; For knowing what register this is
    JSR DECODE_MOVEM_VALUE    
    MOVE.B      D2,D1    
    LSL.B       #4,D1
    LSR.B       #7,D1
    MOVE.B      #4,D0           ; For knowing what register this is
    JSR DECODE_MOVEM_VALUE    
    MOVE.B      D2,D1     
    LSL.B       #5,D1
    LSR.B       #7,D1    
    MOVE.B      #5,D0           ; For knowing what register this is
    JSR DECODE_MOVEM_VALUE        
    MOVE.B      D2,D1     
    LSL.B       #6,D1
    LSR.B       #7,D1    
    MOVE.B      #6,D0           ; For knowing what register this is
    JSR DECODE_MOVEM_VALUE      
    MOVE.B      D2,D1     
    LSL.B       #7,D1
    LSR.B       #7,D1
    MOVE.B      #7,D0           ; For knowing what register this is
    JSR DECODE_MOVEM_FINAL_VALUE      
    RTS
    
DECODE_MOVEM_FINAL_VALUE
    CMP.B   #1,D1
    BEQ     CHECK_PRINT_FINAL_VALUE
    CMP.B   #1,D4
    BEQ     PRINT_PREVIOUS_VALUE
    MOVE.B  #0,D4
    RTS
    
CHECK_PRINT_FINAL_VALUE
    CMP.B   #0,D4
    BEQ     PRINT_MOVEM_CHAR
    MOVE.B  #0,D4
    MOVE.B  #'-',(A1)+
    CMP.B   #1,D5
    BEQ     PRINT_MOVEM_AN
    CMP.B   #0,D5
    BEQ     PRINT_MOVEM_DN
    
    RTS    

DECODE_MOVEM_VALUE
    CMP.B   #1,D1             ; Check if the register is used
    BEQ CHECK_PRINT_VALUE   ; if so we need to check if we need to print it
    CMP.B   #1,D4
    BEQ     PRINT_PREVIOUS_VALUE
    MOVE.B  #0,D4
    RTS                     ; if we don't then return
 

CHECK_PRINT_VALUE
    CMP.B   #0,D4           ; We know nothing has been printed before so print
    BEQ PRINT_MOVEM_CHAR
    MOVE.B  D0,D6           ; Otherwise move to previous register so it can 
                            ; be printed later on
    MOVE.B  #1,D4                            
    RTS
    
PRINT_PREVIOUS_VALUE
    MOVE.B  #0,D4
    MOVE.B  D6,D0
    MOVE.B  #'-',(A1)+
    CMP.B   #1,D5
    BEQ     PRINT_MOVEM_AN
    CMP.B   #0,D5
    BEQ     PRINT_MOVEM_DN
    
    RTS
    
PRINT_MOVEM_CHAR 
    MOVE.B  #1,D4
    CMP.B   #1,D5
    BEQ     PRINT_MOVEM_AN
    CMP.B   #0,D5
    BEQ     PRINT_MOVEM_DN

    RTS
   
PRINT_MOVEM_AN
    MOVE.B  #'A',(A1)+
    MOVE.B  D0,D7
    JSR     HEX_TO_CHAR
    MOVE.B  D7,(A1)+
    RTS
    
PRINT_MOVEM_DN
    MOVE.B  #'D',(A1)+
    MOVE.B  D0,D7
    JSR     HEX_TO_CHAR
    MOVE.B  D7,(A1)+
    RTS
    
DECODE_ADD_EA_DN_B
    MOVE.L  #buffer,A1
    MOVE.B #'A',(A1)+
    MOVE.B #'D',(A1)+
    MOVE.B #'D',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'B',(A1)+
    MOVE.B #' ',(A1)+
    MOVE.B  #0,D4
    JSR GETSOURCE
    MOVE.B  #',',(A1)+
    JSR GET_DESTINATION_DREG
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT

DECODE_ADD_EA_DN_W
    MOVE.L  #buffer,A1
    MOVE.B #'A',(A1)+
    MOVE.B #'D',(A1)+
    MOVE.B #'D',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'W',(A1)+
    MOVE.B #' ',(A1)+
    MOVE.B  #2,D4    
    JSR GETSOURCE
    MOVE.B  #',',(A1)+
    JSR GET_DESTINATION_DREG
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS

DECODE_ADD_EA_DN_L 
    MOVE.L  #buffer,A1
    MOVE.B #'A',(A1)+
    MOVE.B #'D',(A1)+
    MOVE.B #'D',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'L',(A1)+
    MOVE.B #' ',(A1)+
    MOVE.B  #3,D4    
    JSR GETSOURCE
    MOVE.B  #',',(A1)+
    JSR GET_DESTINATION_DREG
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS

DECODE_ADDA_W
    MOVE.L  #buffer,A1
    MOVE.B #'A',(A1)+
    MOVE.B #'D',(A1)+
    MOVE.B #'D',(A1)+
    MOVE.B #'A',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'W',(A1)+
    MOVE.B #' ',(A1)+
    MOVE.B  #2,D4    
    JSR GETSOURCE
    MOVE.B  #',',(A1)+
    JSR GET_DESTINATION_ADDREG
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS

DECODE_ADD_DN_EA_B
    MOVE.L  #buffer,A1
    MOVE.B #'A',(A1)+
    MOVE.B #'D',(A1)+
    MOVE.B #'D',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'B',(A1)+
    MOVE.B #' ',(A1)+
    JSR GET_DESTINATION_DREG
    MOVE.B  #',',(A1)+
    MOVE.B  #0,D4
    JSR GETSOURCE
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS

DECODE_ADD_DN_EA_W
    MOVE.L  #buffer,A1
    MOVE.B #'A',(A1)+
    MOVE.B #'D',(A1)+
    MOVE.B #'D',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'W',(A1)+
    MOVE.B #' ',(A1)+
    JSR GET_DESTINATION_DREG
    MOVE.B  #',',(A1)+
    MOVE.B  #2,D4
    JSR GETSOURCE
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_ADD_DN_EA_L
    MOVE.L  #buffer,A1
    MOVE.B #'A',(A1)+
    MOVE.B #'D',(A1)+
    MOVE.B #'D',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'L',(A1)+
    MOVE.B #' ',(A1)+
    JSR GET_DESTINATION_DREG
    MOVE.B  #',',(A1)+
    MOVE.B  #3,D4
    JSR GETSOURCE
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_ADDA_L
    MOVE.L  #buffer,A1
    MOVE.B #'A',(A1)+
    MOVE.B #'D',(A1)+
    MOVE.B #'D',(A1)+
    MOVE.B #'A',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'L',(A1)+
    MOVE.B #' ',(A1)+
    MOVE.B  #3,D4
    JSR GETSOURCE
    MOVE.B  #',',(A1)+
    JSR GET_DESTINATION_ADDREG
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_CMP_B
    MOVE.L  #buffer,A1
    MOVE.B #'C',(A1)+
    MOVE.B #'M',(A1)+
    MOVE.B #'P',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'B',(A1)+
    MOVE.B #' ',(A1)+
    MOVE.B  #0,D4
    JSR GETSOURCE
    MOVE.B #',',(A1)+
    JSR GET_DESTINATION_DREG
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_CMP_W
    MOVE.L  #buffer,A1
    MOVE.B #'C',(A1)+
    MOVE.B #'M',(A1)+
    MOVE.B #'P',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'W',(A1)+
    MOVE.B #' ',(A1)+
    MOVE.B  #2,D4
    JSR GETSOURCE
    MOVE.B #',',(A1)+
    JSR GET_DESTINATION_DREG
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_CMP_L
    MOVE.L  #buffer,A1
    MOVE.B #'C',(A1)+
    MOVE.B #'M',(A1)+
    MOVE.B #'P',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'L',(A1)+
    MOVE.B #' ',(A1)+
    MOVE.B  #3,D4
    JSR GETSOURCE
    MOVE.B #',',(A1)+
    JSR GET_DESTINATION_DREG
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_EOR_B
    MOVE.L  #buffer,A1
    MOVE.B #'E',(A1)+
    MOVE.B #'O',(A1)+
    MOVE.B #'R',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'B',(A1)+
    MOVE.B #' ',(A1)+
    JSR GET_DESTINATION_DREG
    MOVE.B #',',(A1)+
    MOVE.B  #0,D4
    JSR GETSOURCE
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_EOR_W
    MOVE.L  #buffer,A1
    MOVE.B #'E',(A1)+
    MOVE.B #'O',(A1)+
    MOVE.B #'R',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'W',(A1)+
    MOVE.B #' ',(A1)+
    JSR GET_DESTINATION_DREG
    MOVE.B #',',(A1)+
    MOVE.B  #2,D4
    JSR GETSOURCE
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS

DECODE_EOR_L
    MOVE.L  #buffer,A1
    MOVE.B #'E',(A1)+
    MOVE.B #'O',(A1)+
    MOVE.B #'R',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'L',(A1)+
    MOVE.B #' ',(A1)+
    JSR GET_DESTINATION_DREG
    MOVE.B #',',(A1)+
    MOVE.B  #3,D4
    JSR GETSOURCE
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
   
DECODE_OR_EA_DN_B
    MOVE.L  #buffer,A1
    MOVE.B #'O',(A1)+
    MOVE.B #'R',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'B',(A1)+
    MOVE.B #' ',(A1)+
    MOVE.B  #0,D4
    JSR GETSOURCE
    MOVE.B  #',',(A1)+
    JSR GET_DESTINATION_DREG
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS

DECODE_OR_EA_DN_W
    MOVE.L  #buffer,A1
    MOVE.B #'O',(A1)+
    MOVE.B #'R',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'W',(A1)+
    MOVE.B #' ',(A1)+
    MOVE.B  #2,D4
    JSR GETSOURCE
    MOVE.B  #',',(A1)+
    JSR GET_DESTINATION_DREG
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS

DECODE_OR_EA_DN_L
    MOVE.L  #buffer,A1
    MOVE.B #'O',(A1)+
    MOVE.B #'R',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'L',(A1)+
    MOVE.B #' ',(A1)+
    MOVE.B  #3,D4
    JSR GETSOURCE
    MOVE.B  #',',(A1)+
    JSR GET_DESTINATION_DREG
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS

DECODE_OR_DN_EA_B
    MOVE.L  #buffer,A1
    MOVE.B #'O',(A1)+
    MOVE.B #'R',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'B',(A1)+
    MOVE.B #' ',(A1)+
    JSR GET_DESTINATION_DREG
    MOVE.B  #',',(A1)+
    MOVE.B  #0,D4
    JSR GETSOURCE
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS

DECODE_OR_DN_EA_W
    MOVE.L  #buffer,A1
    MOVE.B #'O',(A1)+
    MOVE.B #'R',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'W',(A1)+
    MOVE.B #' ',(A1)+
    JSR GET_DESTINATION_DREG
    MOVE.B  #',',(A1)+
    MOVE.B  #2,D4
    JSR GETSOURCE
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS

DECODE_OR_DN_EA_L
    MOVE.L  #buffer,A1
    MOVE.B #'O',(A1)+
    MOVE.B #'R',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'L',(A1)+
    MOVE.B #' ',(A1)+
    JSR GET_DESTINATION_DREG
    MOVE.B  #',',(A1)+
    MOVE.B  #3,D4
    JSR GETSOURCE
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_SUBQ_B
    MOVE.L  #buffer,A1
    MOVE.B #'S',(A1)+
    MOVE.B #'U',(A1)+
    MOVE.B #'B',(A1)+
    MOVE.B #'Q',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'B',(A1)+
    MOVE.B #' ',(A1)+ 
    
    JSR GET_COUNT
    MOVE.B #',',(A1)+
    MOVE.B  #0,D4
    JSR GETSOURCE
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS

DECODE_SUBQ_W

    MOVE.L  #buffer,A1
    MOVE.B #'S',(A1)+
    MOVE.B #'U',(A1)+
    MOVE.B #'B',(A1)+
    MOVE.B #'Q',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'W',(A1)+
    MOVE.B #' ',(A1)+ 
    
    JSR GET_COUNT
    MOVE.B #',',(A1)+
    MOVE.B  #0,D4
    JSR GETSOURCE
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS

DECODE_SUBQ_L

    MOVE.L  #buffer,A1
    MOVE.B #'S',(A1)+
    MOVE.B #'U',(A1)+
    MOVE.B #'B',(A1)+
    MOVE.B #'Q',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'L',(A1)+
    MOVE.B #' ',(A1)+ 
    
    JSR GET_COUNT
    MOVE.B #',',(A1)+
    MOVE.B  #0,D4
    JSR GETSOURCE
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_SUB_EA_DN_B
    MOVE.L  #buffer,A1
    MOVE.B #'S',(A1)+
    MOVE.B #'U',(A1)+
    MOVE.B #'B',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'B',(A1)+
    MOVE.B #' ',(A1)+
    MOVE.B  #0,D4
    JSR GETSOURCE
    MOVE.B  #',',(A1)+
    JSR GET_DESTINATION_DREG
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_SUB_EA_DN_W
    MOVE.L  #buffer,A1
    MOVE.B #'S',(A1)+
    MOVE.B #'U',(A1)+
    MOVE.B #'B',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'W',(A1)+
    MOVE.B #' ',(A1)+
    MOVE.B  #2,D4
    JSR GETSOURCE
    MOVE.B  #',',(A1)+
    JSR GET_DESTINATION_DREG
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_SUB_EA_DN_L
    MOVE.L  #buffer,A1
    MOVE.B #'S',(A1)+
    MOVE.B #'U',(A1)+
    MOVE.B #'B',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'L',(A1)+
    MOVE.B #' ',(A1)+
    MOVE.B  #3,D4
    JSR GETSOURCE
    MOVE.B  #',',(A1)+
    JSR GET_DESTINATION_DREG
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_SUB_DN_EA_B
    MOVE.L  #buffer,A1
    MOVE.B #'S',(A1)+
    MOVE.B #'U',(A1)+
    MOVE.B #'B',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'B',(A1)+
    MOVE.B #' ',(A1)+
    JSR GET_DESTINATION_DREG
    MOVE.B  #',',(A1)+
    MOVE.B  #0,D4
    JSR GETSOURCE
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
    
DECODE_SUB_DN_EA_W
    MOVE.L  #buffer,A1
    MOVE.B #'S',(A1)+
    MOVE.B #'U',(A1)+
    MOVE.B #'B',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'W',(A1)+
    MOVE.B #' ',(A1)+
    JSR GET_DESTINATION_DREG
    MOVE.B  #',',(A1)+
    MOVE.B  #0,D4
    JSR GETSOURCE
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS

    
DECODE_SUB_DN_EA_L
    MOVE.L  #buffer,A1
    MOVE.B #'S',(A1)+
    MOVE.B #'U',(A1)+
    MOVE.B #'B',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'L',(A1)+
    MOVE.B #' ',(A1)+
    JSR GET_DESTINATION_DREG
    MOVE.B  #',',(A1)+
    MOVE.B  #3,D4
    JSR GETSOURCE
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_BRA
    
    MOVE.L  #buffer,A1
    MOVE.B  #'B',(A1)+
    MOVE.B  #'R',(A1)+
    MOVE.B  #'A',(A1)+
    MOVE.B  #' ',(A1)+

    MOVE.W  D3,D1
    LSL     #8,D1
    LSR     #8,D1

    MOVE.B  #'$',(A1)+
    CMP.B   #$00,D1
    BEQ     DECODE_16_BIT_DISPLACEMENT
    CMP.B   #$FF,D1
    BEQ     DECODE_32_BIT_DISPLACEMENT
    JSR PUSH_EA_B   ; Push the first 8 bits in displacement
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_BCC_HI
    MOVE.L  #buffer,A1
    MOVE.B  #'B',(A1)+
    MOVE.B  #'H',(A1)+
    MOVE.B  #'I',(A1)+
    MOVE.B  #' ',(A1)+

    MOVE.W  D3,D1
    LSL     #8,D1
    LSR     #8,D1

    MOVE.B  #'$',(A1)+
    CMP.B   #$00,D1
    BEQ     DECODE_16_BIT_DISPLACEMENT
    CMP.B   #$FF,D1
    BEQ     DECODE_32_BIT_DISPLACEMENT
    JSR PUSH_EA_B   ; Push the first 8 bits in displacement
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_BCC_LS
    
    MOVE.L  #buffer,A1
    MOVE.B  #'B',(A1)+
    MOVE.B  #'L',(A1)+
    MOVE.B  #'S',(A1)+
    MOVE.B  #' ',(A1)+

    MOVE.W  D3,D1
    LSL     #8,D1
    LSR     #8,D1

    MOVE.B  #'$',(A1)+
    CMP.B   #$00,D1
    BEQ     DECODE_16_BIT_DISPLACEMENT
    CMP.B   #$FF,D1
    BEQ     DECODE_32_BIT_DISPLACEMENT
    JSR PUSH_EA_B   ; Push the first 8 bits in displacement
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_BCC_CCHI
    
    MOVE.L  #buffer,A1
    MOVE.B  #'B',(A1)+
    MOVE.B  #'C',(A1)+
    MOVE.B  #'C',(A1)+
    MOVE.B  #' ',(A1)+

    MOVE.W  D3,D1
    LSL     #8,D1
    LSR     #8,D1

    MOVE.B  #'$',(A1)+
    CMP.B   #$00,D1
    BEQ     DECODE_16_BIT_DISPLACEMENT
    CMP.B   #$FF,D1
    BEQ     DECODE_32_BIT_DISPLACEMENT
    JSR PUSH_EA_B   ; Push the first 8 bits in displacement
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_BCC_CCLO
    
    MOVE.L  #buffer,A1
    MOVE.B  #'B',(A1)+
    MOVE.B  #'C',(A1)+
    MOVE.B  #'S',(A1)+
    MOVE.B  #' ',(A1)+

    MOVE.W  D3,D1
    LSL     #8,D1
    LSR     #8,D1

    MOVE.B  #'$',(A1)+
    CMP.B   #$00,D1
    BEQ     DECODE_16_BIT_DISPLACEMENT
    CMP.B   #$FF,D1
    BEQ     DECODE_32_BIT_DISPLACEMENT
    JSR PUSH_EA_B   ; Push the first 8 bits in displacement
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_BCC_NE
    
    MOVE.L  #buffer,A1
    MOVE.B  #'B',(A1)+
    MOVE.B  #'N',(A1)+
    MOVE.B  #'E',(A1)+
    MOVE.B  #' ',(A1)+

    MOVE.W  D3,D1
    LSL     #8,D1
    LSR     #8,D1

    MOVE.B  #'$',(A1)+
    CMP.B   #$00,D1
    BEQ     DECODE_16_BIT_DISPLACEMENT
    CMP.B   #$FF,D1
    BEQ     DECODE_32_BIT_DISPLACEMENT
    JSR PUSH_EA_B   ; Push the first 8 bits in displacement
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_BCC_EQ

    MOVE.L  #buffer,A1
    MOVE.B  #'B',(A1)+
    MOVE.B  #'E',(A1)+
    MOVE.B  #'Q',(A1)+
    MOVE.B  #' ',(A1)+

    MOVE.W  D3,D1
    LSL     #8,D1
    LSR     #8,D1

    MOVE.B  #'$',(A1)+
    CMP.B   #$00,D1
    BEQ     DECODE_16_BIT_DISPLACEMENT
    CMP.B   #$FF,D1
    BEQ     DECODE_32_BIT_DISPLACEMENT
    JSR PUSH_EA_B   ; Push the first 8 bits in displacement
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_BCC_VC
    
    MOVE.L  #buffer,A1
    MOVE.B  #'B',(A1)+
    MOVE.B  #'V',(A1)+
    MOVE.B  #'C',(A1)+
    MOVE.B  #' ',(A1)+

    MOVE.W  D3,D1
    LSL     #8,D1
    LSR     #8,D1

    MOVE.B  #'$',(A1)+
    CMP.B   #$00,D1
    BEQ     DECODE_16_BIT_DISPLACEMENT
    CMP.B   #$FF,D1
    BEQ     DECODE_32_BIT_DISPLACEMENT
    JSR PUSH_EA_B   ; Push the first 8 bits in displacement
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_BCC_VS

    MOVE.L  #buffer,A1
    MOVE.B  #'B',(A1)+
    MOVE.B  #'V',(A1)+
    MOVE.B  #'S',(A1)+
    MOVE.B  #' ',(A1)+

    MOVE.W  D3,D1
    LSL     #8,D1
    LSR     #8,D1

    MOVE.B  #'$',(A1)+
    CMP.B   #$00,D1
    BEQ     DECODE_16_BIT_DISPLACEMENT
    CMP.B   #$FF,D1
    BEQ     DECODE_32_BIT_DISPLACEMENT
    JSR PUSH_EA_B   ; Push the first 8 bits in displacement
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_BCC_PL

    MOVE.L  #buffer,A1
    MOVE.B  #'B',(A1)+
    MOVE.B  #'P',(A1)+
    MOVE.B  #'L',(A1)+
    MOVE.B  #' ',(A1)+

    MOVE.W  D3,D1
    LSL     #8,D1
    LSR     #8,D1

    MOVE.B  #'$',(A1)+
    CMP.B   #$00,D1
    BEQ     DECODE_16_BIT_DISPLACEMENT
    CMP.B   #$FF,D1
    BEQ     DECODE_32_BIT_DISPLACEMENT
    JSR PUSH_EA_B   ; Push the first 8 bits in displacement
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_BCC_MI

    MOVE.L  #buffer,A1
    MOVE.B  #'B',(A1)+
    MOVE.B  #'M',(A1)+
    MOVE.B  #'I',(A1)+
    MOVE.B  #' ',(A1)+

    MOVE.W  D3,D1
    LSL     #8,D1
    LSR     #8,D1

    MOVE.B  #'$',(A1)+
    CMP.B   #$00,D1
    BEQ     DECODE_16_BIT_DISPLACEMENT
    CMP.B   #$FF,D1
    BEQ     DECODE_32_BIT_DISPLACEMENT
    JSR PUSH_EA_B   ; Push the first 8 bits in displacement
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_BCC_GE

    MOVE.L  #buffer,A1
    MOVE.B  #'B',(A1)+
    MOVE.B  #'G',(A1)+
    MOVE.B  #'E',(A1)+
    MOVE.B  #' ',(A1)+

    MOVE.W  D3,D1
    LSL     #8,D1
    LSR     #8,D1

    MOVE.B  #'$',(A1)+
    CMP.B   #$00,D1
    BEQ     DECODE_16_BIT_DISPLACEMENT
    CMP.B   #$FF,D1
    BEQ     DECODE_32_BIT_DISPLACEMENT
    JSR PUSH_EA_B   ; Push the first 8 bits in displacement
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_BCC_LT

    MOVE.L  #buffer,A1
    MOVE.B  #'B',(A1)+
    MOVE.B  #'L',(A1)+
    MOVE.B  #'T',(A1)+
    MOVE.B  #' ',(A1)+

    MOVE.W  D3,D1
    LSL     #8,D1
    LSR     #8,D1

    MOVE.B  #'$',(A1)+
    CMP.B   #$00,D1
    BEQ     DECODE_16_BIT_DISPLACEMENT
    CMP.B   #$FF,D1
    BEQ     DECODE_32_BIT_DISPLACEMENT
    JSR PUSH_EA_B   ; Push the first 8 bits in displacement
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_BCC_GT

    MOVE.L  #buffer,A1
    MOVE.B  #'B',(A1)+
    MOVE.B  #'G',(A1)+
    MOVE.B  #'T',(A1)+
    MOVE.B  #' ',(A1)+

    MOVE.W  D3,D1
    LSL     #8,D1
    LSR     #8,D1

    MOVE.B  #'$',(A1)+
    CMP.B   #$00,D1
    BEQ     DECODE_16_BIT_DISPLACEMENT
    CMP.B   #$FF,D1
    BEQ     DECODE_32_BIT_DISPLACEMENT
    JSR PUSH_EA_B   ; Push the first 8 bits in displacement
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_BCC_LE
    
    MOVE.L  #buffer,A1
    MOVE.B  #'B',(A1)+
    MOVE.B  #'L',(A1)+
    MOVE.B  #'E',(A1)+
    MOVE.B  #' ',(A1)+

    MOVE.W  D3,D1
    LSL     #8,D1
    LSR     #8,D1

    MOVE.B  #'$',(A1)+
    CMP.B   #$00,D1
    BEQ     DECODE_16_BIT_DISPLACEMENT
    CMP.B   #$FF,D1
    BEQ     DECODE_32_BIT_DISPLACEMENT
    JSR PUSH_EA_B   ; Push the first 8 bits in displacement
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_16_BIT_DISPLACEMENT
    MOVE.W  (A4)+,D1
    JSR PUSH_EA_W
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS

DECODE_32_BIT_DISPLACEMENT
    MOVE.L  (A4)+,D1
    JSR PUSH_EA_L
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
CHECK_TYPE_ROTATE
    JSR GETDESTINATIONMODE        ; GET THE THREE BITS NECESSARY TO DETECT ASd,LSd,ROd
    CMP.B   #7,D6
    BEQ CHECK_MEMORY_ROTATE_L     ; MEMORY ROTATE LEFT IS 111 in bits still need to find type
    CMP.B #3,D6
    BEQ CHECK_MEMORY_ROTATE_R     ; MEMORY ROTATE RIGHT IS 011 in bits still need to find type
    JSR GETSOURCEMODE             ; We know it's not a memory rotate so check register rotate
    CMP.B   #7,D6
    BEQ DECODE_REGISTER_RO_REG      ; Know it's a register RO rotate still need to find direction
    CMP.B   #3,D6
    BEQ DECODE_REGISTER_RO_COUNT    ; still need to find direction
    CMP.B   #4,D6
    BEQ DECODE_REGISTER_AS_REG
    CMP.B   #0,D6
    BEQ DECODE_REGISTER_AS_COUNT
    CMP.B   #5,D6
    BEQ DECODE_REGISTER_LS_REG
    CMP.B   #1,D6
    BEQ DECODE_REGISTER_LS_COUNT
    BRA data_error

CHECK_MEMORY_ROTATE_L            ; for when bits 8 7 6 = 111
    JSR GETDESTINATIONREG
    CMP.B   #0,D7
    BEQ DECODE_MEMORY_ASL
    CMP.B   #1,D7
    BEQ DECODE_MEMORY_LSL
    CMP.B   #3,D7
    BEQ DECODE_MEMORY_ROL
    BRA data_error    

CHECK_MEMORY_ROTATE_R         ; for when bits 8 7 6 = 011
    JSR GETDESTINATIONREG
    CMP.B   #0,D7
    BEQ DECODE_MEMORY_ASR
    CMP.B   #1,D7
    BEQ DECODE_MEMORY_LSR
    CMP.B   #3,D7
    BEQ DECODE_MEMORY_ROR
    BRA data_error
    
DECODE_REGISTER_RO_REG      ; Know it's a register RO rotate still need to find direction
    JSR GETDESTINATIONMODE
    LSR #2,D6
    CMP.B #0,D6
    BEQ DECODE_REGISTER_ROR_REG
    BGT DECODE_REGISTER_ROL_REG
    RTS
    
DECODE_REGISTER_RO_COUNT    ; still need to find direction
    JSR GETDESTINATIONMODE
    LSR #2,D6
    CMP.B #0,D6
    BEQ DECODE_REGISTER_ROR_COUNT
    BGT DECODE_REGISTER_ROL_COUNT
    RTS
    
DECODE_REGISTER_AS_REG
    JSR GETDESTINATIONMODE
    LSR #2,D6
    CMP.B #0,D6
    BEQ DECODE_REGISTER_ASR_REG
    BGT DECODE_REGISTER_ASL_REG
    RTS
    
DECODE_REGISTER_AS_COUNT
    JSR GETDESTINATIONMODE
    LSR #2,D6
    CMP.B #0,D6
    BEQ DECODE_REGISTER_ASR_COUNT
    BGT DECODE_REGISTER_ASL_COUNT
    RTS

DECODE_REGISTER_LS_REG
    JSR GETDESTINATIONMODE
    LSR #2,D6
    CMP.B #0,D6
    BEQ DECODE_REGISTER_LSR_REG
    BGT DECODE_REGISTER_LSL_REG
    RTS
    
DECODE_REGISTER_LS_COUNT
    JSR GETDESTINATIONMODE
    LSR #2,D6
    CMP.B #0,D6
    BEQ DECODE_REGISTER_LSR_COUNT
    BGT DECODE_REGISTER_LSL_COUNT
    RTS

DECODE_MEMORY_ASL
    MOVE.L  #buffer,A1
    MOVE.B #'A',(A1)+
    MOVE.B #'S',(A1)+
    MOVE.B #'L',(A1)+
    MOVE.B #' ',(A1)+
    JSR GETSOURCE
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_MEMORY_ASR
    MOVE.L  #buffer,A1
    MOVE.B #'A',(A1)+
    MOVE.B #'S',(A1)+
    MOVE.B #'R',(A1)+
    MOVE.B #' ',(A1)+
    JSR GETSOURCE
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT    
    RTS
    
DECODE_MEMORY_LSL
    MOVE.L  #buffer,A1
    MOVE.B #'L',(A1)+
    MOVE.B #'S',(A1)+
    MOVE.B #'L',(A1)+
    MOVE.B #' ',(A1)+
    JSR GETSOURCE
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT    
    RTS
    
DECODE_MEMORY_LSR
    MOVE.L  #buffer,A1
    MOVE.B #'L',(A1)+
    MOVE.B #'S',(A1)+
    MOVE.B #'R',(A1)+
    MOVE.B #' ',(A1)+
    JSR GETSOURCE
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT    
    RTS
    
DECODE_MEMORY_ROL
    MOVE.L  #buffer,A1
    MOVE.B #'R',(A1)+
    MOVE.B #'O',(A1)+
    MOVE.B #'L',(A1)+
    MOVE.B #' ',(A1)+
    JSR GETSOURCE
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_MEMORY_ROR
    MOVE.L  #buffer,A1
    MOVE.B #'R',(A1)+
    MOVE.B #'O',(A1)+
    MOVE.B #'R',(A1)+
    MOVE.B #' ',(A1)+
    JSR GETSOURCE
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_REGISTER_ASL_REG
    MOVE.L  #buffer,A1
    MOVE.B #'A',(A1)+
    MOVE.B #'S',(A1)+
    MOVE.B #'L',(A1)+
    JSR GET_SHIFT_SIZE
    CLR.L   D2          ; TO LET SIZE KNOW NOT TO GRAB IMMEDIATE DATA
    JSR GET_SIZE
    MOVE.B  #' ',(A1)+
    JSR GET_DESTINATION_DREG
    MOVE.B  #',',(A1)+
    JSR GET_SOURCE_DREG
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS

DECODE_REGISTER_ASL_COUNT
    MOVE.L  #buffer,A1
    MOVE.B #'A',(A1)+
    MOVE.B #'S',(A1)+
    MOVE.B #'L',(A1)+
    JSR GET_SHIFT_SIZE
    CLR.L   D2          ; TO LET SIZE KNOW NOT TO GRAB IMMEDIATE DATA
    JSR GET_SIZE
    MOVE.B  #' ',(A1)+
    JSR GET_COUNT
    MOVE.B  #',',(A1)+
    JSR GET_SOURCE_DREG
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_REGISTER_ASR_REG
    MOVE.L  #buffer,A1
    MOVE.B #'A',(A1)+
    MOVE.B #'S',(A1)+
    MOVE.B #'R',(A1)+
    JSR GET_SHIFT_SIZE
    CLR.L   D2          ; TO LET SIZE KNOW NOT TO GRAB IMMEDIATE DATA
    JSR GET_SIZE
    MOVE.B  #' ',(A1)+
    JSR GET_DESTINATION_DREG
    MOVE.B  #',',(A1)+
    JSR GET_SOURCE_DREG
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS

DECODE_REGISTER_ASR_COUNT
    MOVE.L  #buffer,A1
    MOVE.B #'A',(A1)+
    MOVE.B #'S',(A1)+
    MOVE.B #'R',(A1)+
    JSR GET_SHIFT_SIZE
    CLR.L   D2          ; TO LET SIZE KNOW NOT TO GRAB IMMEDIATE DATA
    JSR GET_SIZE
    MOVE.B  #' ',(A1)+
    JSR GET_COUNT
    MOVE.B  #',',(A1)+
    JSR GET_SOURCE_DREG
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_REGISTER_LSL_REG
    MOVE.L  #buffer,A1
    MOVE.B #'L',(A1)+
    MOVE.B #'S',(A1)+
    MOVE.B #'L',(A1)+
    JSR GET_SHIFT_SIZE
    CLR.L   D2          ; TO LET SIZE KNOW NOT TO GRAB IMMEDIATE DATA
    JSR GET_SIZE
    MOVE.B  #' ',(A1)+
    JSR GET_DESTINATION_DREG
    MOVE.B  #',',(A1)+
    JSR GET_SOURCE_DREG
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS

DECODE_REGISTER_LSL_COUNT
    MOVE.L  #buffer,A1
    MOVE.B #'L',(A1)+
    MOVE.B #'S',(A1)+
    MOVE.B #'L',(A1)+
    JSR GET_SHIFT_SIZE
    CLR.L   D2          ; TO LET SIZE KNOW NOT TO GRAB IMMEDIATE DATA
    JSR GET_SIZE
    MOVE.B  #' ',(A1)+
    JSR GET_COUNT
    MOVE.B  #',',(A1)+
    JSR GET_SOURCE_DREG
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_REGISTER_LSR_REG
    MOVE.L  #buffer,A1
    MOVE.B #'L',(A1)+
    MOVE.B #'S',(A1)+
    MOVE.B #'R',(A1)+
    JSR GET_SHIFT_SIZE
    CLR.L   D2          ; TO LET SIZE KNOW NOT TO GRAB IMMEDIATE DATA
    JSR GET_SIZE
    MOVE.B  #' ',(A1)+
    JSR GET_DESTINATION_DREG
    MOVE.B  #',',(A1)+
    JSR GET_SOURCE_DREG
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS

DECODE_REGISTER_LSR_COUNT
    MOVE.L  #buffer,A1
    MOVE.B #'L',(A1)+
    MOVE.B #'S',(A1)+
    MOVE.B #'R',(A1)+
    JSR GET_SHIFT_SIZE
    CLR.L   D2          ; TO LET SIZE KNOW NOT TO GRAB IMMEDIATE DATA
    JSR GET_SIZE
    MOVE.B  #' ',(A1)+
    JSR GET_COUNT
    MOVE.B  #',',(A1)+
    JSR GET_SOURCE_DREG
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_REGISTER_ROL_REG
    MOVE.L  #buffer,A1
    MOVE.B #'R',(A1)+
    MOVE.B #'O',(A1)+
    MOVE.B #'L',(A1)+
    JSR GET_SHIFT_SIZE
    CLR.L   D2          ; TO LET SIZE KNOW NOT TO GRAB IMMEDIATE DATA
    JSR GET_SIZE
    MOVE.B  #' ',(A1)+
    JSR GET_DESTINATION_DREG
    MOVE.B  #',',(A1)+
    JSR GET_SOURCE_DREG
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS

DECODE_REGISTER_ROL_COUNT
    MOVE.L  #buffer,A1
    MOVE.B #'R',(A1)+
    MOVE.B #'O',(A1)+
    MOVE.B #'L',(A1)+
    JSR GET_SHIFT_SIZE
    CLR.L   D2          ; TO LET SIZE KNOW NOT TO GRAB IMMEDIATE DATA
    JSR GET_SIZE
    MOVE.B  #' ',(A1)+
    JSR GET_COUNT
    MOVE.B  #',',(A1)+
    JSR GET_SOURCE_DREG
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_REGISTER_ROR_REG
    MOVE.L  #buffer,A1
    MOVE.B #'R',(A1)+
    MOVE.B #'O',(A1)+
    MOVE.B #'R',(A1)+
    JSR GET_SHIFT_SIZE
    CLR.L   D2          ; TO LET SIZE KNOW NOT TO GRAB IMMEDIATE DATA
    JSR GET_SIZE
    MOVE.B  #' ',(A1)+
    JSR GET_DESTINATION_DREG    
    MOVE.B  #',',(A1)+
    JSR GET_SOURCE_DREG
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS

DECODE_REGISTER_ROR_COUNT
    MOVE.L  #buffer,A1
    MOVE.B #'R',(A1)+
    MOVE.B #'O',(A1)+
    MOVE.B #'R',(A1)+
    JSR GET_SHIFT_SIZE
    CLR.L   D2          ; TO LET SIZE KNOW NOT TO GRAB IMMEDIATE DATA
    JSR GET_SIZE
    MOVE.B  #' ',(A1)+
    JSR GET_COUNT
    MOVE.B  #',',(A1)+
    JSR GET_SOURCE_DREG
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS

CHECK_LEA_OR_MOVEM
    MOVE.W  D3,D1
    LSL     #4,D1
    LSR     #8,D1
    LSR     #5,D1
    
    CMP.B   #7,D1
    BEQ     DECODE_LEA
    
    JSR     GETDESTINATIONREG
    CMP.B   #4,D7
    BEQ     DECODE_MOVEM_REGTOMEM
    CMP.B   #6,D7
    BEQ     DECODE_MOVEM_MEMTOREG
    
    BRA     data_error
    
DECODE_DIVU
    MOVE.L  #buffer,A1
    MOVE.B #'D',(A1)+
    MOVE.B #'I',(A1)+
    MOVE.B #'V',(A1)+
    MOVE.B #'U',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'W',(A1)+
    MOVE.B #' ',(A1)+
    
    MOVE.B  #2,D4
    JSR GETSOURCE
    MOVE.B #',',(A1)+
    JSR GET_DESTINATION_DREG
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_DIVS
    MOVE.L  #buffer,A1
    MOVE.B #'D',(A1)+
    MOVE.B #'I',(A1)+
    MOVE.B #'V',(A1)+
    MOVE.B #'S',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'W',(A1)+
    MOVE.B #' ',(A1)+
    
    MOVE.B  #2,D4
    JSR GETSOURCE
    MOVE.B #',',(A1)+
    JSR GET_DESTINATION_DREG
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS

DECODE_MULU
    MOVE.L  #buffer,A1
    MOVE.B #'M',(A1)+
    MOVE.B #'U',(A1)+
    MOVE.B #'L',(A1)+
    MOVE.B #'U',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'W',(A1)+
    MOVE.B #' ',(A1)+
    
    MOVE.B  #2,D4
    JSR GETSOURCE
    MOVE.B #',',(A1)+
    JSR GET_DESTINATION_DREG
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_MULS
    MOVE.L  #buffer,A1
    MOVE.B #'M',(A1)+
    MOVE.B #'U',(A1)+
    MOVE.B #'L',(A1)+
    MOVE.B #'S',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'W',(A1)+
    MOVE.B #' ',(A1)+
    
    MOVE.B  #2,D4
    JSR GETSOURCE
    MOVE.B #',',(A1)+
    JSR GET_DESTINATION_DREG
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS


DECODE_DYNAMIC_BCLR
    MOVE.L  #buffer,A1
    MOVE.B  #'B',(A1)+
    MOVE.B  #'C',(A1)+
    MOVE.B  #'L',(A1)+
    MOVE.B  #'R',(A1)+
    MOVE.B  #' ',(A1)+

    JSR GET_DESTINATION_DREG    
    MOVE.B  #',',(A1)+
    JSR GETSOURCE
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS     
    
DECODE_STATIC_BCLR
    MOVE.L  #buffer,A1
    MOVE.B  #'B',(A1)+
    MOVE.B  #'C',(A1)+
    MOVE.B  #'L',(A1)+
    MOVE.B  #'R',(A1)+

    JSR GET_WORD_IMMEDIATE    
    MOVE.B  #',',(A1)+
    JSR GETSOURCE
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    

DECODE_CMPI
    MOVE.L  #buffer,A1
    MOVE.B  #'C',(A1)+
    MOVE.B  #'M',(A1)+
    MOVE.B  #'P',(A1)+
    MOVE.B  #'I',(A1)+

    MOVE.W  D3,D1
    LSL     #8,D1
    LSR     #8,D1
    LSR     #6,D1
    MOVE.B  #$1,D2              ; TO USE IN GET SIZE TO SAY WE NEED IMMEDIATE DATA
    JSR     GET_SIZE
    
    MOVE.B  #',',(A1)+
    JSR     GETSOURCE
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR     PRINT
    RTS
    
DECODE_ORI 
    MOVE.L  #buffer,A1
    MOVE.B  #'O',(A1)+
    MOVE.B  #'R',(A1)+
    MOVE.B  #'I',(A1)+

    MOVE.W  D3,D1
    LSL     #8,D1
    LSR     #8,D1
    LSR     #6,D1
    MOVE.B  #$1,D2              ; TO USE IN GET SIZE TO SAY WE NEED IMMEDIATE DATA
    JSR     GET_SIZE
    
    MOVE.B  #',',(A1)+
    JSR     GETSOURCE
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR     PRINT
    RTS    

DECODE_MOVE_W
    MOVE.L  #buffer,A1
    MOVE.B #'M',(A1)+
    MOVE.B #'O',(A1)+
    MOVE.B #'V',(A1)+
    MOVE.B #'E',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'W',(A1)+
    MOVE.B #' ',(A1)+

    MOVE.B  #2,D4       ; Set to 3 so if it's immediate code it knows to grab a word
    JSR GETSOURCE
    MOVE.B  #',',(A1)+
    JSR GETDESTINATION
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_MOVEA_W
    MOVE.L  #buffer,A1
    MOVE.B #'M',(A1)+
    MOVE.B #'O',(A1)+
    MOVE.B #'V',(A1)+
    MOVE.B #'E',(A1)+
    MOVE.B #'A',(A1)+    
    MOVE.B #'.',(A1)+
    MOVE.B #'W',(A1)+
    MOVE.B #' ',(A1)+

    MOVE.B  #2,D4     ; Set to zero so if it's immediate code it knows to grab a word
    JSR GETSOURCE
    MOVE.B  #',',(A1)+
    JSR GET_DESTINATION_ADDREG
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS  
    
DECODE_MOVE_L
    MOVE.L  #buffer,A1
    MOVE.B #'M',(A1)+
    MOVE.B #'O',(A1)+
    MOVE.B #'V',(A1)+
    MOVE.B #'E',(A1)+
    MOVE.B #'.',(A1)+
    MOVE.B #'L',(A1)+
    MOVE.B #' ',(A1)+

    MOVE.B  #3,D4       ; Set to 3 so if it's immediate code it knows to grab a long
    JSR GETSOURCE
    MOVE.B  #',',(A1)+
    JSR GETDESTINATION
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS
    
DECODE_MOVEA_L
    MOVE.L  #buffer,A1
    MOVE.B #'M',(A1)+
    MOVE.B #'O',(A1)+
    MOVE.B #'V',(A1)+
    MOVE.B #'E',(A1)+
    MOVE.B #'A',(A1)+    
    MOVE.B #'.',(A1)+
    MOVE.B #'L',(A1)+
    MOVE.B #' ',(A1)+

    MOVE.B  #3,D4     ; Set to zero so if it's immediate code it knows to grab a long
    JSR GETSOURCE
    MOVE.B  #',',(A1)+
    JSR GET_DESTINATION_ADDREG
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR PRINT
    RTS  

DECODE_NEG
    MOVE.L  #buffer,A1
    MOVE.B  #'N',(A1)+
    MOVE.B  #'E',(A1)+
    MOVE.B  #'G',(A1)+
    MOVE.W  D3,D1
    LSL     #8,D1
    LSR     #8,D1
    LSR     #6,D1
    
    MOVE.B  #$0,D2
    JSR     GET_SIZE
    MOVE.B  #' ',(A1)+
    JSR     GETSOURCE
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR     PRINT
    RTS
    
DECODE_LEA
    MOVE.L  #buffer,A1
    MOVE.B  #'L',(A1)+
    MOVE.B  #'E',(A1)+
    MOVE.B  #'A',(A1)+
    MOVE.B  #' ',(A1)+
    JSR     GETSOURCE
    MOVE.B  #',',(A1)+
    JSR     GET_DESTINATION_ADDREG
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR     PRINT
    RTS
    
DECODE_NOP
    MOVE.L  #buffer,A1
    MOVE.B  #'N',(A1)+
    MOVE.B  #'O',(A1)+
    MOVE.B  #'P',(A1)+
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR     PRINT
    RTS
    
DECODE_RTS
    MOVE.L  #buffer,A1
    MOVE.B  #'R',(A1)+
    MOVE.B  #'T',(A1)+
    MOVE.B  #'S',(A1)+
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR     PRINT
    RTS
    
DECODE_JSR
    MOVE.L  #buffer,A1
    MOVE.B  #'J',(A1)+
    MOVE.B  #'S',(A1)+
    MOVE.B  #'R',(A1)+
    MOVE.B  #' ',(A1)+
    JSR     GETSOURCE
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR     PRINT
    RTS

GET_SHIFT_SIZE
    JSR GETDESTINATIONMODE
    LSL.B #6,D6
    LSR.B #6,D6
    MOVE.B  D6,D1
    RTS

 * Expects byte to be 00 Word 01 Long 10 in D1
GET_SIZE 
    CMP.B   #%00,D1
    BEQ     GET_BYTE
    CMP.B   #%01,D1
    BEQ     GET_WORD
    CMP.B   #%10,D1
    BEQ     GET_LONG
    
    BRA data_error
    
    
GET_BYTE
    MOVE.B  #'.',(A1)+
    MOVE.B  #'B',(A1)+
    CMP.B   #1,D2                   ; 1 means we need to grab immediate data
    BEQ     GET_BYTE_IMMEDIATE
    RTS

GET_WORD
    MOVE.B  #'.',(A1)+
    MOVE.B  #'W',(A1)+
    CMP.B   #1,D2
    BEQ     GET_WORD_IMMEDIATE
    RTS
    
GET_LONG
    MOVE.B  #'.',(A1)+
    MOVE.B  #'L',(A1)+
    CMP.B   #1,D2
    BEQ     GET_LONG_IMMEDIATE
    RTS    
    
GET_BYTE_IMMEDIATE
    MOVE.B  #' ',(A1)+
    JSR PRINT_EA_ID_REG_B
    RTS

GET_WORD_IMMEDIATE
    MOVE.B  #' ',(A1)+
    JSR PRINT_EA_ID_REG_W
    RTS
    
GET_LONG_IMMEDIATE
    MOVE.B  #' ',(A1)+
    JSR PRINT_EA_ID_REG_L
    RTS
    
*data_error: D7 WORD couldn't be decoded, print it
data_error
    MOVE.L  #buffer,A1                      * Set A1 to point to the Test buffer
    MOVE.B  #'D',(A1)+
    MOVE.B  #'A',(A1)+
    MOVE.B  #'T',(A1)+
    MOVE.B  #'A',(A1)+
    MOVE.B  #CR,(A1)+
    MOVE.B  #LF,(A1)+
    JSR     PRINT
    RTS
        

        
*////////////////////////////////////////////////////////////////////////////////////////
* EA: This is the section for decoding EA
*////////////////////////////////////////////////////////////////////////////////////////

GET_DESTINATION_ADDREG:
    MOVE.L #MARD,D6
    JSR PRINT_EA_MODE
    JSR GETDESTINATIONREG
    JSR PRINT_EA_REG    
    RTS

GET_DESTINATION_DREG:
    MOVE.L #MDRD,D6
    JSR PRINT_EA_MODE
    JSR GETDESTINATIONREG
    JSR PRINT_EA_REG    
    RTS
    
GET_COUNT
    MOVE.B #'#',(A1)+
    MOVE.L #MDRD,D6
    JSR GETDESTINATIONREG
    CMP.B #0,D7
    BEQ PRINT_COUNT_ZERO_FIX
    BGT PRINT_COUNT
    
PRINT_COUNT_ZERO_FIX
    MOVE.L #$08,D7
    JSR HEX_TO_CHAR
    MOVE.B  D7,(A1)+
    RTS

PRINT_COUNT
    JSR HEX_TO_CHAR
    MOVE.B  D7,(A1)+
    RTS
    
GET_SOURCE_ADDREG:
    MOVE.L #MARD,D6
    JSR PRINT_EA_MODE
    JSR GETSOURCEREG
    JSR PRINT_EA_REG    
    RTS

GET_SOURCE_DREG:
    MOVE.L #MDRD,D6
    JSR PRINT_EA_MODE
    JSR GETSOURCEREG
    JSR PRINT_EA_REG    
    RTS
    
GETSOURCE:
    JSR GETSOURCEMODE
    JSR PRINT_EA_MODE
    JSR GETSOURCEREG
    JSR PRINT_EA_REG
    RTS

GETDESTINATION:
    JSR GETDESTINATIONMODE
    JSR PRINT_EA_MODE
    JSR GETDESTINATIONREG
    JSR PRINT_EA_REG
    RTS
    
GETDESTINATIONREG:    
    MOVE.L D3,D1                ; this is for detecting the register
    LSL #4,D1                   ; Remove starting address
    LSR #8,D1                   ; Put back into place
    LSR #5,D1                   ; Remove excess so now it's 010
    MOVE.B D1,D7
    RTS
    
GETDESTINATIONMODE:
    MOVE.L D3,D1                ; this is for detecting the mode
    LSL #7,D1                   ; Remove starting address
    LSR #8,D1                   ; Put back into place
    LSR #5,D1                   ; Remove excess so now it's 000
    MOVE.B D1,D6
    RTS
    

GETSOURCEMODE:    
    MOVE.L D3,D1                ; this is for detecting the mode
    LSL #8,D1                   ; Remove starting address
    LSL #2,D1                   ; Remove offset
    LSR #8,D1                   ; Put back into place
    LSR #5,D1                   ; Remove register
    MOVE.B D1,D6                ; store in D6 to be used for display
    RTS
    
GETSOURCEREG:
    MOVE.L D3,D1                ; this is for detecting the register
    LSL #8,D1                   ; Remove starting address
    LSL #5,D1                   ; Remove offset
    LSR #8,D1                   ; Put back into place
    LSR #5,D1                   ; Remove excess 
    MOVE.B D1,D7                ; store in D7 to be used for display
    RTS
            

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
    RTS

PRINT_EA_REG:
    CMP.B   #MDRD,D6                ; If the mode is a Dn then we just print the value in the register
    BEQ     PRINT_EA_REG_VALUE
    CMP.B   #MARD,D6                ; If the mode is a An then we just print the value in the register
    BEQ     PRINT_EA_REG_VALUE
    CMP.B   #MARI,D6                ; If the mode is a (An) we need to print the reg value and )
    BEQ     PRINT_EA_ARI_REG
    CMP.B   #MARIP,D6               ; If the mode is a (An)+ we need to print the reg value and )+
    BEQ     PRINT_EA_ARIP_REG           
    CMP.B   #MARIM,D6               ; If the mode is a -(An) we need to print the reg value and )
    BEQ     PRINT_EA_ARI_REG
    CMP.B   #RAWA,D7                ; The reg is a .w so we need to print the address and ).W
    BEQ     PRINT_EA_AWA_REG
    CMP.B   #RALA,D7                ; The reg is a .l so we need to print the address and ).L
    BEQ     PRINT_EA_ALA_REG
    CMP.B   #RID,D7                 ; The reg can be several different lengths so go to our operation and compare address mode, print address and >
    BEQ     PRINT_EA_ID_REG
    
PRINT_EA_REG_END:
    CMP.B   #MDRD,D6                ; If the mode is a Dn then we just print the value in the register
    BEQ     DONE_PRINTING
    CMP.B   #MARD,D6                ; If the mode is a An then we just print the value in the register
    BEQ     DONE_PRINTING
    CMP.B   #MARI,D6                ; If the mode is a (An) we need to print the reg value and )
    BEQ     PRINT_EA_ARI_REG_END
    CMP.B   #MARIP,D6               ; If the mode is a (An)+ we need to print the reg value and )+
    BEQ     PRINT_EA_ARIP_REG_END 
    CMP.B   #MARIM,D6               ; If the mode is a -(An) we need to print the reg value and )
    BEQ     PRINT_EA_ARI_REG_END
    RTS          

DONE_PRINTING:
    RTS
    
PRINT_EA_REG_VALUE:
    JSR HEX_TO_CHAR
    MOVE.B  D7,(A1)+
    JMP PRINT_EA_REG_END
    
PRINT_EA_ARI_REG:
   JMP PRINT_EA_REG_VALUE
               
PRINT_EA_ARIP_REG:
   JMP PRINT_EA_REG_VALUE 
   
PRINT_EA_ARI_REG_END:
    MOVE.B  #')',(A1)+
    RTS
    
PRINT_EA_ARIP_REG_END:
    MOVE.B  #')',(A1)+
    MOVE.B  #'+',(A1)+
    RTS
    
PRINT_EA_AWA_REG:
    MOVE.B  #'(',(A1)+
    MOVE.W  (A4)+,D1
    JSR     PUSH_EA_W
    MOVE.B  #')',(A1)+
    MOVE.B  #'.',(A1)+
    MOVE.B  #'W',(A1)+

    RTS

PRINT_EA_ALA_REG:
    MOVE.B  #'(',(A1)+
    MOVE.L  (A4)+,D1
    JSR     PUSH_EA_L
    MOVE.B  #')',(A1)+
    MOVE.B  #'.',(A1)+
    MOVE.B  #'L',(A1)+
    RTS
        
PRINT_EA_ID_REG:
    CMP.B   #0,D4
    BEQ     PRINT_EA_ID_REG_B ; I think it might be a Byte not WORD
    CMP.B   #2,D4
    BEQ     PRINT_EA_ID_REG_W
    CMP.B   #3,D4
    BEQ     PRINT_EA_ID_REG_L

PRINT_EA_ID_REG_B:  
    MOVE.B  #'#',(A1)+ 
    ADD.L  #1,A4
    MOVE.B  (A4)+,D1
    JSR     PUSH_EA_B
    RTS
    
PRINT_EA_ID_REG_W:   
    MOVE.B  #'#',(A1)+ 
    MOVE.W  (A4)+,D1
    JSR     PUSH_EA_W
    RTS
    
PRINT_EA_ID_REG_L:
    MOVE.B  #'#',(A1)+ 
    MOVE.L  (A4)+,D1
    JSR     PUSH_EA_L
    RTS
    
PRINT_EA_DRD
    MOVE.B  #'D',(A1)+
    RTS
    
PRINT_EA_ARD
    MOVE.B  #'A',(A1)+
    RTS
    
PRINT_EA_ARI
    MOVE.B #'(',(A1)+
    MOVE.B #'A',(A1)+
    RTS
    
PRINT_EA_ARIP
    MOVE.B #'(',(A1)+
    MOVE.B #'A',(A1)+
    RTS
    
PRINT_EA_ARIM
    MOVE.B #'-',(A1)+
    MOVE.B #'(',(A1)+
    MOVE.B #'A',(A1)+
    RTS
    
PUSH_EA_B
    MOVE.W  D1,D7
    LSR     #4,D7
    JSR HEX_TO_CHAR
    MOVE.B  D7,(A1)+
    MOVE.W  D1,D7
    LSL.L   #8,D7
    LSL.L   #8,D7
    LSL.L   #8,D7
    LSL.L   #4,D7
    LSR.L   #8,D7
    LSR.L   #8,D7
    LSR.L   #8,D7
    LSR.L   #4,D7
    JSR HEX_TO_CHAR
    MOVE.B  D7,(A1)+
    RTS 
    
PUSH_EA_W
    MOVE.W  D1,D7
    LSR.L   #8,D7
    LSR.L   #4,D7
    JSR HEX_TO_CHAR
    MOVE.B  D7,(A1)+
    MOVE.W  D1,D7
    LSL.L   #8,D7
    LSL.L   #8,D7
    LSL.L   #4,D7
    LSR.L   #8,D7
    LSR.L   #8,D7
    LSR.L   #8,D7
    LSR.L   #4,D7
    JSR HEX_TO_CHAR
    MOVE.B  D7,(A1)+
    MOVE.W  D1,D7
    LSL.L   #8,D7
    LSL.L   #8,D7
    LSL.L   #8,D7
    LSR.L   #8,D7
    LSR.L   #8,D7
    LSR.L   #8,D7
    LSR.L   #4,D7
    JSR HEX_TO_CHAR
    MOVE.B  D7,(A1)+
    MOVE.W  D1,D7
    LSL.L   #8,D7
    LSL.L   #8,D7
    LSL.L   #8,D7
    LSL.L   #4,D7
    LSR.L   #8,D7
    LSR.L   #8,D7
    LSR.L   #8,D7
    LSR.L   #4,D7
    JSR HEX_TO_CHAR
    MOVE.B  D7,(A1)+
    RTS

PUSH_EA_L
    MOVE.L  D1,D7
    LSR.L   #8,D7
    LSR.L   #8,D7
    LSR.L   #8,D7
    LSR.L   #4,D7
    JSR     HEX_TO_CHAR
    MOVE.B  D7,(A1)+
    MOVE.L  D1,D7
    LSL.L   #4,D7
    LSR.L   #8,D7
    LSR.L   #8,D7
    LSR.L   #8,D7
    LSR.L   #4,D7
    JSR     HEX_TO_CHAR
    MOVE.B  D7,(A1)+
    MOVE.L  D1,D7
    LSL.L   #8,D7
    LSR.L   #8,D7
    LSR.L   #8,D7
    LSR.L   #8,D7
    LSR.L   #4,D7
    JSR     HEX_TO_CHAR
    MOVE.B  D7,(A1)+
    MOVE.L  D1,D7
    LSL.L   #8,D7
    LSL.L   #4,D7
    LSR.L   #8,D7
    LSR.L   #8,D7
    LSR.L   #8,D7
    LSR.L   #4,D7
    JSR     HEX_TO_CHAR
    MOVE.B  D7,(A1)+
    JMP PUSH_EA_W



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
