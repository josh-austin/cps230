; Draws a diagonal line

include irvine16.inc

.data
_X word ?
_Y word ?

.code


main proc
	mov ax, @data
    mov ds, ax
	
    mov ax, 0012h ; video mode
    int 10h

    mov ax, 0a000h ; Set up the video segment
    mov es, ax
	
	mov cx, 479
L1:
	; simple diagonal line
	mov [_X], cx
	mov [_Y], cx
	
	call draw_xy 
	
	; a diagonal line where x = y / 3
	mov dx, 0
	mov bx, 3
	mov ax, [_Y]
	div bx
	mov [_X], ax
	
	call draw_xy
	
	loop L1
	
	
	exit
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
	mov ax, _Y
	mov bx, 80
	mul bx
	push ax
	
	; Clear EAX
	mov eax, 0
	
	; Take X, divide by 8, put the quotient in DI
	mov ax, _X
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
