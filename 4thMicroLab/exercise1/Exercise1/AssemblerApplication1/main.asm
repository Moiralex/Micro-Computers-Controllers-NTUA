.include "m16def.inc"

reset:
	ldi r24, low(RAMEND) ; Αρχικοποίηση στοίβας στο τέλος της RAM
	out SPL, r24
	ldi r24, high(RAMEND)
	out SPH, r24
	ser r24 ; Θύρα Α ως έξοδος
	out DDRA, r24
	clr r24 ; Θύρα Β ως είσοδος
	out DDRB, r24
	ldi r26, 0x01 ; Αναμμένο LED
	ldi r28, 0x01 ; Flag φοράς περιστροφής

main:
	out PORTA, r26 ; Άναμμα τρέχοντος LED
	nop
	nop
	in r16, PINB ; Ανάγνωση PORTB
	andi r16, 0x01 ; Απομόνωση LSB
	cpi r16, 0x01 ; Αν είναι 1 (πατημένο) σταμάτα την κίνηση κάνοντας jump στη main χωρίς να ολισθήσει το αναμμένο LED
	breq main
	cpi r28, 0x01 ; Έλεγχος αν πρέπει να γίνει δεξιά (r28=0) ή αριστερή (r28=1) περιστροφή
	breq left

right:
	lsr r26 ; Δεξιά περιστροφή
	cpi r26, 0x01 ; Έλεγχος αν το αναμμένο LED είναι στο LSB 
	brne main ; Αν όχι συνέχισε κανονικά τη λειτουργία
	ldi r28, 0x01 ; Αλλιώς άλλαξε τη φορά περιστροφής ενημερώνοντας το flag
	jmp main ; και μετά συνέχισε τη λειτουργία

left:
	lsl r26 ; Αριστερή περιστροφή
	cpi r26, 0x80 ; Έλεγχος αν το αναμμένο LED είναι στο MSB
	brne main ; Αν όχι συνέχισε κανονικά τη λειτουργία
	ldi r28, 0x00 ; Αλλιώς άλλαξε τη φορά περιστροφής ενημερώνοντας το flag
	jmp main ; και μετά συνέχισε τη λειτουργία