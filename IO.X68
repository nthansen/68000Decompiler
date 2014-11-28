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
    
    
    ORG    $1000
START:                  ; first instruction of program
        LEA     STACK, SP  *Get the stak pointer

    
    *Ask for the input message
LOOP    
        
        *Get the starting address
        
        
        CMP.L   #-1,D1  *If -1 then exit
        BEQ     DONE    
        
        CMP.L   #0,D1
        BLE     DISPLAY_NEG_ERR
        BGE     GET_END_ADDR
        
*Display the one end address is smaller than start address error    
DISPLAY_ERR 
        LEA     NOT_VALID_ERR,A1
        MOVE.B  #14,D0
        TRAP    #15 
        BRA     LOOP        

DISPLAY_NEG_ERR
        LEA     NEG_ADDR,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     LOOP    

DISPLAY_NEG_END_ERR
        LEA     NEG_ADDR,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     GET_END_ADDR

GET_END_ADDR
        MOVE.L  D1,A2               *Starting address in A2
        *Ask for the input message
        LEA     INPUT_MSG_END,A1
        MOVE.B  #14,D0
        TRAP    #15
    
        *Get the ending address
        MOVE.B  #4,D0
        TRAP    #15
        
        CMP.L   #-1,D1  *If -1 then exit
        BEQ     DONE 
        
        CMP.L   #0,D1
        BLE     DISPLAY_NEG_END_ERR
        BGE     COMPARE_FUNC

COMPARE_FUNC
        MOVE.L  D1,A3               *Ending address in A3
        CMP.L   A3,A2               *Compare D3 and D4 if D3 is greater or
        BGE     DISPLAY_ERR         *equal then throw an error   
        BLE     DATA_LOOP
        BRA     LOOP

DATA_LOOP
        ADD.L  #BYTE,A2
        CMP.L   A2,A3
        BEQ     DONE
        BRA     DATA_LOOP
        
DONE
        MOVE.B  #9,D0
        TRAP    #15                 ; halt simulator
        
*/////////////////////SUBROUTINES
CONVERT_ONE_CHAR_TO_HEX
        MOVE.B  (A1)+, D2   *Get character in D2
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
        ASL.L   #4, D3
        ADD.B   D2, D3      *Move the result into D3
        BRA     CONVERT_ONE_CHAR_TO_HEX *Go to the next one

UPPER_HEX
        SUBI.B  #55,D2      *Get hex value
         
STRING_END
        RTS        

VALIDATE
        MOVEQ   #$0,D3
        CMP.B   D3,D1
        BLE     DISPLAY_NEG_ERR
        CMPI    #$8,D1
        BGT     WRONG_INPUT
        
GET_START_ADDR
        LEA     INPUT_MSG_START,A1
        MOVE.B  #14,D0
        TRAP    #15
        
        LEA     START_ADDR,A1
        MOVE.B  #4,D0           *The starting address input in D1
        TRAP    #15

        JSR     VALIDATE              

CHECK_IF_EVEN
        CLR.L   D2              *Clear old value in D2
        MOVE.L  #$00000002,D1   *Put 2 in D1
        MOVE.L  D3,D2
        DIVU    D1,D2           *Divide
        SWAP    D2
        CMP.B   #$01,D2         *If there is a remainder then display error
        BEQ     ODD_INPUT

CONVERT_HEX_TO_ASCII
        ANDI.L  #$000000FF,D1
        CMP.B   #4,D1             *If size is greater than 4
        BGT     DISPLAY_BYTE_ERR  *then display incorrect byte size error
        CMP.B   #0,D1             *If size is less or equal to 0
        BLE     DISPLAY_BYTE_ERR  *do the same
        
WRONG_INPUT
        LEA     INPUT_ERR,A1
        MOVE.B  #14,D0
        TRAP    #15

ODD_INPUT
        LEA     ODD_ERR,A1
        MOVE.B  #14,D0
        TRAP    #15

DISPLAY_BYTE_ERR
        LEA     BYTE_ERR,A1
        MOVE    #14,D0
        TRAP    #15

* Put variables and constants here
NEG_ADDR            DC.B    'Address must be positive',CR,LF,0
INPUT_ERR           DC.B    'The input is wrong',CR,LF,0
INPUT_MSG_START     DC.B    'Please type the starting address: ',CR,LF,0
INPUT_MSG_END       DC.B    'Please type the ending address: ',CR,LF,0
NOT_VALID_ERR       DC.B    'Starting address is larger or equal to ending address',CR,LF,0
BYTE_ERR            DC.B    'Incorrect byte size',CR,LF,0
START_ADDR          DS.B    80
END_ADDR            DS.B    80
    
    END    START        ; last line of source
   





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
