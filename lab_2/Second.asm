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

	BSF STATUS, RP0 ; Bank 1
	BCF INTCON, GIE ; Disable INTs.
	BSF EECON1, WREN ; Enable Write
	MOVLW 55h ;
	MOVWF EECON2 ; Write 55h
	MOVLW AAh ;
	MOVWF EECON2 ; Write AAh
	BSF EECON1,0x01 ; Set WR bit; begin write
	BSF INTCON, GIE ; Enable INTs.
;	MOVF EEDATA, W

	CLRF v_ptr        
	end