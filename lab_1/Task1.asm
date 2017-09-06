#include "p16f84.inc" 

c_adr set 0x30  ; the starting address of the array, a constant
v_ptr equ 0x2F  ; the pointer to the current element in array, a variable
v_max equ 0x2E  ; the maximal number in array, a variable
v_min equ 0x2D	;
c_num set 0x14  ; the number of elements in array, a constant 

BEGIN:
	BCF STATUS, 0x5 ; set Bank0 in Data Memory by clearing RP0 bit in STATUS register
	CLRF v_ptr      ; v_ptr=0
	CLRF v_max      ; v_max=0

	MOVF c_adr, 0	; v_min = arr[0]
	MOVWF v_min		;
LOOP1:
	MOVF v_ptr,0    ; W=v_ptr
	ADDLW c_adr     ; W=W+c_adr
	MOVWF FSR       ; FSR=W, INDF=array[W]
	MOVF INDF,0     ; W=INDF
	SUBWF v_max,0   ; W=W-v_max
	BTFSC STATUS,0  ; If W < 0 then go to SMALL
	GOTO SKIP
			; Else W >= 0 then W is bigger than v_max
	MOVF v_ptr,0
	ADDLW c_adr
	MOVWF FSR
	MOVF INDF,0
	MOVWF v_max     ; v_max=array[v_ptr]
	
SKIP:
	INCF v_ptr,0x1  ; v_ptr=v_ptr+1
	MOVLW c_num     ; W=c_num
	SUBWF v_ptr,0   ; W=W-v_ptr
	BTFSS STATUS,0  ; v_ptr > c_num ?
	GOTO LOOP1      ; no
	                ; yes
	CLRF v_ptr      ; v_ptr=0
	CLRF v_max      ; v_max=0
	end
