*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
CR      EQU $0D
LF      EQU $0A  
STACK   EQU $7000               * Stack address

    ORG    $1000
START:                  ; first instruction of program

    LEA STACK, SP           *Get the stak pointer
    LEA $8000,A5

    *MOVEA.W (A1),A6
    * ADD.L   A6,D1
    
    
    LEA $4000,A4
    JMP TEST
    

TEST:
    CLR.L      D1
    MOVE.W  (A4)+,D3
    JSR DECODE_OPCODE
    BRA TEST
    
PRINT           
        MOVE.B  #$00,(A1)                 * Terminate the string
        CLR.L   D0                        * Clear D0   
        MOVE.B  #14,D0                    * Load task number 14 for printing
        LEA     buffer,A1                 * Load the buffer into A1 
        TRAP    #15                       * Print the buffer              
        RTS
    
*////////////////////////////////////////////////////////////////////////////////////////
* OPCODE!!!
*////////////////////////////////////////////////////////////////////////////////////////

; not sure if these should compare to d7 or d3
HEX_TO_CHAR                                                                                                   
        CMP.B   #$9,D7                    *Check if digit                            
        BLE     DIG_TO_ASCII              *Convert digit                 
        BRA     LET_TO_ASCII              *Convert letter
                                                                                                    
DIG_TO_ASCII                                                                                               
        ADDI.B  #$30,D7                                                                  
        RTS
                                                                                                              
LET_TO_ASCII                                                                                            
        ADDI.B  #$37,D7                                                                   
        RTS
        
SETUP_VALUES:
    MOVE.W      D3,D1                   * For first four values
    LSR.L       #8,D1                       *Shift 12 bits to the right 
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
   
DECODE_5    * SUBQ

    BRA     data_error
        
DECODE_6    * Bcc, BRA
	
    BRA     data_error
        
          
DECODE_8    * DIVS,OR
    BRA     data_error
    
DECODE_9    * SUB
    
    BRA     data_error

DECODE_B    * EOR,CMP
    BRA     data_error


DECODE_C    * MULS
    BRA     data_error


DECODE_D    * ADD, ADDA
    
    BRA     data_error

DECODE_E    * LSL, LSR, ASL, ASR, ROL, ROR
    
    BRA     data_error
	
CHECK_LEA_OR_MOVEM
    MOVE.W  D3,D1
    LSL     #4,D1
    LSR     #8,D1
    LSR     #5,D1
    
    CMP.B   #%111,D1
    BEQ     DECODE_LEA
    
    BRA     data_error
    
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

 * Expects byte to be 00 Word 01 Long 10 in D1
GET_SIZE 
    CMP.B   #%00,D1
    BEQ     GET_BYTE
    CMP.B   #%01,D1
    BEQ     GET_WORD
    CMP.B   #%10,D1
    BEQ     GET_LONG
    
    RTS
    
    
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
    CMP.B   #MARIM,D6               ; If the mode is a -(SP) we need to print the reg value and )
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
    MOVE.B  #')',(A1)+
    MOVE.B  #'+',(A1)+
    RTS   
   
PRINT_EA_ARI_REG_END:
    MOVE.B  #')',(A1)+
    RTS
    
PRINT_EA_ARIP_REG_END:
    LEA ARIP_END_TEXT,A1
    MOVE.B  #14,D0
    TRAP #15
    RTS
    
PRINT_EA_AWA_REG:
    MOVE.B  #'(',(A1)+
    MOVE.W  (A4)+,D1
    JSR     PUSH_EA_W
    MOVE.B  #')',(A1)+
    MOVE.B  #'.',(A1)+
    MOVE.B  #'W',(A1)+
    MOVE.B  #' ',(A1)+

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
