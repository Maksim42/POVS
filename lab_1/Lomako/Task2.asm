#include "p16f84.inc" 

c_arA set 0x30
c_arLen set 0x5
v_tmp equ 0x2D
v_tmp2 equ 0x2E

BEGIN:
    BCF STATUS, 0x5 ;Set Bank0

    ; swap A[0] and A[4]
    MOVLW 0x4       ; A[0] = A[4] begin
    ADDLW c_arA
    MOVWF FSR
    MOVF INDF, 0
    MOVWF v_tmp2
    MOVLW 0x0       ; v_tmp = A[0] begin
    ADDLW c_arA
    MOVWF FSR
    MOVF INDF, 0
    MOVWF v_tmp     ; v_tmp = A[0] end
    MOVF v_tmp2, 0
    MOVWF INDF      ; A[0] = A[4] end
    MOVLW 0x4       ; A[4] = v_tmp begin
    ADDLW c_arA
    MOVWF FSR
    MOVF v_tmp, 0
    MOVWF INDF      ; A[4] = v_tmp end

    NOP
	CLRF v_tmp
    end