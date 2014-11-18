*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000

*Starting info for each type
RTS     EQU     %0100111001110101  * Full function
BRA     EQU     %01100000          * Has 8 bit displacement
JSR     EQU     %0100111010        * 6 bit displacement?
BCC     EQU     %0110              * 4 bit condition, then 8 bit displacement
ORI     EQU     %00000000          * 2 bit size then EA Mode, Register
OR      EQU     %1000              * 3 bit register, 3 bit opmode, EA mode, EA Register 
NEG     EQU     %01000100          * 2 bit size, EA Mode, EA Register
ROLROR  EQU     $1110011           * 1 bit dr, 11, EA Mode, EA register
BCLR    EQU     %0000              * 3 bit register, 110, EA Mode, EA register
ASLASR  EQU     %1110000           * 1 bit dr, 11, EA Mode, EA Register
LSLLSR  EQU     %1110001           * 1 bit dr, 11, EA Mode, EA Register
LEA     EQU     %0100              * 3 bit register, 111, EA Mode, EA Register
MOVE    EQU     %00                * 2 bit size, DEST Register, DEST Mode, SOURCE Mode, Source Register

START:                  ; first instruction of program

* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
