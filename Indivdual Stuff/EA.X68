*---------------------------------------------------------
* Title      :  Final Project
* Written by :  Brad Minogoue, Konstantin Stekhov, Norman Hansen 
* Date       :  11/6/14
* Description:  
*-----------------------------------------------------------
    ORG    $1000
*FOR ADDA, MIGHT NOT BE THE SAME FOR ALL
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

ADD       EQU     %0011001111000011 * 00 SIZE 11 DEST REG 010 DEST MODE 001 SOURCE MODE 100 SOURCE REG 011

START:                  ; first instruction of program

* Put program code here
    
MAIN:
    MOVE.L #ADD,D3

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
    LEA GETSOURCEMODE,A0
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
                                    ; STILL NEED ONE FOR #

PRINT_EA_REG_VALUE:
    MOVE.B D7,D1                    ; Move the reg value to the spot to print
    MOVE.B #16,D2                   ; Make sure it's in base 16
    MOVE.B #15,D0                   ; Necessary to print values
    TRAP #15                        ; Print
    JMP (A0)                        ; Jump back to location

PRINT_EA_ARI_REG:
   MOVE.L A0,A2
   LEA PRINT_EA_ARI_REG_END,A0          ; Load the display end part of ARI to address to jump to later
   JMP PRINT_EA_REG_VALUE              ; Display the register value
   
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


PRINT_EA_ALA_REG
    MOVE.L  (A5)+,D1
    MOVE.B  #15,D0
    MOVE.B  #16,D2
    TRAP    #15 
    LEA     ALA_END_TEXT,A1
    MOVE.B  #14,D0
    TRAP    #15
    JMP     (A0)
        

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
    LEA MAIN,A0                 ; Once finished jump to main
    JMP PRINT_EA_REG
    
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
    
    SIMHALT             ; halt simulator

* Put variables and constants here
EA_TEXT DC.B ' EA',0
DRD_TEXT DC.B ' D', 0
ARD_TEXT DC.B ' A',0
ARI_TEXT DC.B ' (A',0
ARIP_TEXT DC.B ' (A',0
ARIM_TEXT DC.B ' -(A',0
ID_TEXT DC.B ' #',0
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
