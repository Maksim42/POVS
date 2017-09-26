#include "p16f84.inc" 

; const
c_stHead    set 0x0C ; stek length = 4
; var
v_stPointer equ 0x10
v_temp  equ 0x11
v_i         equ 0x12
v_arPointer equ 0x13
v_epPointer equ 0x14

GOTO BEGIN

PUSH:
    MOVWF v_temp
    MOVF v_stPointer, 0
    MOVWF FSR
    MOVF v_temp, 0
    MOVWF INDF
    INCF v_stPointer, 1
RETURN

POP:
	DECF v_stPointer, 1
    MOVF v_stPointer, 0
    MOVWF FSR
    MOVF INDF, 0
RETURN

READSTR:
    CALL POP
    MOVWF v_epPointer

    CALL POP
    MOVWF v_i
    DECF v_i, 1

    CALL POP
    MOVWF v_arPointer

    

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
MOVLW c_stHead
MOVWF v_stPointer

MOVLW 0x30
CALL PUSH
MOVLW 0x05
CALL PUSH
MOVLW 0x01
CALL PUSH

CALL READSTR 

CLRW
END