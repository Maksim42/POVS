#include "p16f84.inc" 
Intcon equ 0Bh ; ������� Intcon.
Status equ 03h ; ������� Status.
EEData equ 08h ; EEPROM - ������
EECon1 equ 08h ; EECON1 - ����1.
EEAdr equ 09h ; EEPROM - �����
EECon2 equ 09h ; EECON2 - ����1. 
;================================================================================
; ������������ ����� ��������.
;================================================================================
RP0 equ 5 ; ��� ������ �����.
GIE equ 7 ; ��� ����������� ���������� ����������.
;================================================================================ 
;.............................................................
;================================================================================ 
ORG 2100h ; ��������� � EEPROM ������ ������.
DE "BSUIR" ; �������� � ������ � �������� .0, .1, .2
;================================================================================
ORG 0 ; ������ ���������� ���������
c_adr set 0x30  ; the starting address of the array, a constant
d_adr set 0x10;
v_ptr equ 0x2F  ; the pointer to the current element in array, a variable
symbol equ 0x2E;
eeprom_start equ 0x0;
eeprom_write_start equ 0x20;
c_num set 0x6   ; the number of elements in array, a constant 
;GOTO READ ; � ������������ READ.
;**********************************************************************
READ:
	BCF Status, 0x5 ; set Bank0 in Data Memory by clearing RP0 bit in STATUS register
	CLRF v_ptr      ; v_ptr=0
LOOP1:
	BCF Status,RP0 ; ������� � ������� ����.
 	MOVF v_ptr, 0 ; �������� � ������� W v_ptr
 	ADDLW eeprom_start ;W=W+eeprom_start
 	MOVWF EEAdr ; ����������� v_ptr, �� �������� W, � ������� EEAdr.
 	BSF Status,RP0 ; ������� � ������ ����.
 	BSF EECon1,0 ; ���������������� ������.
	BCF Status,RP0 ; ������� � ������� ����.
 	MOVF EEData,0 ; ����������� ����� �� ������ EEPROM � ������� v_ptr, � ������� W.
 	MOVWF symbol ; ����������� �����, �� �������� W, � ������� symbol.
	MOVF v_ptr,0	;W=v_ptr
	ADDLW c_adr		;W=W+c_addr
	MOVWF FSR       ;FSR=W, INDF=array[W]
	MOVF symbol, 0	;W=SYMBOL
	MOVWF INDF 		;W=INDF
	INCF v_ptr,0x1  ; v_ptr=v_ptr+1
	MOVLW c_num     ; W=c_num
	SUBWF v_ptr,0   ; W=W-v_ptr
	BTFSS Status,0  ; v_ptr > c_num ?
GOTO LOOP1
;GOTO MAS
;================================================================================ 

MAS:
	CLRF v_ptr      ; v_ptr=0
LOOP2:
	MOVF v_ptr,0	;W=v_ptr
	ADDLW d_adr		;W=W+d_addr
	MOVWF FSR       ;FSR=W, INDF=array[W]
	MOVF v_ptr, 0	;
	MOVWF INDF 		;INDF=W
	INCF v_ptr,0x1  ; v_ptr=v_ptr+1
	MOVLW c_num     ; W=c_num
	SUBWF v_ptr,0   ; W=W-v_ptr
	BTFSS Status,0  ; v_ptr > c_num ?
GOTO LOOP2

WRITE
	;================================================================================
	; ������ ������ � EEPROM.
	;================================================================================
	; ������ ����������� �������� Registr � ������ EEPROM � ������� 02h.
	;--------------------------------------------------------------------------------
	CLRF v_ptr      ; v_ptr=0
LOOP3
	BANKSEL     EEADR
	MOVF v_ptr, 0 ; �������� � ������� W v_ptr
 	ADDLW eeprom_write_start ;W = W + eeprom_start	
	movwf EEAdr ; ����������� ���������, �� �������� W, � ������� EEAdr.
	MOVF v_ptr,0    ; W=v_ptr
	ADDLW d_adr     ; W=W+d_addr
	MOVWF FSR       ; FSR=W, INDF=array[W]
	MOVF INDF,0     ; W=INDF
	movwf EEData ; ����������� �����, �� �������� W, � ������ EEPROM.

	BSF Status, RP0 ;Bank 1
	BCF INTCON, GIE ; Disable INTs.
	BSF EECON1, WREN ; Enable Write
	MOVLW 0x55 ;
	MOVWF EECON2 ; Write 55h
	MOVLW 0xAA ;
	MOVWF EECON2 ; Write AAh
	BSF EECON1,WR ; Set WR bit

	BTFSC       EECON1,WR      	
    GOTO        $-1				
	BCF         EECON1,WREN    	; write complete, disable write mode
	BANKSEL     0 				; bank 0
	BSF INTCON, GIE; nable INTs.
	
	INCF v_ptr,0x1  ; v_ptr=v_ptr+1
	MOVLW c_num     ; W=c_num
	SUBWF v_ptr,0   ; W=W-v_ptr
	BTFSS Status,0  ; v_ptr > c_num ?
GOTO LOOP3
end