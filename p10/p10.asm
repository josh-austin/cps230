;.model tiny
;.386
;.stack 200h

include irvine16.inc

.data
X_1 dword 19
Y_1 dword 0

X_2 dword 0
Y_2 dword 479

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

    mov ax, 0a000h      ; Set up the video segment
    mov es, ax

    mov cx, 24
    mov di, 0

L1:
    call calc_coords
		
	add [X_1], 20
	sub [Y_2], 20
	
	dec cx
	cmp cx, 0
    jne L1

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

calc_coords proc
; Description: Draws a pixel at X, Y
;     where Y = ( ( rise/run ) * X ) + 20
	pusha
	
	; STEP 1: Calculate slope (aka "M")
	mov edx, 0     ; clear EDX for the upcoming IDIV
	
	mov eax, [Y_2]
	sub eax, [Y_1]
	
	mov ebx, [X_2]
	sub ebx, [X_1]
	
	idiv ebx
	mov [_M], eax
	
	
	imul negative_one
;	mov [_M], eax
	
	; STEP 2: Calculate coordinates
	cmp [_M], 1 ; If M <= 1, then X = (Y-B) / M
	jl JLE_ONE
	cmp [_M], 0
	je J_G_ONE


J_G_ONE:
	imul negative_one
	mov eax, 0
	mov ebx, [_B]
	mov ecx, [X_1]
	add ecx, 1
	mov edx, [_M]

G_ONE:

	push eax
	mov [_X], eax
	imul edx
	add eax, ebx
	mov [_Y], eax
	
;	call dumpregs

	call draw_xy
	
	pop eax
	inc eax
	
	dec ecx
	cmp ecx, 0
	je END_ALL

jmp G_ONE

JLE_ONE:
	imul negative_one
	pusha
	
	mov ecx, [Y_2]
	add ecx, 1
	mov eax, 0
	mov ebx, [_B]
	
loopy:
	push eax
	mov edx, 0
	push ecx
	mov [_Y], eax
	mov ecx, [_M]
	sub eax, ebx
	idiv ecx
	mov [_X], eax
;call dumpregs	
	call draw_xy
	

	
	pop ecx
	pop eax
	inc eax
	dec ecx
	cmp ecx, 0
	jne loopy
	
END_ALL:
	
	popa


	
	popa
	
	add [_B], 20
	
	ret

calc_coords endp

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

