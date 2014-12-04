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
Md16An   EQU     %101    * (d16,An)
Md8AnXn  EQU     %110    * (d8,An,Xn)
MxxxW    EQU     %111    * (xxx).W
MxxxL    EQU     %111    * (xxx).L
MdAdd    EQU     %111    * #<data>
Md16PC   EQU     %111    * (d16,PC)
Md8PCXn  EQU     %111    * (d8,PC,Xn)

* REGISTER

RxxxW    EQU     %000    * (xxx).W
RxxxL    EQU     %001    * (xxx).L
RdAdd    EQU     %100    * #<data>
Rd16PC   EQU     %010    * (d16,PC)
Rd8PCXn  EQU     %011    * (d8,PC,Xn)

START:                  ; first instruction of program

* Put program code here

GETREG:
    MOVE.L D2,D1                ; this is for detecting the register starts as 1001 0001 WANT 001
    LSL #8,D1                   ; Remove starting address
    LSL #5,D1                   ; Remove offset so then it's 0010 0010
    LSR #8,D1                   ; Put back into place
    LSR #5,D1                   ; Remove excess so now it's 0001
  
EA_AnP
    LEA AnP_TEXT,A1
    MOVE.B #14,D0
    TRAP #15

EA_D16An
    LEA D16An_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    
EA_D8AnXn
    LEA D8AnXn_TEXT,A1
    MOVE.B  #14,D0
    TRAP #15
    
EA_XXXXW
    LEA xxxxW_TEXT,A1
    MOVE.B  #14,D0
    TRAP #15
    
EA_XXXXL
    LEA xxxxL_TEXT,A1
    MOVE.B  #14,D0
    TRAP #15
    
EA_D16PC
    LEA D16PC_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    
EA_D8PCXn_TEXT
    LEA D8PCXn_TEXT,A1
    MOVE.B #14,D0
    TRAP #15

    
    SIMHALT             ; halt simulator

* Put variables and constants here
EA_TEXT DC.B ' EA',0
AnP_TEXT DC.B ' (An)',0
D16An_TEXT DC.B ' (d16,An)',0
D8AnXn_TEXT DC.B ' (d8,An,Xn)',0
xxxxW_TEXT DC.B ' (xxxx).W',0
xxxxL_TEXT DC.B ' (xxxx).L',0
D16PC_TEXT DC.B ' (d16,PC)',0
D8PCXn_TEXT DC.B ' (d8,PC,Xn)',0


    END    START        ; last line of source





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
