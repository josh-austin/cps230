; 		   Program: CpS 230 Program 10 - Drawing Lines
; 	   Description: Program will draw 24 lines on the screen in a
;					predetermined pattern
; 			Author: Cameron Thacker, Josh Austin, Ashley Lane
; 			 Notes: 
;    Help Received: (None)

.model tiny
.386
.stack 200h

.data
X_1 dword 0
Y_1 dword 19

X_2 dword 479
Y_2 dword 0

_B dword 19
_M dword ?
_Y dword ?
_X dword ?

negative_one dword 0FFFFFFFFh

.code
main proc
    mov ax, @data
    mov ds, ax

    mov ax, 0012h
    int 10h

    mov ax, 0a000h      
    mov es, ax				; Set up the video segment
	

    mov cx, 24
    mov di, 0

; Set up for first loop to run through the equation y = mx + b
L1:
	push cx
    call calc_coords
	pop cx
	add [Y_1], 20
	sub [X_2], 20
	
	dec cx
	cmp cx, 0
    jne L1

; Set up for second loop to run through the equation x = (y - b) / m
	mov [_B], 19
	mov cx, 24
	mov di, 0 
	mov [Y_1], 19
	mov [X_2], 479
L2:
	push cx
	call calc_coords_2
	pop cx
	add [_B], 20
	add [Y_1], 20
	sub [X_2], 20
	
	dec cx
	cmp cx, 0
	jne L2


    mov ax, 4c00h
    int 21h             ; Terminate
main endp



; Function: Draws a white pixel at (Y,X)
; Receives: _Y and _X in the data segment
;  Returns: Nothing
; Requires: Nothing
; Clobbers: Nothing
draw_xy proc
	
	pusha
	
	; Clear EAX
	mov eax, 0

	; Take Y, multiply by 80 to go to the row we want to draw on, 
	; and then push this number on the stack for later
	mov eax, _Y
	mov bx, 80
	mul bx
	push ax
	
	; Clear EAX
	mov eax, 0
	
	; Take X, divide by 8, put the quotient in DI
	mov eax, _X
	mov bx, 8
	div bx
	mov di, ax
	
	; Add the Y*80 that's in the stack to DI
	pop bx
	add di, bx
	
	; Set the bit mask with the remainder; put in AX
	mov cx, dx
	add cx, 1
	mov ax, 1
	
SHL1:
	ror al, 1
	loop SHL1
	
	; Clear EBX
	mov ebx, 0
	; Set color to white
	mov bl, 0Fh
	
	; Draw it
	call write_color
	
	popa
	ret
draw_xy endp

; Function: Calculates the coordinates and calls draw_xy to draw the pixel at that coordinate
;			this uses the function y = mx + b
; Receives: X_2 and Y_1 from memory
;  Returns: Returns y and x value in the _Y and _X memory slots
; Requires: nothing
; Clobbers: nothing
calc_coords proc
	pusha
	
JL_ONE:					; y = mx + b
	mov eax, 0			; set x = 0 for the first point the increment after each run through loop
	mov ecx, [X_2]		; sets the counter equal to value of the X_2 value
	add ecx, 1
	mov edx, [Y_1]		; set EDX = RISE

L_ONE:

	push eax
	push ecx
	mov [_X], eax		; set _X = EAX
	push edx
	neg edx
	imul edx			; EAX = (RISE)x

	mov ecx, [X_2]		; ECX = RUN
	idiv ecx			; EAX = (RISE)x / (RUN)

	pop edx
	pop ecx			
	add eax, [Y_1]		; EAX = mx + b
	mov [_Y], eax		; moves EAX value into _Y slot in memory

	call draw_xy
	
	pop eax
	inc eax
	
	dec ecx
	cmp ecx, 0
	je END_ALL

jmp L_ONE

END_ALL:
	popa
	
	add [_B], 20		; add 20 to B to mark the next y-intercept
	
	ret

calc_coords endp

; Function: Calculates the coordinates and calls draw_xy to draw the pixel at that coordinate
;			this uses the funciton x = (y - b) / m
; Receives: X_2 and Y_1 from memory
;  Returns: x and y values in the _X and _Y memory slots
; Requires: nothing
; Clobbers: nothing
calc_coords_2 proc

JG_ONE:					; x = (y - b) / m
	pusha
	
	mov ecx, [Y_1]		; set counter equal to Y_1 value to determine the length of the line
	add ecx, 1			
	mov eax, 0			; start from y = 0
	mov ebx, [Y_1]		; move "b" value into EBX register
	
loopy:
	push eax
	push ecx
	mov ebx, [Y_1]		; RESET EBX
	
	mov [_Y], eax		; set y = 0 initially then increments after each run through the loop
	sub eax, ebx		; (y - b)	
	mov ebx, [X_2]

	mov edx, 0
	imul ebx			; EAX = (y - b)(RUN)

	mov ecx, [Y_1]
	neg ecx
	
	idiv ecx			; EAX = ((y - b)(RUN)) / (RISE)
	mov [_X], eax		; move the calculated x-value into the _X memory slot

	call draw_xy		; using the _X and _Y values, mark the point on the line
	
	pop ecx
	pop eax
	inc eax
	
	dec ecx
	cmp ecx, 0
	jne loopy
	
	popa
	ret
calc_coords_2 endp

; Description: Set pixels to a color
; Receives:    al = bit(s) within byte to set the color for
;           es:di = byte address within video memory
;              bl = color (0 - 0fh)
; Returns: nothing
; Requires: nothing
; Clobbers: nothing
write_color proc
    pusha
    mov  dx, 3ceh
    mov  ah, al
    mov  al, 8
    out  dx, ax                 ; Set the color
    mov  ax, 0205h              ; Set write mode 2
    out  dx, ax
    mov  ax, 0003h              ; Set replace mode
    out  dx, ax
    mov  dl, byte ptr es:[di]   ; dummy read
    mov  byte ptr es:[di], bl   ; write the color
    popa
    ret
write_color endp

end main