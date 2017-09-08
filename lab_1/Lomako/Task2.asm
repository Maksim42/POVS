#include "p16f84.inc" 

; const
c_arA set       0x2F    ; array start index - 1
c_arLen set     0x20    ; array length
; var
v_i equ         0x29
v_j equ         0x2A
v_max equ       0x2B
v_maxpos equ    0x2C
v_tmp equ       0x2D

BEGIN:
    BCF STATUS, 0x5 ; Set Bank0
    MOVLW c_arLen
    MOVWF v_i
LOOPI:
    MOVF v_i, 0         ; W = i
    MOVWF v_j           ; j = i
    ADDLW c_arA
    MOVWF v_maxpos      ; v_maxpos = a[i].address
    MOVWF FSR           ; min = a[i]
    MOVF INDF, 0
    MOVWF v_max
LOOPJ:
    MOVF v_j, 0         ; W = a[j]
    ADDLW c_arA
    MOVWF FSR
    MOVF INDF, 0
    SUBWF v_max, 0      ; if a[j] > v_max
    BTFSC STATUS, 0
    GOTO IFEND
    MOVF FSR, 0
    MOVWF v_maxpos      ; maxpos = a[j].address
    MOVF INDF, 0        ; max = a[j]
    MOVWF v_max     
IFEND:                  ; end if
    DECFSZ v_j, 1
    GOTO LOOPJ          ; end LOOPJ

    MOVF v_i, 0         ; tmp = a[i]
    ADDLW c_arA
    MOVWF FSR
    MOVF INDF, 0
    MOVWF v_tmp          
    MOVF v_max, 0       ; a[i] = min
    MOVWF INDF
    MOVF v_maxpos, 0    ; a[minpos] = tmp
    MOVWF FSR
    MOVF v_tmp, 0
    MOVWF INDF

    DECFSZ v_i, 1
    GOTO LOOPI          ; end LOOPI
    end