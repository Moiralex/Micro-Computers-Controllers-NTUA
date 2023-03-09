START:
    IN 20H
    RAR
    RAR
    RAR
    RAR
    RAR
    ANI 05H ; Αριθμός/2 = αριθμός αριστερών περιστροφών άσσου
    MOV C,A
    MVI B,01H

REPEAT:
    MOV A,C
    CPI 00H
    JZ EXIT

    DCR C
    MOV A,B
    RLC
    MOV B,A
    JMP REPEAT

EXIT:
    MOV A,B
    OUT 30H
    JMP START
