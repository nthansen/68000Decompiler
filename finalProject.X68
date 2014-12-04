*---------------------------------------------------------
* Title      :  Final Project
* Written by :  Brad Minogoue, Konstantin Stekhov, Norman Hansen 
* Date       :  11/6/14
* Description:  
*-----------------------------------------------------------
    ORG    $1000
*FOR ADDA, MIGHT NOT BE THE SAME FOR ALL
* MODE

MDn      EQU     %000    * Dn
MAn      EQU     %001    * An
MAnP     EQU     %010    * (An)
MAnPlus  EQU     %011    * (An)+
MAnMin   EQU     %100    * -(An)
MxxxW    EQU     %111    * (xxx).W
MxxxL    EQU     %111    * (xxx).L
MdAdd    EQU     %111    * #<data>

* REGISTER

RxxxW    EQU     %000    * (xxx).W
RxxxL    EQU     %001    * (xxx).L
RdAdd    EQU     %100    * #<data>

START:                  ; first instruction of program

* Put program code here

GETREG:
    MOVE.L D2,D1                ; this is for detecting the register starts as 1001 0001 WANT 001
    LSL #8,D1                   ; Remove starting address
    LSL #5,D1                   ; Remove offset so then it's 0010 0010
    LSR #8,D1                   ; Put back into place
    LSR #5,D1                   ; Remove excess so now it's 0001
  
PRINT_EA_DRD
    LEA DRD_TEXT,A1
    MOVE.B #14,D0
    TRAP #15

PRINT_EA_ARD
    LEA ARD_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    
PRINT_EA_ARI
    LEA ARI_TEXT,A1
    MOVE.B  #14,D0
    TRAP #15
    
PRINT_EA_ARIP
    LEA ARIP_TEXT,A1
    MOVE.B  #14,D0
    TRAP #15
    
PRINT_EA_ARIM
    LEA ARIM_TEXT,A1
    MOVE.B  #14,D0
    TRAP #15
    
PRINT_EA_ID
    LEA ID_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    
PRINT_EA_ALA
    LEA ALA_TEXT,A1
    MOVE.B #14,D0
    TRAP #15

PRINT_EA_AWA
    LEA AWA_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    
    SIMHALT             ; halt simulator

* Put variables and constants here
EA_TEXT DC.B ' EA',0
DRD_TEXT DC.B ' Dn ', 0
ARD_TEXT DC.B ' An ',0
ARI_TEXT DC.B ' (An)',0
ARIP_TEXT DC.B ' (An)+ ',0
ARIM_TEXT DC.B ' -(SP) ',0
ID_TEXT DC.B ' # ',0
ALA_TEXT DC.B ' (xxxx).W',0
AWA_TEXT DC.B ' (xxxx).L',0


    END    START        ; last line of source






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
