#include "p16f84.inc" 

c_adr set 0x30  ; the starting address of the array
c_num set 0x14  ; the number of elements in array
v_ptr equ 0x2F  ; the pointer to the current element in array
v_min equ 0x2D	; minimal element in array

BEGIN:
	BCF STATUS, 0x5 ; set Bank0 in Data Memory by clearing RP0 bit in STATUS register
	CLRF v_ptr      ; v_ptr=0

	MOVF c_adr, 0	; W = arr[0]
	MOVWF v_min		; v_min = W
LOOP1:
	MOVF v_ptr, 0    ; W = v_ptr
	ADDLW c_adr     ; W = W + c_adr
	MOVWF FSR       ; FSR = W, INDF = array[v_ptr]
	MOVF INDF, 0     ; W = INDF
	SUBWF v_min, 0   ; W = v_min - W
	BTFSS STATUS, 0  ; If W >= 0 then go to SKIP
	GOTO SKIP		 ; Else W < 0 then
	MOVF v_ptr,0
	ADDLW c_adr
	MOVWF FSR
	MOVF INDF,0
	MOVWF v_min     ; v_min=array[v_ptr]
	
SKIP:
	INCF v_ptr, 0x1  ; v_ptr = v_ptr+1
	MOVLW c_num     ; W = c_num
	SUBWF v_ptr, 0   ; W = v_ptr - W
	BTFSS STATUS, 0  ; v_ptr < c_num ?
	GOTO LOOP1      ; true
	                ; false
	CLRF v_ptr      ; v_ptr = 0
	CLRF v_min      ; v_min = 0
	end
