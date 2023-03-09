DATA SEGMENT
	TEN DB DUP(10)	; Store number ten in memmory in order to use it for multiplications
DATA ENDS

CODE SEGMENT
ASSUME CS:CODE, DS:DATA
MAIN PROC FAR
    START:
        MOV AX, DATA
        MOV DS, AX
        
        MOV DL,5AH ; Print 'Z'
        CALL PRINT
        MOV DL,3DH ; Print '='
        CALL PRINT
        
        CALL READ_AND_PRINT ;Read and print the decades of Z
        SUB AL,30H ; Convert from ASCII to decimal
        MUL TEN  ; Multiply the number read by 10 to construct the number Z
        MOV BL,AL
        CALL READ_AND_PRINT ;Read and print least significant decimal digit of number Z
        SUB AL,30H ; Convert from ASCII to decimal
        ADD BL,AL ; Z in BL
        
        MOV DL,20H
        CALL PRINT

        MOV DL,57H ; Print 'W'
        CALL PRINT
        MOV DL,3DH ; Print '='
        CALL PRINT
        
        CALL READ_AND_PRINT ;Read and print the decades of W
        SUB AL,30H ; Convert from ASCII to decimal
        MUL TEN  ; Multiply the number read by 10 to construct the number W
        MOV BH,AL
        CALL READ_AND_PRINT ;Read and print least significant decimal digit of number Z
        SUB AL,30H ; Convert from ASCII to decimal
        ADD BH, AL ; W in BH
        
        MOV DL, 0AH ; End of line
        MOV AH,2
        INT 21H
        MOV DL, 0DH ; Return cursor to the start of the line
        MOV AH,2
        INT 21H

        MOV DL,5AH ; Print 'Z'
        CALL PRINT
        MOV DL,2BH ; Print '+'
        CALL PRINT
        MOV DL,57H ; Print 'W'
        CALL PRINT
        MOV DL,3DH ; Print '='
        CALL PRINT

        MOV AX,0
        MOV AL, BL ; Add Z to initially 0 AL
        ADD AL, BH ; Then add W to it
        CALL PRINT_HEX ; Print the result

        MOV DL,20H ; Print ' '
        CALL PRINT 

        MOV DL,5AH ; Print 'Z'
        CALL PRINT
        MOV DL,2DH ; Print '-'
        CALL PRINT
        MOV DL,57H ; Print 'W'
        CALL PRINT
        MOV DL,3DH ; Print '='
        CALL PRINT

        MOV AH,0
        MOV AL,BL ; Move Z in AL
        SUB AL,BH ; Subtract W from Z
        JNC SKIP ; If result not negative then print it
        MOV DL,2DH ;else print a '-' in front
        CALL PRINT
        MOV AH,0 ;and calculate the opposite by moving
        MOV AL,BH ; W in AL
        SUB AL,BL ; and subtracting Z from W

    SKIP:
        CALL PRINT_HEX ; Print the result

        MOV DL, 0AH ; End of line
        MOV AH,2
        INT 21H
        MOV DL, 0DH ; Return cursor to the start of the line
        MOV AH,2
        INT 21H

        JMP START ; Repeat waiting for next input
MAIN ENDP

READ_AND_PRINT PROC NEAR
IGNORE:
    MOV AH,8
    INT 21H
    CMP AL,30H ;Check if the number is valid. If not read another one
    JL IGNORE
    CMP AL,39H
    JG IGNORE
    
    MOV DL,AL ; If it is valid print it and return
    MOV AH,2
    INT 21H

    RET
READ_AND_PRINT ENDP

PRINT PROC NEAR
    MOV AH,2
    INT 21H
    RET
PRINT ENDP

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

    CODE ENDS
END MAIN
