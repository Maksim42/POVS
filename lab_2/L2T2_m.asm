#include "p16f84.inc" 

; const
c_adr set 0x30  ; the starting address of the array, a constant
c_num set 0x14  ; the number of elements in array, a constant
; variable
v_nextelement   equ 0x2E ; the current element
v_ptr           equ 0x2F ; the pointer to the current element in array
v_num           equ 0x2D
v_arPointer     equ 0x11
v_epPointer     equ 0x12
v_strLength     equ 0x13
v_i				equ 0x14

GOTO BEGIN

WRITESTR:
    MOVF v_strLength, 0
    MOVWF v_i
    DECF v_i, 1

    LOOPI:
        BCF STATUS, 0x05
        MOVF v_epPointer, 0
        ADDWF v_i, 0
        MOVWF EEADR
        MOVF v_arPointer, 0
        ADDWF v_i, 0
        MOVWF FSR
        MOVF INDF, 0
        MOVWF EEDATA

        BSF STATUS, 0x05 ; set Bank1
        BCF INTCON, 0x07 ; disable ineraptions
        BSF EECON1, 0x02 ; Enable Write
        MOVLW 0x55 ;
        MOVWF EECON2 
        MOVLW 0xAA ;
        MOVWF EECON2
        BSF EECON1, 0x01 ; write data
        BSF INTCON, 0x07 ; enable ineraptions

        WAITWRITE:
            BTFSS EECON1, 0x04
            GOTO WAITWRITE
        BCF EECON1, 0x04
      
        MOVLW 0x01
        SUBWF v_i, 1
        BTFSC STATUS, 0 
    GOTO LOOPI
RETURN

BEGIN:
BCF STATUS, 0x5 ; set Bank0
CLRF v_ptr   
CLRF v_nextelement  
INCF v_nextelement, 1
MOVF v_ptr, 0
ADDLW c_num
MOVWF v_num
	
CREATEARRAY:
	MOVF v_ptr, 0    
	ADDLW c_adr     
	MOVWF FSR       
	MOVF v_nextelement, 0
	MOVWF INDF
	INCF v_nextelement, 1
	INCF v_ptr, 1
	MOVF v_num, 0 
	SUBWF v_ptr, 0
	BTFSS STATUS, 0
GOTO CREATEARRAY

MOVLW c_adr
MOVWF v_arPointer
MOVLW c_num
MOVWF v_strLength
MOVLW 0x05
MOVWF v_epPointer

CALL WRITESTR

NOP       
END