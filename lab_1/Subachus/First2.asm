#include "p16f84.inc" 

c_adr set 0x30  ; the starting address of the array, a constant
c_num set 0x5   ; the number of elements in array, a constant
v_min equ 0x2E  ; the current element
v_minadr equ 0x2D ; адресс минимального элемента
v_ptr equ 0x2F  ; the pointer to the current element in array, a variable
v_cycleptr equ 0x2C ;
v_buffer equ 0x2B


BEGIN: ; работает
	BCF STATUS, 0x5 ; set Bank0
	CLRF v_ptr     
	CLRF v_min    
	
LOOP1: ; работает
	
	MOVF v_ptr,0    ; W=v_ptr
	MOVWF v_cycleptr	; начало цикла
	ADDLW c_adr     ; W=W+c_addr
	MOVWF FSR       ; FSR=W, INDF=array[W]
	MOVF INDF,0     ; W=INDFMOVF v_ptr,0    ; W=v_ptr
	MOVWF v_min
	MOVF FSR,0
	MOVWF v_minadr

	INCF v_cycleptr,0x1 ;запцускаем цикл со след элемента

LOOP2: ; вроде пашет
	
	MOVF v_cycleptr,0 
	ADDLW c_adr
	MOVWF FSR
	MOVF INDF,0
	SUBWF v_min,0
	BTFSS STATUS,0

	GOTO CHECKLOOP2 ; Если w<0 пропускаем

	MOVF INDF,0
	MOVWF v_min
	MOVF FSR,0
	MOVWF v_minadr
	


CHECKLOOP2: ; раюотает
	
	INCF v_cycleptr,0x1
	MOVLW c_num
	SUBWF v_cycleptr,0
	BTFSS STATUS,0
	GOTO LOOP2

	
	MOVF v_ptr,0
	ADDLW c_adr
	MOVWF FSR       
	MOVF INDF,0
	MOVWF v_buffer
	MOVF v_min,0
	MOVWF INDF

	MOVF v_minadr,0;
	MOVWF FSR
	MOVF v_buffer,0
	MOVWF INDF

	

CHECK:	

	INCF v_ptr,0x1
	INCF v_ptr,0x1
	MOVLW c_num     
	SUBWF v_ptr,0
	DECF v_ptr,0x1
	BTFSS STATUS,0
	GOTO LOOP1


	CLRF v_minadr
	CLRF v_ptr      
	CLRF v_min     
	end