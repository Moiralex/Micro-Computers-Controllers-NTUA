INCLUDE MACROS

DATA_SEG SEGMENT
    MSG1 DB 'DOSE 1ο ARITHMO: $'
    MSG2 DB 0AH,0DH, 'DOSE 2ο ARITHMO: $'
    MSG3 DB 0AH,0DH, 'APOTELESMA= $'
DATA_SEG ENDS

CODE_SEG SEGMENT
    ASSUME CS:CODE_SEG, DS:DATA_SEG

MAIN PROC FAR
    MOV AX, DATA_SEG
    MOV DS, AX

    PRINT_STR MSG1

    CALL OCT_KEYB ;O3
    MOV AH,0
    MOV BL,8
    MUL BL ; Μέγιστο αποτέλεσμα 56 χωρά στον AL
    MOV BH, AL
    
    CALL OCT_KEYB ;O2
    MOV AH,0
    ADD BH,AL ; Μέγιστο αποτέλεσμα 63 χωρά

    PRINT_STR MSG2
    
    CALL OCT_KEYB ;O1
    MOV AH,0
    MOV BL,8
    MUL BL ; Μέγιστο αποτέλεσμα 56 χωρά στον AL
    MOV BL, AL
    
    CALL OCT_KEYB ;O0
    MOV AH,0
    ADD BL,AL ; Μέγιστο αποτέλεσμα 63 χωρά 

    PRINT_STR MSG3

    ADD BH,BL ; Μέγιστο αποτέλεσμα 126 χωρά στον BH

    MOV DL,BH
    MOV CL,4
    RCR DL,CL
    AND DL,0FH
    CALL PRINT_HEX

    MOV DL,BH
    AND DL,0FH
    CALL PRINT_HEX

    EXIT

MAIN ENDP

    PRINT_HEX PROC NEAR
         CMP DL, 9 
         JG ADDR1
         ADD DL, 30H
         JMP ADDR2
         
         ADDR1:
         ADD DL, 37H   
         
         ADDR2:
         MOV AH,2
         INT 21H
         RET
    PRINT_HEX ENDP
    
    OCT_KEYB PROC NEAR 
         PUSH DX 
       NEXT:
         MOV AH,8
         INT 21H
         CMP AL, 'T'
         JE EXITING
         CMP AL,30H 
         JL NEXT 
         CMP AL,37H 
         JG NEXT
         MOV DL, AL
         MOV AH,2
         INT 21H
         SUB AL,30H 
       RETURN:
         POP DX
         RET
       EXITING:
         POP DX
         MOV AX, 4C00H
         INT 21H
    OCT_KEYB ENDP


CODE_SEG ENDS
END MAIN


