#include p16f84a.inc                ; Include register definition file

; Bank0 and Bank1 definitions
#define BANK0 BCF STATUS,RP0
#define BANK1 BSF STATUS,RP0
RS set 1
RW set 2
EN set 3
vpause equ 0x10
LCD_buf equ 0x11
LCD_tmp equ 0x12
; LCD instructions
constant LCD_CD=0x01 ; Clear Display :2ms
constant LCD_CH=0x02 ; Cursor Home :2ms
constant LCD_ON=0x0C ; Display On :40us
constant LCD_OF=0x08 ; Display Off :40us
constant LCD_CN=0x0E ; Cursor On :40us
constant LCD_CB=0x09 ; Cursor Blink :40us
constant LCD_2L=0x28 ; LCD has 2 lines,
constant LCD_4B=0x20 ; 4-bitinterface :40us
constant LCD_L1=0x80 ; select 1 line :40us
constant LCD_L2=0xC0 ; select 2 line :40us

ORG 0
GOTO	START

; ~1ms delay for 4MHz
Delay_1ms:
   MOVLW	0xFA ; 1us, W=250
   MOVWF	vpause ; 1us
   D0:
      nop ; 1us
   DECFSZ	vpause,1 ; 1us
   GOTO		D0 ; 2us
RETURN

; 2ms delay
Delay_2ms macro
   CALL 	Delay_1ms
   CALL 	Delay_1ms
endm

; ~40us delay for 4MHz
Delay_40us:
   MOVLW 	0x08
   MOVWF 	vpause
   D1:
      nop
   DECFSZ 	vpause,1
   GOTO 	D1
RETURN

; Write W to LCD
LCD_w_wr:
   CLRF 	PORTB ; Clear port
   MOVWF 	PORTB ; PortB=Wreg
   CALL 	Delay_1ms ; Wait for 1ms
   BSF 		PORTB,EN ; E='1'
   BCF 		PORTB,EN ; E='0'
   CALL 	Delay_1ms ; Wait for 1ms
   CLRF 	PORTB ; Clear port
RETURN

; Write a command to LCD
; Command is in the WReg
LCD_cmd:
   CLRF		LCD_buf ; clear buffer
   MOVWF	LCD_tmp ; LCD_tmp=command
   ANDLW 	b'11110000' ; WReg & 0xF0
   IORWF 	LCD_buf,0 ; LCD_buf=(1st half)
   CALL 	LCD_w_wr ; Write 1st half
   SWAPF 	LCD_tmp,0 ; swap command
   ANDLW 	b'11110000' ; WReg & 0xF0
   IORWF 	LCD_buf,0 ; LCD_buf=(2nd half)
   CALL 	LCD_w_wr ; Write 2nd half
RETURN


; Write data to LCD
LCD_dat:
   CLRF 	LCD_buf
   BSF 		LCD_buf,RS
   MOVWF 	LCD_tmp
   ANDLW 	b'11110000'
   IORWF 	LCD_buf,0
   CALL 	LCD_w_wr
   SWAPF 	LCD_tmp,0
   ANDLW 	b'11110000'
   IORWF 	LCD_buf,0
   CALL 	LCD_w_wr
RETURN

; LCD display initialization
LCD_init:
   BANK1
   CLRF TRISB ; All outputs on PORTB
   BANK0
   CLRF PORTB ; Clear PORTB
   CALL Delay_1ms ; Delay in 4ms after
   CALL Delay_1ms ; power is on
   CALL Delay_1ms
   CALL Delay_1ms
   MOVLW LCD_4B ; 4-bit data interface
   CALL LCD_w_wr
   CALL Delay_40us
   MOVLW LCD_ON ; Turn on LCD
   CALL LCD_cmd
   CALL Delay_40us
   MOVLW LCD_2L ; 2 lines
   CALL LCD_cmd
   CALL Delay_40us
   MOVLW LCD_CD
   CALL LCD_cmd ; Clear LCD
   Delay_2ms
RETURN

; write char to next position
WRITECHAR: ; (W - char index)
   CALL LCD_dat
   CALL Delay_40us
RETURN

START:
   CALL LCD_init
   
   MOVLW 0x42 	; B
   CALL WRITECHAR
   
   MOVLW 0x47	; G
   CALL WRITECHAR
   
   MOVLW 0x55	; U
   CALL WRITECHAR
   
   MOVLW 0x49	; I
   CALL WRITECHAR
   
   MOVLW 0x52	; R
   CALL WRITECHAR
   
   MOVLW LCD_L2	; Line 2
   CALL LCD_cmd
   CALL Delay_40us
   
   MOVLW 0x4C	; L
   CALL WRITECHAR
   
   MOVLW 0x6F	; o
   CALL WRITECHAR
   
   MOVLW 0x6D	; m
   CALL WRITECHAR
   
   MOVLW 0x61	; a
   CALL WRITECHAR
   
   MOVLW 0x6B	; k
   CALL WRITECHAR
   
   MOVLW 0x6F	; o
   CALL WRITECHAR

   END
