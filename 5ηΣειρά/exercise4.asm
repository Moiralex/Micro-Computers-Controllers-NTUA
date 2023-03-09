DATA SEGMENT
    LETTERS DB 20 DUP(?) ; Table to store the letters read
    NUMBERS DB 20 DUP(?) ; Table to store the numbers read
    
    LETTER_INDEX DW DUP(0) ; Index to iterate through letter table
	NUMBER_INDEX DW DUP(0) ; Index to iterate through number table
DATA ENDS

CODE SEGMENT
ASSUME CS:CODE, DS:DATA
MAIN PROC FAR
    START:
        MOV AX,DATA
        MOV DS,AX

        MOV CX,20 ; A maximum of 20 characters will be read
        MOV LETTER_INDEX,0 ; Set the index of the letter table to 0
        MOV NUMBER_INDEX,0 ; Set the index of the number table to 0
    INPUT:
        CALL READ ; Read characters
        LOOP INPUT ; Loop 20 times or until ENTER is pressed and the READ routine breaks the loop

        MOV DL, 0AH ; End of line
        MOV AH,2
        INT 21H
        MOV DL, 0DH ;  Move cursor to the start of the line
        MOV AH,2
        INT 21H

    CALL PRINT_LETTERS ; Print all the letters read capitalized
    CALL PRINT_DASH ; Print a dash between letters and numbers (will only be printed if both letters and numbers were read)
    CALL PRINT_NUMBERS ; Print all the numbers read    
        
    
    MOV DL, 0AH ; End of line
    MOV AH,2
    INT 21H
    MOV DL, 0DH ; Move cursor to the start of the line
    MOV AH,2
    INT 21H
    JMP START ; Restart and wait next input
        
MAIN ENDP

READ PROC NEAR ; Routine for reading a lower-case letter or number from keyboard.
    PUSH DX ; Temporarily store DX
    MOV BX,0
IGNORE:
    MOV AH,8; Διάβασε τον χαρακτήρα από το πληκτρολόγιο
    INT 21H
    CMP AL, 3DH ; Check if the character read is '=' in which case stop the program and return control to the OS
    JZ EQUAL_KEY
    CMP AL, 0DH ; Check if ENTER was pressed in which case stop reading characters
    JZ ENTER_KEY
    CMP AL,30H ; Check if character is a digit
    JL IGNORE ; If not, ignore it and read another
    CMP AL,39H
    JG LETTER
    JMP NUMBER
LETTER:
    CMP AL,'a' ; Check if the character read is a valid lower-case letter
    JL IGNORE
    CMP AL,'z'
    JG IGNORE
    MOV DL, AL
    CALL PRINT ; If yes print it
    MOV DI,LETTER_INDEX
    MOV LETTERS[DI], AL ; Store it in the letter table in the position where LETTER_INDEX is pointing
    INC LETTER_INDEX ; Increase the LETTER_INDEX
    POP DX
    RET
NUMBER:
    MOV DL,AL
    CALL PRINT
    MOV DI, NUMBER_INDEX 
    MOV NUMBERS[DI], AL ; If it is a number store it in the number table in the position where NUMBER_INDEX is pointing
    INC NUMBER_INDEX ; Increase the NUMBER_INDEX
    POP DX ; Restore contents of DX
    RET
ENTER_KEY:
    POP DX ; Restore contents of DX
    MOV CX,1 ; Set CX to 1 in order to break the loop that reads characters
    RET
EQUAL_KEY:
    MOV AX, 4C00H ; Return control to the OS
    INT 21H

READ ENDP

PRINT PROC NEAR
    MOV AH,2
    INT 21H
    RET
PRINT ENDP

PRINT_LETTERS PROC NEAR
    MOV CX, LETTER_INDEX ; Move LETTER_INDEX to CX in order to print all the letters using loop
    CMP CX,0 ; If the LETTER_INDEX is 0 (there are no letters) return
    JE END_LETTERS
    MOV DI,0
    PRINT_LETTER:
        MOV DL, LETTERS[DI] ; else iterate through the letter table and move current letter to DL
        SUB DL, 20H ; Capitalize the letter
        CALL PRINT ;and print it
        INC DI
        LOOP PRINT_LETTER ; Continue until all letters read are printed
    END_LETTERS:
        RET
PRINT_LETTERS ENDP

PRINT_DASH PROC NEAR ; Print the '-' only if both numbers and letters are read
    CMP LETTER_INDEX, 0 ; If the LETTER_INDEX is 0 (there are no letters) return without printing '-'
    JE NO_DASH
    CMP NUMBER_INDEX, 0 ; If the NUMBER_INDEX is 0 (there are no numbers) return without printing '-'
    JE NO_DASH
    
    MOV DL,2DH ; If both letters and numbers were read print the '-'
    MOV AH,2
    INT 21H

    NO_DASH:
        RET
PRINT_DASH ENDP
    
PRINT_NUMBERS PROC NEAR
    MOV CX, NUMBER_INDEX ; Move NUMBER_INDEX to CX in order to print all the numbers using loop
    CMP CX,0 ; If the NUMBER_INDEX is 0 (there are no numbers) return
    JE END_NUMBERS
    MOV DI,0
    PRINT_NUM:
        MOV DL, NUMBERS[DI] ; else iterate through the number table and move current number to DL
        CALL PRINT ;and print it
        INC DI
        LOOP PRINT_NUM ; Continue until all numbers read are printed
    END_NUMBERS:
        RET
PRINT_NUMBERS ENDP
    CODE ENDS
END MAIN  