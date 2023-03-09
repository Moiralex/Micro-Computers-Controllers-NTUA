#include <avr/io.h>

int led;

int main(void)
{
	DDRA=0xFF; //PORTA ως έξοδος
	DDRC=0x00; //PORTC ως είσοδος
	led=1; // Αρχική θέση LED στο LSB
	
    while (1) 
    {
		if((PINC&0x01)==1) { // Έλεγχος πατήματος push-button SW0
			while((PINC&0x01)==1); // Έλεγχος επαναφοράς push-button SW0
			if(led==128) // Αν είσαι στο MSB led μετακινήσου στο LSB (κυκλική περιστροφή)
				led=1;
			else
				led = led << 1; // Αριστερή ολίσθηση
		}
		
		if((PINC&0x02)==2) { // Έλεγχος πατήματος push-button SW1
			while((PINC&0x02)==2); // Έλεγχος επαναφοράς push-button SW1
			if(led==1) // Αν είσαι στο LSB led μετακινήσου στο MSB (κυκλική περιστροφή)
			led=128;
			else
			led = led >> 1; // Δεξιά ολίσθηση
		}
		
		if((PINC&0x04)==4) { // Έλεγχος πατήματος push-button SW2
			while((PINC&0x04)==4); // Έλεγχος επαναφοράς push-button SW2
			led=128; //Μετακίνηση αναμμένου LED στη θέση MSB
		}
		
		if((PINC&0x08)==8) { // Έλεγχος πατήματος push-button SW3
			while((PINC&0x08)==8); // Έλεγχος επαναφοράς push-button SW3
			led=1; //Μετακίνηση αναμμένου LED στην αρχική του θέση LSB
		}
		
		PORTA=led; // Έξοδος σε PORTA
    }
}

