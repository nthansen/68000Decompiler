*---------------------------------------------------------
* Title      :  EA
* Written by :  Norman Hansen 
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
    
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
