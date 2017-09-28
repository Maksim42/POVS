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
	
CREATEARRAY: ; работает
	
	MOVF v_ptr,0    
	ADDLW c_adr     
	MOVWF FSR       
	MOVF v_nextelement,0
	MOVWF INDF
	INCF v_nextelement,0x01
	INCF v_ptr,0x01
	MOVF v_num,0 
	SUBWF v_ptr,0
	BTFSS STATUS,0
	GOTO CREATEARRAY

WRITE:

	BSF STATUS, 0x06 ; Bank 1
	BCF INTCON, 0x07; Disable INTs.
	BSF EECON1, 0x02 ; Enable Write
	MOVLW 0x55 ;
	MOVWF EECON2 ; Write 55h
	MOVLW 0xAA ;
	MOVWF EECON2 ; Write AAh
	BSF EECON1,0x01 ; Set WR bit; begin write
	BSF INTCON, 0x07 ; Enable INTs.

	MOVF 0x00,0
	MOVWF EEADR
	MOVF 0x01,0
	MOVWF EEDATA
	BCF EECON1,0x01 
;	MOVWF EEDATA
	

	CLRF v_ptr        
	end