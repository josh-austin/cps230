.model tiny
.386
.code
org 7c00h			; code here starts at offset 7c00h

main proc
	mov ax, cs
	mov ss, ax
	mov sp, 0
	mov ds, ax
<<<<<<< HEAD
	;mov dx, offset mystring
	;call print_string
	mov ah, 02
=======
	mov dx, offset mystring
	call print_line
	mov ah, 02h
>>>>>>> 918e3cbe278468b667db195f80b4c19d720a571c
	mov ch, 0
	mov cl, 2
	mov al, 40
	
	mov dx, 0000h
	mov es, dx
	mov dh, 0
	mov dl, 0
	mov bx, 0800h
	
	int 13h
	; if CF flag is set, print error
	
	jnc happy
	mov dx, offset errmsg
	call print_line
happy:
	
<<<<<<< HEAD
	jc all_good
	mov dx, offset errorstr
	call print_string
	jmp Past_it_all
all_good:
	
	pushw 0800h
	pushw 0000h
	retf
	
	jmp Past_it_all
=======
	pushw 0800h
	pushw 0000h
	retf
>>>>>>> 918e3cbe278468b667db195f80b4c19d720a571c

main endp

jmp Past_it_all

mystring byte "Booting...", 0dh, 0ah, 0
<<<<<<< HEAD
errorstr byte "Something went wrong...", 0
=======
errmsg byte "Oops!", 0
>>>>>>> 918e3cbe278468b667db195f80b4c19d720a571c

; Function: Prints the ASCII string of a byte array, plus a newline (\r\n), to the screen in green via BIOS
; Receives: DX
; Requires: Nothing
;  Returns: Nothing
; Clobbers: Nothing
print_line proc
	pusha
<<<<<<< HEAD
=======

	mov si, 0
>>>>>>> 918e3cbe278468b667db195f80b4c19d720a571c
	mov bx, dx

	printloop:
		mov al, [bx + si] ; put the next piece of the array into AL
		cmp al, 0
		jz endprint
		mov ah, 0Eh   ; 0Eh in BIOS means print character 
		push bx
		mov bl, 0010b ; Set foreground color to green
		int 10h		  ; BIOS interrupt
		pop bx
		inc si
		jmp printloop
	endprint:
		mov  ax, 0e0dh
		int  10h
		mov  al, 0ah
		int  10h
		popa
		ret
print_line endp

Past_it_all:
	
org main+510
	byte 055h, 0aah
	
end main