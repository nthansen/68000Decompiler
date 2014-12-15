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
MAX     EQU 25
END     EQU $00FFFFFE   
    
    ORG    $1000
START:                  ; first instruction of program
        LEA     STACK,SP            *Get the stak pointer
        MOVE.B  #0,LINE_COUNTER     *Line counter for displaying part of output
        LEA     START_MSG,A1
        MOVE.B  #14,D0
        TRAP    #15
        JSR     GET_START_ADDR
        JSR     CLEAR_ALL
        
        RTS
        
            
*/////////////////////SUBROUTINES/////////////////////////
DATA_LOOP
        CMP.L   A4,A5
        BEQ     DONE
        MOVE.W  (A4)+,D3 
        JSR     PRINT_CURRENT_ADDR
        ADD.B   #1,LINE_COUNTER
        CMP.B   #MAX,LINE_COUNTER
        BEQ     ASK_ENTER    
        BRA     DATA_LOOP  

ASK_ENTER
        MOVE.B  #0,LINE_COUNTER
        LEA     ENTER, A1
        MOVE.B  #14,D0
        TRAP    #15
        LEA     STUFF,A1
        MOVE.B  #2,D0
        TRAP    #15
        BRA     DATA_LOOP

PRINT           
        MOVE.B  #$00,(A1)                 * Terminate the string
        CLR.L   D0                        * Clear D0   
        MOVE.B  #13,D0                    * Load task number 14 for printing
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
        BRA     PRINT
        RTS

HEX_TO_CHAR                                                                                                   
        CMP.B   #$9,D7           *Check if digit                            
        BLE     DIG_TO_ASCII     *Convert digit                 
        BRA     LET_TO_ASCII     *Convert letter
                                                                                                    
DIG_TO_ASCII                                                                                               
        ADDI.B  #$30,D7          *Converting a digit to ASCII                                                                  
        RTS
                                                                                                              
LET_TO_ASCII                                                                                            
        ADDI.B  #$37,D7          *Converting a letter to ASCII                                                         
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
        
DONE
    LEA     END_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
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
ENTER               DC.B    CR,LF
                    DC.B    'Please press Enter to continue',CR,LF,0
START_MSG           DC.B    'This is the disassember made by Group 10 (Norman Hansen, Konstantin Stekhov)',CR,LF
                    DC.B    'Input the starting and ending addresses and the program will run your data',CR,LF
                    DC.B    'The starting and ending addresses must be between 7000 and FFFFFE',CR,LF
                    DC.B    CR,LF,0                  
END_MSG             DC.B    CR,LF
                    DC.B    'This is the end of our program',CR,LF
                    DC.B    ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;',CR,LF
                    DC.B    ';;;;;;;;;;;;;     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;',CR,LF
                    DC.B    ';;;;;;;;;;;;  ;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;',CR,LF
                    DC.B    ';;;;;;;;;;;  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;',CR,LF
                    DC.B    ';;;;;;;;;;;  ;;;;;;;;;;        ;;;;      ;;;;;;;;;  ;;;;;;     ;;;;;;;;;;;;;;;;',CR,LF
                    DC.B    ';;;;;;;;;;;; ;;;;;;;;;  ;  ;;;  ;;  ;;;  ;;;;;;;  ;; ;;;;  ;;;  ;;;;;;;;;;;;;;;',CR,LF
                    DC.B    ';;;;;;;;;;;  ;;;;;;;;;  ;;         ;;;;  ;;;;;;;  ;;;  ;;  ;;;  ;;;;;;;;;;;;;;;',CR,LF
                    DC.B    ';;;;;;;;         ;;;;;  ;;;;;  ;;;;;;;;;  ;;;;;  ;;;;;         ;;;;;;;;;;;;;;;;',CR,LF
                    DC.B    ';;;;;;;  ;;  ;;  ;;; ;;  ;;;;  ;;;;;;;;;;  ;;;  ;;;;;;;;;  ;;;;;;;;;;;;;;;;;;;;',CR,LF
                    DC.B    ';;;;;;;;     ;;;     ;;;       ;;;;;;;;;;;     ;;;;;;;;;;;       ;;;;;;;;;;;;;;',CR,LF
                    DC.B    ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;',CR,LF
                    DC.B    ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;',CR,LF
                    DC.B    ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   ;;;;;;;;;;;;;;;;',CR,LF
                    DC.B    ';;;;;;;;;;;;    ;;;;;;    ;;;     ;;;;;   ;;;;;;;;   ;;;;;;    ;;;;;;;;;;;;;;;;',CR,LF
                    DC.B    ';;;;;;;;;;;;;;  ;;;;;    ;;;  ;;    ;; ;;;  ;;;;;;  ;;;;;;;   ;;;;;;;;;;;;;;;;;',CR,LF
                    DC.B    ';;;;;;;;;;;;;;  ;;;;;  ; ;;;    ;; ;  ;;;;;  ;;;;;  ;;;;;;   ;;;;;;;;;;;;;;;;;;',CR,LF
                    DC.B    ';;;;;;;;;;;;;;  ;;;;  ;; ;; ; ;;;; ;;;;;;;;  ;;;; ; ;; ;;;  ;;;;;;;;;;;;;;;;;;;',CR,LF
                    DC.B    ';;;;;;;;;;;;;;;     ;;;    ;;     ;;;;;;;;;;      ;;   ;;;;;;;;;;;;;;;;;;;;;;;;',CR,LF
                    DC.B    ';;;;;;;;;;;;;;;;;;;;;    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  ;;;;;;;;;;;;;;;;;;;',CR,LF
                    DC.B    ';;;;;;;;;;;;;;;         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;',CR,LF
                    DC.B    ';;;;;;;;;;;;;;  ;;;;;;  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;',CR,LF
                    DC.B    ';;;;;;;;;;;;;;         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;',CR,LF
                    DC.B    ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;',CR,LF,0

START_ADDR          DS.B    80
END_ADDR            DS.B    80
BUFFER              DS.B    80
LINE_COUNTER        DS.B    1
STUFF               DS.B    1
                     
    END    START        ; last line of source
   














*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
