#include <avr/io.h>

char a,b,c,d, ccomp, f0, f1, output;

int main(void)
{
    DDRB=0xFF; //PORTB ως έξοδος
	DDRA=0x00; //PORTA ως είσοδος
	
    while (1) 
    {
		output = 0x00; //αρχικοποίηση/επαναφορά output στο 0 για να γίνει or με τα f0,f1
		
		a=PINA & 0x01; //Ανάγνωση Α
		
		b=PINA & 0x02; //Ανάγνωση Β
		b = b >> 1; //ολίσθηση του bit B στο LSB (Επειδή διαβάζεται από το bit 1)
		
		c=PINA & 0x04; //Ανάγνωση C
		c = c >> 2; //ολίσθηση του bit C στο LSB
		ccomp = ~c; //Υπολογισμός C'
		ccomp = ccomp & 0x01; //Μάσκα γιατί έγιναν flip όλα τα bit και θέλουμε μόνο το 1ο
		
		
		d=PINA & 0x08; //Ανάγνωση D
		d = d >> 3; //ολίσθηση του bit D στο LSB
		
		f0 = (a & b & ccomp) | (c & d); //Υπολογισμός F0'
		f0 = ~f0; // Υπολογισμός F0 αντιστρέφοντας το F0' και εφαρμόζοντας
		f0 = f0 & 0x01; // μάσκα για να κρατήσουμε το τελευταίο bit
		
		f1 = (a | b) & (c | d); //Υπολογισμός F1
		f1 = f1 << 1; //και τοποθέτηση του στο 2ο LSB αφού θέλουμε να είναι στο bit 1 της εξόδου
		
		output = output | f0; //F0 στο LSB της εξόδου
		output = output | f1; //F1 στο 2ο LSB της εξόδου
		
		PORTB = output; //Έξοδος σε PORTB
    }
}

