#include "p16f84.inc" 

; const
c_stHead    set 0x0C ; stek length = 4
; var
v_i         equ 0x10
v_arPointer equ 0x11
v_epPointer equ 0x12
v_strLength equ 0x13

GOTO BEGIN

READSTR:
    MOVF v_strLength, 0
    MOVWF v_i
    DECF v_i, 1

    LOOPI:
        MOVF v_epPointer, 0
        ADDWF v_i, 0
        MOVWF EEADR
        BSF STATUS, 0x05
        BSF EECON1, 0x00
        BCF STATUS, 0x05

        MOVF v_arPointer, 0
        ADDWF v_i, 0
        MOVWF FSR
        MOVF EEDATA, 0
        MOVWF INDF
        
        MOVLW 0x01
        SUBWF v_i, 1
        BTFSC STATUS, 0 
    GOTO LOOPI
RETURN

BEGIN:
BCF STATUS, 0x5

MOVLW 0x30
MOVWF v_arPointer
MOVLW 0x5
MOVWF v_strLength
MOVLW 0x01
MOVWF v_epPointer

CALL READSTR 

NOP
END