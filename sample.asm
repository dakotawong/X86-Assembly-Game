; ***********************************

; First, some assembler directives that tell the assembler:
; - assume a small code space
; - use a 100h size stack (a type of temporary storage)
; - output opcodes for the 386 processor
.MODEL small
.STACK 100h
.386

; Next, begin a data section
.data
	msg DB "CHONKER TERMINATED", 0	; first msg
	nSize DW ($ - msg)-1

	; A randomly generated set of numbers that will be used randomize rock placement
    random DB 2, 3, 9, 14, 17, 27, 40, 48, 49, 54, 55, 56, 57, 58, 63, 64, 70, 71, 74, 78
    	   DB 1, 7, 8, 12, 30, 35, 37, 38, 41, 42, 46, 57, 60, 61, 64, 69, 72, 73, 76, 79
    	   DB 16, 19, 20, 22, 23, 25, 28, 29, 36, 43, 44, 46, 47, 53, 64, 69, 70, 71, 73, 78
    	   DB 10, 13, 19, 22, 25, 31, 35, 41, 47, 52, 53, 54, 55, 60, 63, 66, 72, 73, 74, 78
    	   DB 2, 3, 4, 6, 13, 15, 23, 26, 32, 37, 43, 47, 51, 59, 60, 62, 64, 72, 75, 77
    	   DB 18, 19, 21, 22, 26, 30, 31, 43, 52, 53, 55, 59, 60, 64, 65, 67, 72, 76, 77, 79
    	   DB 1, 2, 5, 6, 7, 9, 14, 20, 27, 28, 38, 42, 43, 44, 45, 52, 55, 61, 76, 79
    	   DB 4, 5, 6, 7, 9, 11, 12, 13, 17, 20, 24, 26, 38, 45, 52, 62, 68, 69, 75, 79
    	   DB 0, 1, 2, 4, 7, 13, 22, 23, 27, 28, 29, 33, 35, 41, 43, 55, 65, 70, 74, 77
    	   DB 0, 13, 14, 19, 21, 26, 29, 36, 37, 40, 42, 55, 58, 61, 62, 66, 68, 69, 70, 71
    	   DB 6, 11, 27, 28, 30, 34, 37, 41, 45, 48, 52, 53, 58, 59, 69, 70, 74, 75, 77, 78
    	   DB 1, 3, 10, 16, 23, 26, 30, 33, 34, 39, 43, 55, 56, 59, 60, 64, 70, 73, 75, 78
    	   DB 4, 7, 8, 9, 10, 23, 25, 29, 31, 33, 38, 51, 54, 59, 62, 65, 69, 75, 78, 79
    	   DB 0, 7, 13, 16, 17, 20, 22, 26, 27, 31, 33, 34, 39, 40, 41, 49, 50, 70, 74, 75
    	   DB 0, 2, 5, 16, 17, 19, 25, 39, 41, 48, 51, 54, 55, 62, 64, 65, 66, 69, 73, 79
    	   DB 1, 7, 11, 15, 20, 23, 26, 29, 41, 42, 44, 55, 57, 60, 61, 65, 70, 73, 74, 75
    	   DB 1, 2, 8, 17, 18, 20, 21, 29, 33, 36, 39, 42, 48, 57, 58, 68, 71, 72, 73, 77
    	   DB 0, 1, 2, 6, 9, 11, 14, 20, 23, 26, 27, 30, 34, 38, 42, 55, 68, 72, 73, 77
    	   DB 2, 4, 6, 9, 12, 14, 15, 16, 17, 22, 33, 34, 42, 45, 46, 54, 61, 76, 78, 79
    	   DB 0, 2, 4, 8, 10, 13, 15, 27, 33, 39, 41, 49, 53, 56, 57, 63, 66, 69, 72, 77

	rSize DW ($ - random)-1		; Size of the random set of numbers

	rock_counter DW 0 			; Counts the number of rocks placed

	xpostion DB 28h				; Stores the column position of the chonker
	
.code

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedures to reduce repetitive code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This procedure creates a 0.1 second delay.
delay proc
	MOV CX, 01h
	MOV DX, 86A0h
	MOV AH, 86h
	INT 15h	; 1 seconds delay	
	RET
delay ENDP

; Sets the cursor to the positon of the chonker
move_cursor proc
	mov dl, xpostion		; Sets the column
	mov dh, 0Ch				; Sets the row to 12
	mov bh, 0h				; Sets the page to zero
	mov ah, 02h				; Function code for Set Cursor Position
	int 10h
	RET					
move_cursor ENDP

; Draws a tunnel at the current cursor position
draw_tunnel proc
	mov al, 'X'				; Character to be printed
	mov bh, 0h				; Setting the page number
	mov bl, 07h				; Setting the Color
	mov cx, 01h				; Number of times to print the character
	mov ah, 09h				; Function Code to Write a Character at the Cursor Location
	int 10h
	RET
draw_tunnel ENDP

; Draws a chonker at the current cursor position
draw_chonker proc
	mov al, '#'				; Character to be printed
	mov bh, 0h				; Setting the page number
	mov bl, 07h				; Setting the Color
	mov cx, 01h				; Number of times to print the character
	mov ah, 09h				; Function Code to Write a Character at the Cursor Location
	int 10h
	RET
draw_chonker ENDP

; Clears the screen
clear_screen proc
	mov ah, 0h
	mov al, 03h
	int 10h
	RET
clear_screen ENDP	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Main Procedure
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

_main PROC

; First, set various registers 
; It's important to set the segment registers.
	MOV DX, @data
	MOV DS, DX

; Clear the screen.
	call clear_screen

; Start of the game loop
OuterLoop:	

; Draw the Tunnel
	call draw_tunnel

; draw some rocks
	xor DI, DI				; Clearing the DI register
	xor SI, SI				; Clearing the SI register
	mov SI, rock_counter	; Moving the rock_counter into SI
RockLoop:
	; Moving the cursor to a random spot on the bottom line
	; to draw a rock
	mov dl, [random+SI]		; Iterating the random number set
	mov dh, 18h				; Setting the row (Bottom Row)
	mov bh, 0h				; Setting the page
	mov ah, 02h				; Function code to set the cursor postition
	int 10h

	; Draw a rock
	mov al, 'R'				; Moving the ASCII code for the rock to the register
	mov bh, 0h				; Setting the page
	mov bl, 03h				; Setting the color of the rocks
	mov CX, 01h				; Printing one rock per interrupt request
	mov ah, 09h
	int 10h

	inc SI					; Incrementing the total rock count
	inc DI					; Incrementing the loop count
	cmp DI, 4				; Only 5 rocks are placed per row (0 to 4 is 5 loops that each place 1 rock)
	jle RockLoop

	mov rock_counter, SI	; Checking that the total rocks placed does not exceed the number of random numbers in the set
	cmp rSize, SI
	jle reset_counter		; If the total rocks placed exceed the total random numbers reset the counter (start at the begining again)

done_rest:

	call move_cursor		; Reset the cursor to the location of the chonker

; scroll the screen
	mov ah, 06h
	mov al, 1				; Scroll one line
	mov ch, 0				; Setting upper row index
	mov cl, 0				; Setting upper column index
	mov dh, 24				; Setting lower row index
	mov dl, 79				; Setting lower column index
	int 10h

; see if a rock hit the chonker
	call move_cursor		; Update cursor location
	mov ah, 08h				; Function Code to read the attribute at the cursor location 
	int 10h
	cmp al, 'R'				; If there is a 'R' at the new cursor location terminate the chonker
	je terminate

; if chonker is safe, draw the chonker
	call draw_chonker

; We wait 0.1 second.	
	CALL delay

; Checking for keypresses

;CHECK IF KEY WAS PRESSED.
	mov ah, 0bh
  	int 21h      ;RETURNS AL=0 if NO KEY PRESSED otherwise AL!=0 if KEY PRESSED.
  	cmp al, 0
  	je  noKey

;PROCESS KEY.        

; Handling Key press
	mov ah, 0h
	int 16h
	cmp al, 'q'		; Quitting the program
	je terminate
	cmp al, 'a'		; Moving the chonker left
	je moveleft		
	cmp al, 's'		; Moving the chonker right
	je moveright

noKey:

	JMP OuterLoop 	; Repeat the loop

moveleft:
; Moving left on the screen.
	SUB xpostion, 1
	JMP OuterLoop

moveright:
; Moving right on the screen.
	INC xpostion
	JMP OuterLoop

reset_counter:		; Reseting the Random set index
	mov rock_counter, 0
	JMP done_rest

terminate:
; An INT call exists to print a string (about the Chonker being terminated).
; Printing the msg
	mov AH, 13h			; Write string Function Code
	mov AL, 1			; Setting the write mode
	mov BH, 0			; Setting the page number
	mov BL, 4			; Setting the colo
	mov CX, nSize		; Number of characters in the string
	MOV DX, @data		; Setting base segment of the string
	MOV ES, DX
	mov DH, 18h			; Setting the row (bottom row)
	mov DL, 1Eh			; Setting the Column (center of the window)
	MOV BP, OFFSET msg	; Setting the offset of the string 
	int 10h
; exit the program.
	MOV AX, 4C00h
	INT 21h
_main ENDP
END _main

