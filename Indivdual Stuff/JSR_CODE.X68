*-----------------------------------------------------------
* Title      : JSR CODE
* Written by : Brad Minogue/Norman Hansen
* Date       : 11/19/2014
* Description: JSR Code for OP/EA
*-----------------------------------------------------------
MAnP     EQU     $2    ;%010    * (An)
Md16An   EQU     $5    ;%101    * (d16,An)
Md8AnXn  EQU     $6    ;%110    * (d8,An,Xn)
MxxxW    EQU     $7    ;%111    * (xxx).W
MxxxL    EQU     $7    ;%111    * (xxx).L
Md16PC   EQU     $7    ;%111    * (d16,PC)
Md8PCXn  EQU     $7    ;%111    * (d8,PC,Xn)

    ORG    $1000
START: 
    MOVE.L (SAMPLE_INPUT),D2    ;Load up sample input, 4E91 so EA 010 001 or do 
    MOVE.L D2,D1                ;copy the data so we don't ruin it
    LSR #6,D1                   ;erase the EA
    CMP.L JSR_VALUE, D1         ;see if we are JSR
    BNE END_SEG                 ;if not end this segment
    
    LEA JSR_TEXT,A1             ;print out JSR
    MOVE.B #14, D0
    TRAP #15
    
    LEA EA_TEXT,A1              ;this is where we hand off to EA
    MOVE.B #14,D0
    TRAP #15   
    
GETEA:    
    MOVE.L D2,D1                ; this is for detecting the mode starts as 1001 0001 WANT 010
    LSL #8,D1                   ; Remove starting address
    LSL #1,D1                   ; Remove offset so then it's 0010 0010
    LSR #8,D1                   ; Put back into place
    LSR #4,D1                   ; Remove register so now it's 0010
    CMP.B #MAnP,D1
    BEQ EA_AnP
    
GETREG:
    MOVE.L D2,D1                ; this is for detecting the register starts as 1001 0001 WANT 001
    LSL #8,D1                   ; Remove starting address
    LSL #5,D1                   ; Remove offset so then it's 0010 0010
    LSR #8,D1                   ; Put back into place
    LSR #5,D1                   ; Remove excess so now it's 0001
    BRA END_SEG
  
EA_AnP
    LEA AnP_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    BRA GETREG

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

    
END_SEG    SIMHALT             ; halt simulator

SAMPLE_INPUT DC.L $4E91
JSR_VALUE DC.L $13A
JSR_TEXT DC.B 'JSR',0
EA_TEXT DC.B ' EA',0
AnP_TEXT DC.B ' (An)',0
D16An_TEXT DC.B ' (d16,An)',0
D8AnXn_TEXT DC.B ' (d8,An,Xn)',0
xxxxW_TEXT DC.B ' (xxxx).W',0
xxxxL_TEXT DC.B ' (xxxx).L',0
D16PC_TEXT DC.B ' (d16,PC)',0
D8PCXn_TEXT DC.B ' (d8,PC,Xn)',0

MAnP     EQU     %010    * (An)
Md16An   EQU     %101    * (d16,An)
Md8AnXn  EQU     %110    * (d8,An,Xn)
MxxxW    EQU     %111    * (xxx).W
MxxxL    EQU     %111    * (xxx).L
Md16PC   EQU     %111    * (d16,PC)
Md8PCXn  EQU     %111    * (d8,PC,Xn)

    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
