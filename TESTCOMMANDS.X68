*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
WORD    EQU $0BCD
LONG    EQU $1234ABCD

    ORG    $4000
START:                  ; first instruction of program

    MOVEM.W     D1-D4/A1-A6,(A4)
    MOVEM.W     D0-D7/A0-A7,(A4)
    MOVEM.W     D2/D1/D5/A3/A1,(A6)
    MOVEM.W     (A6),D2/D1/D5/A3/A1
    MOVEM.L     A3/A1/D2/D1/D5,-(A6)
    MOVEM.L     A6,(A2)
    
    BRA     START
    BCC     START
    BCS     START
    BEQ     START
    BGE     START
    BGT     START
    BHI     START
    BLE     START
    BLS     START
    BLT     START
    BMI     START
    BNE     START
    BPL     START
    BVC     START
    BVS     START
    
    MOVE.B      $AB,(A1)
    MOVE.B      $ABFCAFD,(A1)
   
    
    MOVEM.W     (A4),A3
    MOVEM.L     (A2),A6
    
    SUBQ.B  #2,D4
    SUBQ.W  #8,(A4)+
    SUBQ.L  #1,-(A6)
    
    NEG.B   D1
    NEG.W   D4
    NEG.L   D6
    
    ORI.B   #$FF,D6
    ORI.W   #$A134,D3
    ORI.L   #$1435DCDA,D4
    
    CMPI.B  #$AA,D2
    CMPI.W  #$B432,D3
    CMPI.L  #$ABCD1234,D7
    
    RTS
    NOP
    JSR (A1)
    JSR WORD
    JSR LONG
    
    LEA (A3),A7
    
    BCLR #$5,D1             ; Static
    BCLR #$8,(A4)           ; Static
    
    BCLR D6,(A7)            ; Dynamic
    
    MOVE.B  D4,D3
    MOVE.B  (A3),(A4)
    MOVE.B  D5,(A1)
    MOVE.B  #$BC,D1
    MOVE.B  #$11,(A4)
    
    MOVE.W  D4,D3
    MOVE.W  (A3),(A4)
    MOVE.W  D5,(A1)
    MOVE.W #$A134,D6
    
    MOVEA.W #$134,A4
    MOVEA.W #$A134,A4
    MOVEA.W #$A34,A4 
    
    MOVE.L  D4,D3
    MOVE.L  (A3),(A4)
    MOVE.L  D5,(A1)
    MOVE.L #$A134,D6
    
    MOVEA.L #$134,A4
    MOVEA.L #$FFFFA134,A4
    MOVEA.L #$A34,A4    
    
    ASL (A1)
    ASR (A1)

    LSL (A1)
    LSR (A1)
    
    ROL (A1)
    ROR (A1)
    
    ASL.B D1,D2
    ASL.W D2,D3
    ASL.L D4,D5
    
    ASR.B D1,D2
    ASR.W D2,D3
    ASR.L D4,D5
    
    ASL.B #1,D2
    ASL.W #2,D3
    ASL.L #8,D5
    
    ASR.B #4,D2
    ASR.W #5,D3
    ASR.L #8,D5
    
    LSL.B D1,D2
    LSL.W D2,D3
    LSL.L D4,D5
    
    LSR.B D1,D2
    LSR.W D2,D3
    LSR.L D4,D5
    
    LSL.B #1,D2
    LSL.W #2,D3
    LSL.L #8,D5
    
    LSR.B #4,D2
    LSR.W #5,D3
    LSR.L #8,D5
    
    ROL.B D1,D2
    ROL.W D2,D3
    ROL.L D4,D5
    
    ROR.B D1,D2
    ROR.W D2,D3
    ROR.L D4,D5
    
    ROL.B #1,D2
    ROL.W #2,D3
    ROL.L #8,D5
    
    ROR.B #4,D2
    ROR.W #5,D3
    ROR.L #8,D5
    
    ADD.B   D1,(A1)
    ADD.W   D2,(A2)
    ADD.L   D3,(A3)
    
    ADD.B   (A1),D1
    ADD.W   (A2),D2
    ADD.L   (A3),D3

    ADDA.W   A4,A2
    ADDA.L   -(A1),A3
    ADDA.W   D2,A2
    ADDA.L   D3,A3
    
    MULS.W  D1,D7
    MULS.W  (A3),D4
    MULS.W  (A5)+,D2
    MULS.W  -(A0),D6
    
    MULU.W  D1,D7
    MULU.W  (A3),D4
    MULU.W  (A5)+,D2
    MULU.W  -(A0),D6
    
    DIVS.W  D1,D7
    DIVS.W  #$0123,D4
    DIVS.W  (A5)+,D2
    DIVS.W  -(A0),D6
    
    DIVU.W  D1,D7
    DIVU.W  (A3),D4
    DIVU.W  (A5)+,D2
    DIVU.W  -(A0),D6
    
    OR.B   D1,(A1)
    OR.W   D2,(A2)
    OR.L   D3,(A3)
    
    OR.B   (A1),D1
    OR.W   (A2),D2
    OR.L   (A3),D3

    CMP.B   (A1),D5
    CMP.W   A4,D2
    CMP.L   -(A4),D3

    CMP.B   #$A1,D6
    CMP.W   #$01B8,D1
    CMP.L   #$BDE2F132,D4
    
    EOR.B   D1,D6
    EOR.B   D4,(A1)
    
    EOR.W   D3,-(A3)
    EOR.W   D2,(A2)+
    
    EOR.L   D3,D6
    EOR.L   D1,(A6)
    
    SUB.B   (A1),D6
    SUB.W    A4,D1
    SUB.L   -(A7),D5
    
    SUB.B   D2,(A1)
    SUB.W   D6,(A4)+
    SUB.L   D1,-(A7)

    
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source































*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
