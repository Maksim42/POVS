#include "p16f84.inc" 

;Константа
c_adr set 0x30  ; the starting address of the array, a constant
c_num set 0x14  ; the number of elements in array, a constant
;Переменные
v_nextelement equ 0x2E  ; the current element
v_ptr equ 0x2F  ; the pointer to the current element in array
v_num equ 0x2D

BEGIN: ; работает
	BCF STATUS, 0x5 ; set Bank0
	CLRF v_ptr   
	CLRF v_nextelement  
	INCF v_nextelement,0x01
	MOVF v_ptr,0
	ADDLW c_num
	MOVWF v_num
	
;CREATEARRAY: ; работает
;	
;	MOVF v_ptr,0    
;	ADDLW c_adr     
;	MOVWF FSR       
;	MOVF v_nextelement,0
;	MOVWF INDF
;	INCF v_nextelement,0x01
;	INCF v_ptr,0x01
;	MOVF v_num,0 
;	SUBWF v_ptr,0
;	BTFSS STATUS,0
;	GOTO CREATEARRAY

WRITE:
    BCF STATUS, 0x05 ; set Bank0
    MOVLW 0x05
	MOVWF EEADR
	MOVLW 0x42
	MOVWF EEDATA

    BSF STATUS, 0x05 ; set Bank1
	BCF INTCON, 0x07 ; Disable ineraptions
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
    
NOP       
END