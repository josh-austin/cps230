;include irvine16.inc
.model tiny
.386
.code
org 7c00h
	; code here starts at offset 7c00h
main proc
	mov ax, cs
	mov ss, ax
	mov ds, ax
	mov dx, offset mystring
	call print_string
	mov ah, 02
	mov ch, 0
	mov dh, 0
	mov dl, 0
	mov al, 40
	mov ax, 0800h
	mov es, ax
	mov bx, 0000h
	
	int 13h
	
;	call print_string

main endp

mystring byte "Booting...", 0dh, 0ah, 0

; Function: Prints out a nul-terminated string to the screen
; Receives: bx register
;  Returns: A nul-terminated string displayed on the string
; Requires: nothing
; Clobbers: nothing
print_string proc	
	pusha
	mov dx, offset mystring

	mov bx, dx
	
L1:							;Loop through each character of string	
	cmp al, 0 				;Check to see if character is nul-terminator
	jne outputString
	je endloop
outputString:
	mov al, [bx]	
	mov ah, 0eh				;output the character of the string
	int 10h
	inc bx					;increment bx register to next character in string

jmp L1

	endloop:
	popa
	ret
print_string endp
	
	


org main+510
	byte 055h, 0aah
	
end main