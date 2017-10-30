; Bank0 and Bank1 definitions
#define BANK0 bcf STATUS,RP0
#define BANK1 bsf STATUS,RP0
RS equ 1
RW equ 2
EN equ 3
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

; ~1ms delay for 4MHz
; One instruction in 1us
; Delay=2+1+1+249*4+3+2=1005
; Real delay for 1,005 ms.
Delay_1ms
movlw 0xFA ; 1us, W=250
movwf vpause ; 1us
D0:
nop ; 1us
decfsz vpause,1 ; 1us
goto D0 ; 2us
return
;--------------------------------------------
; 2ms delay
Delay_2ms macro
call Delay_1ms
call Delay_1ms
endm
;--------------------------------------------
; ~40us delay for 4MHz
Delay_40us
movlw 0x08
movwf vpause
D1:
nop
decfsz vpause,1
goto D1
return


;--------------------------------------------
; Write W to LCD
LCD_w_wr
clrf PORTB ; Clear port
movwf PORTB ; PortB=Wreg
call Delay_1ms ; Wait for 1ms
bsf PORTB,EN ; E='1'
bcf PORTB,EN ; E='0'
call Delay_1ms ; Wait for 1ms
clrf PORTB ; Clear port
return


;--------------------------------------------
; Write a command to LCD
; Command is in the WReg
LCD_cmd
clrf LCD_buf ; clear buffer
movwf LCD_tmp ; LCD_tmp=command
andlw b'11110000' ; WReg & 0xF0
iorwf LCD_buf,0 ; LCD_buf=(1st half)
call LCD_w_wr ; Write 1st half
swapf LCD_tmp,0 ; swap command
andlw b'11110000' ; WReg & 0xF0
iorwf LCD_buf,0 ; LCD_buf=(2nd half)
call LCD_w_wr ; Write 2nd half
return


;--------------------------------------------
; Write data to LCD
LCD_dat
clrf LCD_buf
bsf LCD_buf,RS
movwf LCD_tmp
andlw b'11110000'
iorwf LCD_buf,0
call LCD_w_wr
swapf LCD_tmp,0
andlw b'11110000'
iorwf LCD_buf,0
call LCD_w_wr
return


;--------------------------------------------
; LCD display initialization
LCD_init
BANK1
clrf TRISB ; All outputs on PORTB
BANK0
clrf PORTB ; Clear PORTB
call Delay_1ms ; Delay in 4ms after
call Delay_1ms ; power is on
call Delay_1ms
call Delay_1ms
movlw LCD_4B ; 4-bit data interface
call LCD_w_wr
call Delay_40us
movlw LCD_ON ; Turn on LCD
call LCD_cmd
call Delay_40us
movlw LCD_2L ; 2 lines
call LCD_cmd
call Delay_40us
movlw LCD_CD
call LCD_cmd ; Clear LCD
Delay_2ms
return


org 0x10
MAIN:
call LCD_init
; Write character 'A' to the 1st position
movlw 0x41
call LCD_dat
call Delay_40us
; Write character 'a' to the 2nd position
movlw 0x61
call LCD_dat
call Delay_40us
; Write character 'B'
movlw 0x42
call LCD_dat
call Delay_40us
; Show cursor
movlw LCD_ON
iorlw LCD_CN
call LCD_cmd
call Delay_40us
; Blinking cursor
movlw LCD_ON
iorlw LCD_CB
call LCD_cmd
call Delay_40us
movlw 0x01
call LCD_cmd ; clear LCD


;User defined character
;--------------------------------------------
; Define user's character
; Select CGRAM address =0
LCDC 0x40
; Setup bit map
LCDD b'11111'
LCDD b'00001'
LCDD b'11111'
LCDD b'10000'
LCDD b'11111'
LCDD b'00001'
LCDD b'11111'
LCDD b'10101'
; Select DDRAM address =0
LCDC 0x80
; Write predefined character
LCDD 0x0