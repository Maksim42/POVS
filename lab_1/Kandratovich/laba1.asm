
;------------------------------------------------------
; EMBEDDED SYSTEMS
; Practical Work #1
;------------------------------------------------------
; This is a source file of the program which finds the
; maximal element from the given array of numbers.
;------------------------------------------------------
; File      :   max.asm
; Author    :   Alexander A. Ivaniuk
; Date      :   10.10.2004
;------------------------------------------------------
#include "p16f84.inc" 

c_adr set 0x30  ; the starting address of the array, a constant
v_ptr equ 0x2F  ; the pointer to the current element in array, a variable
v_min equ 0x2E  ; the min number in array, a variable
c_num set 0x14   ; the number of elements in array, a constant 

; The allocation of variables in Data Memory:
; Address   :   The value of object
; 0x2E      :   v_ptr
; 0x2F      :   v_max
; 0x30      :   array[0]
; 0x31      :   array[1]
; 0x32      :   array[2]
; ...................
; 0x39      :   array[9]

BEGIN:
	BCF STATUS, 0x5 ; set Bank0 in Data Memory by clearing RP0 bit in STATUS register
	CLRF v_ptr      ; v_ptr = 0
	CLRF v_min      ; v_min = 0

	MOVF v_ptr,0	; W = v_ptr
	ADDLW c_adr		; W += c_adr
	MOVWF FSR		; FSR = W, INDF = array[c_adr] 
	MOVF INDF,0		; W = array[c_adr]
	MOVWF v_min		; v_min = W
	GOTO SKIP 
LOOP1:
	MOVF v_ptr,0    ; W = v_ptr
	ADDLW c_adr     ; W += c_addr
	MOVWF FSR       ; FSR = W, INDF = array[W]
	MOVF INDF,0     ; W = INDF
	SUBWF v_min,0   ; W = v_min-W
	BTFSS STATUS,0  ; v_min > array[W]
	GOTO SKIP
			
	MOVF v_ptr,0	; W = v_ptr
	ADDLW c_adr		; W += vptr
	MOVWF FSR		; FSR = W
	MOVF INDF,0		; W = array[v_ptr]
	MOVWF v_min     ; v_min = array[v_ptr]
	
SKIP:
	INCF v_ptr,0x1  ; v_ptr = v_ptr + 1 
	MOVLW c_num     ; W = c_num
	SUBWF v_ptr,0   ; W = v_ptr - W
	BTFSS STATUS,0  ; v_ptr > c_num ?
	GOTO LOOP1      ; no
	                ; yes
	CLRF v_ptr      ; v_ptr = 0
	CLRF v_min      ; v_min = 0
	end