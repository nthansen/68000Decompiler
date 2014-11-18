*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
CR  EQU $0D
LF  EQU $0A    
    
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
    
    *Ask for the input message
LOOP    LEA     INPUT_MSG_START,A1
        MOVE.B  #14,D0
        TRAP    #15
        
        *Get the starting address
        MOVE.B  #4,D0
        TRAP    #15
        
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
        MOVE.L  D1,D3               *Starting address in D3
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
        MOVE.L  D1,D4               *Ending address in D4
        CMP.L   D3,D4               *Compare D3 and D4 if D3 is greater or
        BGE     DISPLAY_ERR         *equal then throw an error   
        BRA     LOOP
        
DONE
        MOVE.B  #9,D0
        TRAP    #15                 ; halt simulator

* Put variables and constants here
NEG_ADDR            DC.B    'Address must be positive',CR,LF,0
INPUT_MSG_START     DC.B    'Please type the starting address: ',CR,LF,0
INPUT_MSG_END       DC.B    'Please type the ending address: ',CR,LF,0
NOT_VALID_ERR       DC.B    'Starting address is larger or equal to ending address',CR,LF,0

    END    START        ; last line of source
   

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
