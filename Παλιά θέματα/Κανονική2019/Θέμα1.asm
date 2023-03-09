MOV E,B
MVI B,00H
MVI C,08H
MVI D,00H


START:    
    MOV A,B
    RRC
    MOV B,A
    
    DCR C
    JZ EXIT

    MOV A,E
    RRC
    MOV E,A
    JC ONE

    MVI D,00H

    JMP START

ONE:
    MOV A,D
    CPI 00H
    JNZ START

    MVI D,01H ;Αν είναι ο πρώτος άσσος ενημέρωσε το flag
    MOV A,B
    ORI 80H ;Και βαλε έναν άσσο στην αρχή
    MOV B,A
    
    JMP START    

EXIT:
    MOV B,A