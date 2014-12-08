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

ADD       EQU     %0011010000000011 * 00 SIZE 11 DEST REG 010 DEST MODE 000 SOURCE MODE 000 SOURCE REG 011

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
    
    
GETDESTINATIONMODE:
    MOVE.L D3,D1                ; this is for detecting the mode
    LSL #7,D1                   ; Remove starting address
    LSR #8,D1                   ; Put back into place
    LSR #5,D1                   ; Remove excess so now it's 000
    MOVE.B D1,D6
    LEA RETURNDESTMODE,A0
    JMP DISPLAYMODE

RETURNDESTMODE:
    LEA GETSOURCEMODE,A0
    JMP DISPLAYREG
        

DISPLAYMODE:
    CMP.B #MDRD,D6
    BEQ PRINT_EA_DRD
    CMP.B #MARD,D6
    BEQ PRINT_EA_ARD
    CMP.B #MARI,D6
    BEQ PRINT_EA_ARI
    CMP.B #MARIP,D6
    BEQ PRINT_EA_ARIP
    CMP.B #MARIM,D6
    BEQ PRINT_EA_ARIM
    CMP.B #MAWA,D6
    BEQ PRINT_EA_AWA
    CMP.B #MALA,D6
    BEQ PRINT_EA_ALA
    CMP.B #MID,D6
    BEQ PRINT_EA_ID

DISPLAYREG:
    CMP.B   #MDRD,D6                ; If the mode is a Dn then we just print the value in the register
    BEQ     DISPLAYREGVALUE
    CMP.B   #MARD,D6                ; If the mode is a An then we just print the value in the register
    BEQ     DISPLAYREGVALUE
    CMP.B   #MARI,D6                ; If the mode is a (An) we need to print the reg value and )
    BEQ     PRINT_EA_ARI
    CMP.B   #MARIP,D6               ; If the mode is a (An)+ we need to print the reg value and )+
    BEQ     PRINT_EA_ARIP           
    CMP.B   #MARIM,D6               ; If the mode is a -(SP) we need to print the reg value and )
    BEQ     PRINT_EA_ARIM
    CMP.B   #RAWA,D7                ; The reg is a .w so we need to print the address and ).W
    BEQ     PRINTREGW
    CMP.B   #RALA,D7                ; The reg is a .l so we need to print the address and ).L
    BEQ     PRINTREGL
    

DISPLAYREGVALUE:
    MOVE.B D7,D1
    MOVE.B #10,D2
    MOVE.B #15,D0
    TRAP #15
    JMP (A0)

GETSOURCEMODE:    
    MOVE.L D3,D1                ; this is for detecting the mode starts as 1001 0001 WANT 010
    LSL #8,D1                   ; Remove starting address
    LSL #1,D1                   ; Remove offset so then it's 0010 0010
    LSR #8,D1                   ; Put back into place
    LSR #4,D1                   ; Remove register so now it's 0010
    MOVE.B D1,D6
    LEA GETSOURCEREG,A0
    JMP DISPLAYMODE
    
GETSOURCEREG:
    MOVE.L D3,D1                ; this is for detecting the register starts as 1001 0001 WANT 001
    LSL #8,D1                   ; Remove starting address
    LSL #5,D1                   ; Remove offset so then it's 0010 0010
    LSR #8,D1                   ; Put back into place
    LSR #5,D1                   ; Remove excess so now it's 0001
    MOVE.B D1,D7
    LEA MAIN,A0
    JMP DISPLAYREG
    
PRINTREGW:
    MOVE.W  (A5)+,D1
    MOVE.B  #15,D0
    MOVE.B  #16,D2
    TRAP    #15    

PRINTREGL
    MOVE.L  (A5)+,D1
    MOVE.B  #15,D0
    MOVE.B  #16,D2
    TRAP    #15 
    
PRINT_EA_DRD
    LEA DRD_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    JMP (A0)
    
PRINT_EA_ARD
    LEA ARD_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    BRA DISPLAYREGVALUE
    
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
ARIP_TEXT DC.B ' (A ',0
ARIM_TEXT DC.B ' -(A ',0
ID_TEXT DC.B ' #',0
ARIEND_TEXT DC.B ') ',0
ARIPEND_TEXT DC.B ')+ ',0
ALA_TEXT DC.B ' (',0
AWA_TEXT DC.B ' (',0


    END    START        ; last line of source











*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
