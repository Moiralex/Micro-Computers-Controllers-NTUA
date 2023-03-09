.include "m16def.inc"
.DEF input=r22
.DEF temp=r21
.DEF tempstack=r16
.DEF flag = r17

.org 0
reti
reti
jmp interrupt1
reti

clr temp
out DDRA,temp
ser temp
out DDRC,temp

LDI temp,0x80
OUT GIMSK, temp
LDI temp,0x0C
OUT MCUCR,temp
SEI

ldi temp,high(RAMEND)
out SPH, temp
ldi temp,low(RAMEND)
out SPL,temp

LDI flag,0x00
START:
    IN input,PINA
    MOV temp,input

    ANDI temp,0x03
    CPI temp,0x03
    BREQ OUTPUT1

    MOV temp,input
    ANDI temp,0x0C
    CPI temp,0x0C
    BREQ OUTPUT1

    MOV temp,input
    ANDI temp,0x30
    CPI temp,0x00
    BRNE OUTPUT1

    MOV temp,input
    ANDI temp,0xC0
    CPI temp,0x00
    BRNE OUTPUT1

    LDI temp,0x00
    OUT PORTC,temp
    RJMP START

OUTPUT1:
    LDI temp,0x04
    OUT PORTC,temp
    RJMP START

interrupt1:
    POP tempstack
    POP tempstack
    COM flag
    SBRS flag,0 ; Αν το bit 0 του flag=1 (Περριτή διακοπή) μη γυρίσεις στην αρχή
    RJMP START

    LDI temp,0x00
    OUT PORTC,temp
STUCK: JMP STUCK