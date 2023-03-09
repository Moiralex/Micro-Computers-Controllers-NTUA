DATA SEGMENT
	TABLE DB 128 DUP(?) ;Allocate uninitialized memmory for table to store the numbers in
	TWO DB DUP(2)		;Store number two in memmory to use it for divisions
DATA ENDS

CODE SEGMENT
	ASSUME CS:CODE, DS:DATA

	MAIN PROC FAR
        MOV AX,DATA
		MOV DS,AX
        
        MOV DI,0 ;Array index
        MOV CX,128 ; # of numbers to be stored

    STORENUMS:
        MOV TABLE[DI], CL ; Store the number contained in CL in the table (CL instead of CX because we store bytes)
        INC DI ; Increase the index
        LOOP STORENUMS ; Repeat until all the numbers are stored. LOOP will decrease the value of CX by 1 so we will store the correct number next
        
        
        MOV DX,0 ; Sum of all odd numbers in DX
        MOV BX,0 ; # of odd numbers
        MOV DI,0 ; Array index
        MOV CX,128 ; # of numbers to be checked
    AVERAGE:
        MOV AH,0
        MOV AL,TABLE[DI] 
        DIV TWO ; Divide the number that is being checked by 2
        CMP AH,0 ; If it is even (remainder in AH=0) move to the next number
        JE SKIP
        MOV AL,TABLE[DI]
        MOV AH,0
        ADD DX,AX ; If it is odd add it to the sum of all odds
        INC BX ; Increase the odd number count
    SKIP:
        INC DI ; Next number (array index += 1)
        LOOP AVERAGE ; Loop until all numbers have been checked

        MOV AX,DX ; Move the sum of all odd numbers to AX in order to divide it
        MOV DX,0 ; Set DX to 0 because we will divide with 16bit source to get 16bit result
        DIV BX ; Divide by the count of all odd numbers to get the average
        
    ; Print the result in decimal form
        MOV CX,0
    DIGIT:
        MOV DX,0 ;Digit counter on CX
        MOV BX,10 ;Divide by 10 to get the last digit as the remainder
        DIV BX
        PUSH DX ; and push it into the stack
        INC CX ; increase the digit counter
        CMP AX,0 ; while the quotient is not zero (there are more digits) repeat
        JNE DIGIT
        
    PRINT_DECIMAL_NUMBER: ;Once all digits are in the stack print them one by one
        POP DX
        ADD DL,30H
        MOV AH,2
        INT 21H
        LOOP PRINT_DECIMAL_NUMBER


        MOV DL, 0AH ; New line
        MOV AH,2
        INT 21H
        MOV DL, 0DH ; REturn cursor to the start of the line
        MOV AH,2
        INT 21H

        MOV BH,TABLE[0] ;Initialize max
        MOV BL,TABLE[0] ;Initialize min
        MOV DI,1   ; Index on second element of table in order to compare with the rest of the 127 numbers
        MOV CX,127 ; 127 numbers to check
    FINDMAXMIN:
        MOV AL,TABLE[DI] ; If the element checked is greater than the current max change the current max
        CMP BH, AL
        JNC CHANGEMAX
        CMP BL, AL ; If the element checked is less than the current min change the current min
        JC CHANGEMIN
    NEXT_ITER:
        INC DI ; Check the next element
        LOOP FINDMAXMIN ; Repeat until all elements are checked
        JMP PRINT_MAX_MIN ; Print the results

    CHANGEMAX:
        MOV BH, AL
        JMP NEXT_ITER

    CHANGEMIN:
        MOV BL,AL
        JMP NEXT_ITER

    PRINT_MAX_MIN:
        MOV DL, BH ; For the max
        AND DL, 0F0H ; Isolate the 4 most significant digits of the number
        MOV CL, 4
        RCR DL, CL ; Move them to the 4 least significant positions
        CALL PRINT_HEX ; Print them as one hexadecimal digit
        MOV DL, BH ; Isolate the 4 least significant digits and print them as another hex number
        AND DL, 0FH 
        CALL PRINT_HEX
        
        MOV DL,20H ; Print " "
        MOV AH,2
        INT 21H
        
        MOV DL, BL ; For the min
        AND DL, 0F0H ; Isolate the 4 most significant digits of the number
        MOV CL, 4
        RCR DL, CL ; Move them to the 4 least significant positions
        CALL PRINT_HEX ; Print them as one hexadecimal digit
        MOV DL, BL ; Isolate the 4 least significant digits and print them as another hex number
        AND DL, 0FH
        CALL PRINT_HEX
    
        MOV AX, 4C00H ; Exit the program and return control to the operating system
        INT 21H
MAIN ENDP

PRINT_HEX PROC NEAR
        CMP DL, 9 ; If the number is between 0 and 9 add the value 30H ('0'=30H).
        JG ADDR1
        ADD DL, 30H
        JMP ADDR2
    ADDR1:
        ADD DL, 37H ; else add the value 37H ('A'=41H).
    ADDR2:
        MOV AH,2
        INT 21H
        RET
PRINT_HEX ENDP
    CODE ENDS
END MAIN