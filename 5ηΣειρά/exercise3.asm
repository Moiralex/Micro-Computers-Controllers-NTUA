DATA SEGMENT
	SIXTEEN DB DUP(16)	; Store number sixteen in memmory in order to use it for multiplications
DATA ENDS

CODE SEGMENT
ASSUME CS:CODE, DS:DATA
MAIN PROC FAR
    START:
        MOV AX,DATA
        MOV DS,AX
        CALL HEX_KEYB ;Read the most significant digit
        MOV AH, 0
        MUL SIXTEEN ;Multiply with 16*16 to start forming the 3digit hexadecimal number
        MUL SIXTEEN
        MOV BX, AX ; Number will be stored in BX

        CALL HEX_KEYB ;Read the next digit
        MOV AH, 0
        MUL SIXTEEN ;Multiply with 16 following the same logic
        ADD BX, AX ; Add to the number
        
        CALL HEX_KEYB ;Read the next digit
        MOV AH, 0
        ADD BX, AX ; Add to the number

        MOV AX, BX ; Number in AX in order to print it in hexadecimal form
        CALL PRINT_HEX

        MOV DL,3DH ; Print '='
        CALL PRINT
        
        MOV AX, BX ; Number in AX in order to print it in decimal form
        CALL PRINT_DEC

        MOV DL,3DH ; Print '='
        CALL PRINT

        MOV AX, BX ; Number in AX in order to print it in octal form
        CALL PRINT_OCT

        MOV DL,3DH ; Print '='
        CALL PRINT

        MOV AX, BX ; Number in AX in order to print it in binary form
        CALL PRINT_BIN

        MOV DL, 0AH ; End of line
        MOV AH,2
        INT 21H
        MOV DL, 0DH ; Return cursor to the start of the line
        MOV AH,2
        INT 21H

        JMP START ; Repeat for next input
MAIN ENDP

PRINT_HEX PROC NEAR ; This routine prints the number contained in AX in hexadecimal form
    PUSH DX ; Save contents of DX because that register will be used
    PUSH BX ; Save contents of BX because that register will be used
    MOV CX,0 ;Digit counter on CX
    HEX_DIGIT:
        MOV DX,0
        MOV BX,16D ;Divide by 16 to get the last digit as the remainder
        DIV BX
        PUSH DX ; and push it into the stack
        INC CX ; increase the digit counter
        CMP AX,0 ; while the quotient is not zero (there are more digits) repeat
        JNE HEX_DIGIT
            
        PRINT_HEXADECIMAL_NUMBER: ;Once all digits are in the stack print them one by one
            POP DX
            CMP DX,9
            JG PRINT_HEX_LETTER ; If the digit is between 10 and 15 print it as a letter
            ADD DL,30H
        OUTPUT:
            MOV AH,2
            INT 21H
            LOOP PRINT_HEXADECIMAL_NUMBER
        POP BX ; Restore contents of BX
        POP DX ; Restore contents of DX
        RET
        
        PRINT_HEX_LETTER:
            ADD DL,37H
            JMP OUTPUT      
        
PRINT_HEX ENDP

PRINT_DEC PROC NEAR ; This routine prints the number contained in AX in decimal form
    PUSH DX ; Save contents of DX because that register will be used
    PUSH BX ; Save contents of BX because that register will be used
    MOV CX,0 ;Digit counter on CX
    DEC_DIGIT:
        MOV DX,0
        MOV BX,10D ;Divide by 10 to get the last digit as the remainder
        DIV BX
        PUSH DX ; and push it into the stack
        INC CX ; increase the digit counter
        CMP AX,0 ; while the quotient is not zero (there are more digits) repeat
        JNE DEC_DIGIT
            
    PRINT_DECIMAL_NUMBER: ;Once all digits are in the stack print them one by one
        POP DX
        ADD DL,30H
        MOV AH,2
        INT 21H
        LOOP PRINT_DECIMAL_NUMBER
        POP BX ; Restore contents of BX
        POP DX ; Restore contents of DX
        RET
PRINT_DEC ENDP

PRINT_OCT PROC NEAR ; This routine prints the number contained in AX in octal form
    PUSH DX ; Save contents of DX because that register will be used
    PUSH BX ; Save contents of BX because that register will be used
    MOV CX,0 ;Digit counter on CX
    OCT_DIGIT:
        MOV DX,0
        MOV BX,8D ;Divide by 8 to get the last digit as the remainder
        DIV BX
        PUSH DX ; and push it into the stack
        INC CX ; increase the digit counter
        CMP AX,0 ; while the quotient is not zero (there are more digits) repeat
        JNE OCT_DIGIT
            
    PRINT_OCTAL_NUMBER: ;Once all digits are in the stack print them one by one
        POP DX
        ADD DL,30H
        MOV AH,2
        INT 21H
        LOOP PRINT_OCTAL_NUMBER
        POP BX ; Restore contents of BX
        POP DX ; Restore contents of DX
        RET
PRINT_OCT ENDP

PRINT_BIN PROC NEAR ; This routine prints the number contained in AX in binary form
    PUSH DX ; Save contents of DX because that register will be used
    PUSH BX ; Save contents of BX because that register will be used
    MOV CX,0 ;Digit counter on CX
    BIN_DIGIT:
        MOV DX,0
        MOV BX,2D ;Divide by 2 to get the last digit as the remainder
        DIV BX
        PUSH DX ; and push it into the stack
        INC CX ; increase the digit counter
        CMP AX,0 ; while the quotient is not zero (there are more digits) repeat
        JNE BIN_DIGIT
            
    PRINT_BINARY_NUMBER: ;Once all digits are in the stack print them one by one
        POP DX
        ADD DL,30H
        MOV AH,2
        INT 21H
        LOOP PRINT_BINARY_NUMBER
        POP BX ; Restore contents of BX
        POP DX ; Restore contents of DX
        RET
PRINT_BIN ENDP

HEX_KEYB PROC NEAR ; Routine reads a hex digit and returns it as binary in AL register (Page 21 mP11_80x86_programs.pdf)
    IGNORE:

        MOV AH,8; Read from keyboard
        INT 21H
        CMP AL, 'T' ; If the character T is pressed exit the program and return control to the operating system
        JE EXIT
        CMP AL,30H ; Check if the character read is a hex digit
        JL IGNORE ; If not ignore it and read another
        CMP AL,39H
        JG ADDR1
        SUB AL,30H ; Extract the actual number converting the ASCII code ('0'=30)
        JMP ADDR2
    ADDR1:
        CMP AL,'A'
        JL IGNORE
        CMP AL,'F'
        JG IGNORE
        SUB AL,37H ; Convert HEX ASCII to a pure number ('A'=41, 41H-37H=0AH=10D)
    ADDR2: 
        RET
    EXIT:
        MOV AX, 4C00H ; Return control to the operating system
        INT 21H

HEX_KEYB ENDP

PRINT PROC NEAR
    MOV AH,2
    INT 21H
    RET
PRINT ENDP

    CODE ENDS
END MAIN    