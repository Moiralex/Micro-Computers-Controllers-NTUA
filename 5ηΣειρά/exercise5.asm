DATA SEGMENT
	START_MSG DB "START(Y,N) :$" ; Message to be printed at the start of the program
    ERROR_MSG DB "ERROR$" ; Error message for temperatures above 1200 degrees
    SIXTEEN DB DUP(16) ; Store number sixteen in memmory in order to use it for multiplications
DATA ENDS

CODE SEGMENT
ASSUME CS:CODE, DS:DATA
MAIN PROC FAR

        MOV AX,DATA
        MOV DS,AX
        
        LEA DX,START_MSG  ; Print the start message
        MOV AH,09H
        INT 21H
        CALL READ_YN
        
    START:
        MOV DL, 0AH ; New line
        MOV AH,2
        INT 21H
        MOV DL, 0DH ; Move cursor to the start of the line
        MOV AH,2
        INT 21H
    
        CALL HEX_KEYB ;Read the most significant digit
        MOV AH, 0
        MUL SIXTEEN ;Multiply with 16*16 to start forming the 3digit hexadecimal number
        MUL SIXTEEN
        MOV BX, AX ; Add to the number

        CALL HEX_KEYB ;Read the next digit
        MOV AH, 0
        MUL SIXTEEN ;Multiply with 16 following the same logic
        ADD BX, AX ; Add to the number
        
        CALL HEX_KEYB ;Read the least significant digit
        MOV AH, 0
        ADD BX, AX ; Add to the number
        
        MOV AH,2
        MOV DL,3AH ;Print a ":" character next to the hexadecimal number you read
        INT 21H
        MOV DL,09H ;and then a tab next to it
        INT 21H
        
        ;MOV DX,0
        MOV AX, BX ;Move the number to AX to use it in the following multiplications and divisions
        CMP AX, 2048 ;If the given number is below 2048 we are in the first part of the temperature-voltage curve
        JL LINE_PART1
        CMP AX, 3072 ;IF it is between 2048 and 3071 we are in the second part
        JL LINE_PART2

    ERROR:      ; Else the temperature is above 1200 degrees and we print an error message
        LEA DX,ERROR_MSG ;Load the address of the message and print it until you find '$'
        MOV AH,09H
        INT 21H
        JMP START ;Then get a new reading
        
    LINE_PART1: ; T=reading*(4/4095)*(400/2) => T=reading*(800/4095)
        MOV BX, 8000 ; Multiply with 8000 instead of 800 to keep the first digit of the fractional part
        MUL BX ;Result is stored in DX:AX
        MOV BX, 4095 ;Divide with 4095
        DIV BX ; Quotient goes in AX and remainder in DX
        MOV DX,0 ;The remainder is of no use to us (all the digits we care about are in the quotient)
        MOV BX, 10 ; so we make DX 0 to divide the quotient with 10
        DIV BX ; And now the integer part is in AX and the first digit of the remainder in DX
            
        CALL PRINT_RESULT ;Print the result
        JMP START ; Go to the start of the program to get a new reading

    LINE_PART2: ; T=(reading*(4/4095)-2)*800+400 => T=reading*(3200/4095)-1200
        MOV BX, 32000 ;Following the same logic as before we multiply with 32000 instead of 3200
        MUL BX
        MOV BX, 4095 ;Divide by 4095
        DIV BX
        SUB AX, 12000 ;Sub 12000 instead of 1200
        MOV DX,0
        MOV BX, 10 ;Divide by 10 to seperate integer part from fractional digit
        DIV BX
            
        CALL PRINT_RESULT ;Print the result
        JMP START ; Go to the start of the program to get a new reading
        
MAIN ENDP


HEX_KEYB PROC NEAR ; Routine reads a hex digit and returns it as binary in AL register (Page 21 mP11_80x86_programs.pdf)
    IGNORE:

        MOV AH,8; Read from keyboard
        INT 21H
        CMP AL, 'N' ; If the character N is pressed exit the program and return control to the operating system
        JE EXIT
        CMP AL,30H ; Check if the character read is a hex digit
        JL IGNORE ; If not ignore it and read another
        CMP AL,39H
        JG ADDR1
        MOV AH,2 ;Print the hex digit read on the screen
        MOV DL,AL
        INT 21H
        SUB AL,30H ; Extract the actual number converting the ASCII code ('0'=30)
        JMP ADDR2
    ADDR1:
        CMP AL,'A'
        JL IGNORE
        CMP AL,'F'
        JG IGNORE
        MOV AH,2
        MOV DL,AL
        INT 21H
        SUB AL,37H ; Convert HEX ASCII to a pure number ('A'=41, 41H-37H=0AH=10D)
    ADDR2: 
        RET
    EXIT:
        MOV AX, 4C00H ; Return control to the operating system
        INT 21H

HEX_KEYB ENDP

READ_YN PROC NEAR ; This routine reads 'Y' or 'N' and determines whether the program will continue or exit
    IGNORE1:
        MOV AH,8; Read a character from the keyboard
        INT 21H
        CMP AL, 'N' ; If it is the character 'N' exit the program
        JE EXIT1
        CMP AL, 'Y' ; If it is neither 'N' or 'Y' read a new character
        JNZ IGNORE1
        MOV DL,AL ; If it is 'Y' print it and return to the main program
        MOV AH,2
        INT 21H
        RET
    EXIT1:
        MOV AX, 4C00H ; Return control to the operating system
        INT 21H
READ_YN ENDP

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

PRINT_RESULT PROC NEAR
    CALL PRINT_DEC ;Print the integer part
    MOV BX,DX ;Save contents of DX because we use the register in the later print
    MOV DL,46 ;Print the "."
    MOV AH,2
    INT 21H
    MOV AX,BX ;Move the fractional digit on AX and print it
    CALL PRINT_DEC
    RET
PRINT_RESULT ENDP
CODE ENDS
END MAIN