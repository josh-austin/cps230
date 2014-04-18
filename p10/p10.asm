.model tiny
.386
.stack 200h
.data
X_1 dword 19
Y_1 dword 0

X_2 dword 0
Y_2 dword 479

_B dword 20
_M dword ?
_Y dword ?
_X dword ?

.code
main proc
    mov ax, @data
    mov ds, ax

    mov ax, 0012h
    int 10h

    mov ax, 0a000h      ; Set up the video segment
    mov es, ax

    mov cx, 479
    mov di, 0

L1:
    mov al, 09h         ; Set bit 0 and bit 3
    mov bl, 0Fh         ; white
    call write_color

    add di, 80

    loop L1

    mov ax, 4c00h
    int 21h             ; Terminate
main endp

calc_coords proc
; Description: Draws a pixel at X, Y
;     where Y = ( ( rise/run ) * X ) + 20
	pusha
	
	; STEP 1: Calculate slope (aka "M")
	mov edx, 0     ; clear EDX for the upcoming IDIV
	
	mov eax, [Y_2]
	sub eax, [Y_1]
	
	mov ebx, [X_2]
	sub ecx, [X_1]
	
	idiv ebx
	mov [_M], eax
	
	; STEP 2: Calculate coordinates
	cmp [_M], 1 ; If M <= 1, then X = (Y-B) / M
	jle JLE_ONE
	
	; Otherwise Y = (MX) + B	
	mov eax, [_M]
	mov ebx, [_X]
	
	imul ebx
	add ebx, [_B]
	mov [_Y], ebx
	
	popa
	ret

JLE_ONE:
	mov eax, [_Y]
	sub eax, [_B]
	mov ebx, [_M]
	idiv ebx
	mov [_X], ebx
	
	popa
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

