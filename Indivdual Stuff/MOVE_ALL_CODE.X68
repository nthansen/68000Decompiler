*-----------------------------------------------------------
* Title      :  MOVE Decompile Code
* Written by :  Brad Minogue
* Date       :  12/6/14
* Description:  Decompiles all MOVE, MOVEA, MOVEM
*-----------------------------------------------------------
    ORG    $1000
START:

    MOVE.L (SAMPLE_INPUT),D2
    ;see if we are MOVEM
    MOVE.L D2,D1
    AND.L (MOVEM_VALUE),D1
    CMP.L MOVEM_VALUE,D1
    BEQ MOVEM_SEG
    ;see if we are MOVE FROM CCR
    MOVE.L D2,D1
    AND.L (MOVE_FROM_CCR_VALUE),D1
    CMP.L MOVE_FROM_CCR_VALUE,D1
    BEQ MOVE_FROM_CCR_SEG
    ;see if are move to ccr
    MOVE.L D2,D1
    AND.L (MOVE_TO_CCR_VALUE),D1
    CMP.L MOVE_TO_CCR_VALUE,D1
    BEQ MOVE_TO_CCR_SEG
    ;see if are move from sr
    MOVE.L D2,D1
    AND.L (MOVE_FROM_SR_VALUE),D1
    CMP.L MOVE_FROM_SR_VALUE,D1
    BEQ MOVE_F_SR_SEG
    ;see if we are movea    
    MOVE.L D2,D1
    AND.L (MOVEA_VALUE),D1
    CMP.L MOVEA_VALUE,D1
    BEQ MOVEA_SEG
    ;see if we are a move
    MOVE.L D2,D1
    CMP.L MOVE_MIN_VALUE,D1
    BGE MOVE_SEG            ;BGE is used as all moves must be
    BRA END_SEG             ;more than a set value, see size starts at 1
MOVE_FROM_CCR_SEG
    ;Start off by print out move
    LEA MOVE_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    MOVE.L D2,D1
    ;print out ccr
    LEA CCR_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    ;now for a comma
    LEA COMMA_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    ;now we hand of to ea
    LEA EA_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    BRA END_SEG
MOVE_TO_CCR_SEG
    ;print out move
    LEA MOVE_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    ;hand off to ea
    MOVE.L D2,D1
    LEA EA_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    ;print out ,
    LEA COMMA_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    ;print out ccr
    LEA CCR_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    BRA END_SEG
MOVEA_SEG
    ;print out move
    LEA MOVE_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    ;print out A
    LEA A_REG_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    ;find out what size we are
    MOVE.L D2,D1
    LSL #2,D1
    LSR #2,D1
    LSR #4,D1
    LSR #8,D1
    BRA MOVEA_LONG_SEG
MOVEA_LONG_SEG
    ;print out L
    CMP.L #2,D1
    BNE MOVEA_WORD_SEG
    LEA LONG_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    BRA MOVEA_REST_SEG
MOVEA_WORD_SEG
    ;print out W
    LEA WORD_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    BRA MOVEA_REST_SEG
MOVEA_REST_SEG
    ;hand off to EA
    LEA EA_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    ;print out ,
    LEA COMMA_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    ;print out A
    LEA A_REG_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    ;find out what reg we are in
    MOVE.L D2,D1
    LSL #4,D1
    LSR #5,D1
    LSR #8,D1 ;then print it out
    MOVE.B #3,D0
    TRAP #15
    BRA END_SEG
MOVEM_SEG 
    ;print out MOVEM
    LEA MOVEM_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    ;find what size w eare
    MOVE.L D2,D1
    LSL #8,D1
    LSL #1,D1
    LSR #8,D1
    LSR #7,D1
    BRA MOVEM_LONG_SEG
MOVEM_LONG_SEG  ;see if we are a long if so print
    CMP.L #1,D1
    BNE MOVEA_WORD_SEG
    LEA LONG_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    BRA MOVEM_REST_SEG
MOVEM_WORD_SEG  ;print out W
    LEA WORD_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    BRA MOVEM_REST_SEG
MOVEM_REST_SEG  ;find which direction we are going
    MOVE.L D2,D1
    LSL #5,D1
    LSR #5,D1
    LSR #8,D1
    LSR #2,D1
    CMP.L #0,D1
    BNE REG_TO_MEM 
    LEA EA_TEXT, A1 ;hand off to ea
    MOVE.B #14,D0
    TRAP #15
    LEA COMMA_TEXT, A1 ;print out ,
    MOVE.B #14,D0
    TRAP #15
    LEA LIST_TEXT, A1   ;print out the LIST
    MOVE.B #14,D0
    TRAP #15    
    BRA END_SEG
REG_TO_MEM
    LEA LIST_TEXT, A1   ;print out list
    MOVE.B #14,D0
    TRAP #15
    LEA COMMA_TEXT, A1  ;print out ,
    MOVE.B #14,D0
    TRAP #15
    LEA EA_TEXT, A1     ;hand off to ea
    MOVE.B #14,D0
    TRAP #15    
    BRA END_SEG

MOVE_SEG ;this seg decodes a normal move
    LEA MOVE_TEXT,A1    ;pritn out move
    MOVE.B #14,D0
    TRAP #15
    MOVE.L D2,D1    ;restore data
    LSL #2,D1       ;find the size
    LSR #2,D1
    LSR #8,D1
    LSR #4,D1
    CMP.L #1,D1
    BNE MOVE_LONG_SEG   ;if we are a byte print it out
    LEA BYTE_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    BRA MOVE_REST_SEG
MOVE_LONG_SEG               ;if we are a long print ito ut
    CMP.L #2,D1
    BNE MOVE_WORD_SEG
    LEA LONG_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    BRA MOVE_REST_SEG
MOVE_WORD_SEG           ;if we are a word print it
    LEA WORD_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    BRA MOVE_REST_SEG
MOVE_REST_SEG           ;hand off to ea here
    LEA EA_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    LEA COMMA_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    LEA EA_TEXT,A1
    MOVE.B #14,D0
    TRAP #15
    BRA END_SEG
MOVE_F_SR_SEG       
    LEA MOVE_TEXT,A1    ;print out move
    MOVE.B #14,D0
    TRAP #15
    MOVE.L D2,D1
    LEA SR_TEXT,A1      ;print out sr
    MOVE.B #14,D0
    TRAP #15
    LEA COMMA_TEXT,A1   ;print out comma
    MOVE.B #14,D0
    TRAP #15
    LEA EA_TEXT,A1      ;hand off to ea
    MOVE.B #14,D0
    TRAP #15
    BRA END_SEG
END_SEG    SIMHALT
SAMPLE_INPUT DC.L $48F9
CCR_TEXT DC.B ' CCR',0
*CCR,EA
MOVE_FROM_CCR_VALUE DC.L $42C0
*EA,CCR
MOVE_TO_CCR_VALUE DC.L $44C0
SR_TEXT DC.B ' SR',0
*SR,EA
MOVE_FROM_SR_VALUE DC.L $40C0
A_REG_TEXT DC.B 'A',0
*EA,An
EA_TEXT DC.B ' EA',0
MOVEA_VALUE DC.L $0040
*EA,EA
MOVE_MIN_VALUE DC.L $1000
*LIST,EA; EA,LIST
MOVEM_VALUE DC.L $4880
COMMA_TEXT DC.B ',',0
BYTE_TEXT DC.B '.B',0
LONG_TEXT DC.B '.L',0
WORD_TEXT DC.B '.W',0
MOVE_TEXT DC.B 'MOVE',0
MOVEM_TEXT DC.B 'MOVEM',0
LIST_TEXT DC.B ' <LIST>',0
    END    START        
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
