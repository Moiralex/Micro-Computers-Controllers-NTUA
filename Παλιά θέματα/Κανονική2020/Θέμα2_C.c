#include <mega16.h>
unsigned char temp,A,B,C,D,E,F,G,H,output,flag;


interrupt [EXT_INT1] void ext_int1_isr(void)
{
    flag = flag ^ 0xFF;
    while (flag==0xFF) {
        output = 0x00;
        PORTC = output;
    }
}

void main(void) {
    DDRA=0x00;
    DDRC=0xFF;
    flag=0x00;
    GIMSK=0x80;
    MCUCR=0x0C;
    #asm("sei");

    while(1) {
        temp=PINA;
        A = temp&0x01;
        B = temp&0x02;
        C = temp&0x04;
        D = temp&0x08;
        E = temp&0x10;
        F = temp&0x20;
        G = temp&0x40;
        H = temp&0x80;

        B = B>>1;
        C = C>>2;
        D = D>>3;
        E = E>>4;
        F = F>>5;
        G = G>>6;
        H = H>>7;

        output = (A&B)|(C&D)|(E|F)|(G|H);
        output = output<<2;
        output = output&0x04;
        PORTC = output;
    } 
}