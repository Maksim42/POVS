#include "p16f84.inc" 
Intcon equ 0Bh ; Регистр Intcon.
Status equ 03h ; Регистр Status.
EEData equ 08h ; EEPROM - данные
EECon1 equ 08h ; EECON1 - банк1.
EEAdr equ 09h ; EEPROM - адрес
EECon2 equ 09h ; EECON2 - банк1. 
;================================================================================
; Присваивание битам названий.
;================================================================================
RP0 equ 5 ; Бит выбора банка.
GIE equ 7 ; Бит глобального разрешения прерываний.
;================================================================================ 
;.............................................................
;================================================================================ 
ORG 2100h ; Обращение к EEPROM памяти данных.
DE "BSUIR" ; Записать в ячейки с адресами .0, .1, .2
;================================================================================
ORG 0 ; Начать выполнение программы
c_adr set 0x30  ; the starting address of the array, a constant
d_adr set 0x10;
v_ptr equ 0x2F  ; the pointer to the current element in array, a variable
symbol equ 0x2E;
eeprom_start equ 0x0;
eeprom_write_start equ 0x20;
c_num set 0x6   ; the number of elements in array, a constant 
;GOTO READ ; с подпрограммы READ.
;**********************************************************************
READ:
	BCF Status, 0x5 ; set Bank0 in Data Memory by clearing RP0 bit in STATUS register
	CLRF v_ptr      ; v_ptr=0
LOOP1:
	BCF Status,RP0 ; Переход в нулевой банк.
 	MOVF v_ptr, 0 ; Записать в регистр W v_ptr
 	ADDLW eeprom_start ;W=W+eeprom_start
 	MOVWF EEAdr ; Скопировать v_ptr, из регистра W, в регистр EEAdr.
 	BSF Status,RP0 ; Переход в первый банк.
 	BSF EECon1,0 ; Инициализировать чтение.
	BCF Status,RP0 ; Переход в нулевой банк.
 	MOVF EEData,0 ; Скопировать число из ячейки EEPROM с адресом v_ptr, в регистр W.
 	MOVWF symbol ; Скопировать число, из регистра W, в регистр symbol.
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
	; Запись данных в EEPROM.
	;================================================================================
	; Запись содержимого регистра Registr в ячейку EEPROM с адресом 02h.
	;--------------------------------------------------------------------------------
	CLRF v_ptr      ; v_ptr=0
LOOP3
	BANKSEL     EEADR
	MOVF v_ptr, 0 ; Записать в регистр W v_ptr
 	ADDLW eeprom_write_start ;W = W + eeprom_start	
	movwf EEAdr ; Скопировать константу, из регистра W, в регистр EEAdr.
	MOVF v_ptr,0    ; W=v_ptr
	ADDLW d_adr     ; W=W+d_addr
	MOVWF FSR       ; FSR=W, INDF=array[W]
	MOVF INDF,0     ; W=INDF
	movwf EEData ; Скопировать число, из регистра W, в ячейку EEPROM.

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