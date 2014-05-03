.model tiny
.386
.code
org 7c00h						; code here starts at offset 7c00h

main proc
	mov ax, cs					; Set CS = SS = DS
	mov ss, ax
	mov ds, ax
	
	mov sp, 0	;I BELIEVE THIS IS CAUSING AN ERROR

	mov dx, offset mystring		; Print the "Booting..." message
	call print_line
	
	mov cl, 2					; Set the Current sector = 2
	mov al, 40					; Set the number of sectors to read = 40
	
	mov dx, 0800h				; Move into ES register segment 0000h
	mov es, dx
	mov bx, 0000h				; Move into BX register offset 0800h
	
	mov ch, 0					; Set the Cylinder = 0
	mov dh, 0					; Set Head = 0
	mov dl, 0					; Set Drive = 0
	mov ah, 02h					; Call interrupt 13h to read from disk
	
	int 13h						; Read disk
	
	jnc happy					; if CF flag is set, print error
	mov dx, offset errmsg
	call print_line
happy:
	
	
	
	pushw 0800h					; Alice in Wonderland jump to whatever is in address 0000:0800h
	pushw 0000h
	retf
	
jmp Past_it_all

main endp



mystring byte "Booting...", 0dh, 0ah, 0
errmsg byte "Your Carry Flag is set!", 0

; Function: Prints the ASCII string of a byte array, plus a newline (\r\n), to the screen in green via BIOS
; Receives: DX
; Requires: Nothing
;  Returns: Nothing
; Clobbers: Nothing
print_line proc
	pusha
	mov si, 0
	mov bx, dx

	printloop:
		mov al, [bx + si] 		; put the next piece of the array into AL
		cmp al, 0
		jz endprint
		mov ah, 0Eh   			; 0Eh in BIOS means print character 
		push bx
		mov bl, 0010b 			; Set foreground color to green
		int 10h		  			; BIOS interrupt
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
	
org main+510					; Move the signature 0AA55h into the last 2 bytes of the first sector
	byte 055h, 0aah
	
end main