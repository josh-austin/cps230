TITLE Non-Preemptive Kernel (npk.asm)
; Author: Joshua Austin
.model tiny
.386
.stack 400h

;include irvine16.inc

.data
	numchars    byte '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'
	placeholder byte ?
	greeting    byte ">>>>     ROUNDROBIN KERNEL     <<<<", 0
	description byte "Description: Just another non-preemptive kernel proof-of-concept", 0
	authors     byte "Authors:     Ashley Lane, Cameron Thacker, Joshua Austin", 0
	
	stack_segment_low word 0FFFFh
	stack_main_segment word ?
	
	registered_functions byte 0
	
	demoproc1intro byte "'demoproc1' is waking up", 0
	demoproc1extro byte "'demoproc1' is going to sleep", 0
	
	demoproc2intro byte "'demoproc2' is waking up", 0
	demoproc2extro byte "'demoproc2' is going to sleep", 0
	
	demoproc3intro byte "'demoproc3' is waking up", 0
	demoproc3extro byte "'demoproc3' is going to sleep", 0
	
	demoproc4intro byte "'demoproc4' is waking up", 0
	demoproc4extro byte "'demoproc4' is going to sleep", 0
	
	yield byte "NPK_YIELD", 0

.code
; Function: Prints the ASCII string of a byte array to the screen via BIOS
; Receives: DX
;  Returns: Nothing
; Requires: Nothing
; Clobbers: Nothing
print_string PROC
	pusha

	mov si, 0
	mov bx, dx

	loop_printstring:
		mov al, [bx + si] ; put the next piece of the array into AL
		cmp al, 0
		jz exit_printstring
		push bx
		mov bl, 0010b	; Set foreground color to green
		mov ah, 0Eh		; 0Eh in BIOS means print character 
		int 10h			; BIOS interrupt
		pop bx
		inc si
		jmp loop_printstring

	exit_printstring:
		popa
		ret
print_string ENDP


; Function: Prints a character in AL to console output
; Receives: ASCII value in AL
; Requires: Nothing
;  Returns: Nothing
; Clobbers: Nothing
print_char proc
	mov ah, 0Eh ; write character
	int 10h     ; video interrupt
	ret
print_char endp


; Function: Outputs a return carriage and line feed to the console
; Receives: Nothing
; Requires: Nothing
;  Returns: Nothing
; Clobbers: Nothing
print_newline proc
	push ax
    mov  ax, 0e0dh
    int  10h
    mov  al, 0ah
    int  10h
    pop  ax
    ret
print_newline endp


; Function: Prints a number base representation to console
; Receives: Base number in EBX, represented number in EAX
; Requires: Nothing
;  Returns: Nothing
; Clobbers: Nothing
print_number_by_base proc
	pusha
	mov cx, 0

	; loop till the quotient is 0
	divvy_it_up_guys:
		div bl

		mov [placeholder], al   ; put quotient in memory for later 

		movzx si, ah
		mov al, [numchars + si] ; SI is the index for the numeric char we want to print
		push ax
		inc cx

		mov al, [placeholder]   ; bring back the quotient for dividing by BX if the jump continues
		movzx ax, al            ; we need to remove the remainder from AH

		cmp ax, 0
		
		je  give_us_the_chars
		jne divvy_it_up_guys

	; print out the chars in the stack
	give_us_the_chars:
		pop ax
		call print_char
		loop give_us_the_chars

	popa
	ret
print_number_by_base endp


; Function: Prints an unsigned base ten representation of AX to console
; Receives: Number to represent in AX
; Requires: Nothing
;  Returns: Nothing
; Clobbers: Nothing
print_unsigned_decimal proc
	push ebx
	mov ebx, 10
	call print_number_by_base
	pop ebx
	ret
print_unsigned_decimal endp


; Function: Demo process that counts down from 10 to 1
; Receives: Nothing
; Requires: Nothing
;  Returns: Nothing
; Clobbers: Nothing
demoproc1 proc
	mov dx, offset demoproc1intro
	call print_string
	call print_newline
	mov cx, 10
	
	L1:
		mov ax, cx
		call print_unsigned_decimal
		call print_newline
		push cx
		; Pause for 1 second so the viewer can read the output
		mov cx, 0Fh
		mov dx, 4240h
		mov ah, 86h
		int 15h
		pop cx
		loop L1
		
	mov dx, offset demoproc1extro
	call print_string
	call print_newline
	
	;call npk_yield
	
	; Pause for 1 second so the viewer can read the output
	mov cx, 0Fh
	mov dx, 4240h
	mov ah, 86h
	int 15h
	
	pushw offset demoproc2
	ret
demoproc1 endp


; Function: Demo process that counts down from 5 to 1
; Receives: Nothing
; Requires: Nothing
;  Returns: Nothing
; Clobbers: Nothing
demoproc2 proc
	mov dx, offset demoproc2intro
	call print_string
	call print_newline
	mov cx, 5
	
	L2:
		mov ax, cx
		call print_unsigned_decimal
		call print_newline
		push cx
		; Pause for 1 second so the viewer can read the output
		mov cx, 0Fh
		mov dx, 4240h
		mov ah, 86h
		int 15h
		pop cx
		loop L2
		
	mov dx, offset demoproc2extro
	call print_string
	call print_newline
	
	;call npk_yield
	; Pause for 1 second so the viewer can read the output
	mov cx, 0Fh
	mov dx, 4240h
	mov ah, 86h
	int 15h
	
	pushw offset demoproc1
	ret
demoproc2 endp


; Function: Registers a function address and stack segment
; Receives: Function offset in AX
; Requires: Nothing
;  Returns: Nothing
; Clobbers: Nothing
npk_register_function proc
	; Register the current function's address into the previous function's stack segment
	sub stack_segment_low, 0100h
	mov ss, stack_segment_low
	push ax
	
	; Register the first function's address into the current function's stack segment
	;mov ss, 00000FEFFh
	pop ax
	push ax
	mov ss, stack_segment_low
	push ax
	
	; Let's go back to the main runner's stack segment, shall we?
	mov ss, stack_main_segment
	ret
npk_register_function endp


; Function: Yields execution to the next registered NPK function
; Receives: Nothing
; Requires: Nothing
;  Returns: Nothing
; Clobbers: Nothing
npk_yield proc
	; Tell the user the NPK YIELD event is happening
	mov dx, offset yield
	call print_string
	call print_newline
	
	; Pause for 1 second so the viewer can read the output
	mov cx, 0Fh
	mov dx, 4240h
	mov ah, 86h
	int 15h
	
	; TODO: Store registers in the current stack segment
	
	; TODO: Point to the next stack segment
	
	; Point to the next function address
	pop ax
	push ax
	mov ss, ax
	
	; "Yield" to the next function
	ret
npk_yield endp


; Function: Begins execution of the NPK
; Receives: Nothing
; Requires: Nothing
;  Returns: Nothing
; Clobbers: Nothing
npk_start_execution proc
	; Set up the data segment
	mov ax, @data
	mov ds, ax
	
	; Activate VGA (640x480) mode
	mov ah, 00h
	mov al, 12h
	int 10h
	
	; Greeting, etc.
	mov edx, offset greeting
	call print_string
	call print_newline
	
	mov edx, offset description
	call print_string
	call print_newline
	
	mov edx, offset authors
	call print_string
	call print_newline
	
	; Register functions <--UNTESTED AND UNFINISHED!
	;mov ax, offset demoproc1
	;mov stack_main_segment, ss
	;call npk_register_proc
	
	;mov ax, offset demoproc2
	;mov stack_main_segment, ss
	;call npk_register_proc
	
	; Let the fun begin! <--UNTESTED!
	;mov ax, offset demoproc1
	;pushw ax
	;ret
	
	call demoproc1
	
	mov ax, 4c00h
    int 21h ; Terminate
npk_start_execution endp

end npk_start_execution