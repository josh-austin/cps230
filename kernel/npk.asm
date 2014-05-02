TITLE Non-Preemptive Kernel (npk.asm)

include irvine16.inc

.data

offset_eax			equ		0
offset_ebx			equ		4
offset_ecx			equ		8
offset_edx			equ		12
offset_esp			equ		16
offset_flags		equ		20
number_registered	word	0
cabinet_drawer		byte	0
cabinet				dword	256 dup(0)
registered			word	20 dup(0)
placeholder			word	0
greeting			byte	"The Cheshire Non-Preemptive Cat", 0
authors				byte	"by Cameron Thacker, Ashley Lane, Josh Austin"
tweedledee_msg		byte	"TWEEDLE DEE: The time has come, the Walrus said...", 0
tweedledum_msg		byte	"TWEEDLE DUM: Why, sometimes I've believed as many as six impossible things before breakfast.", 0

.code

main proc
	; DOS only: register the data segment since we're not in Wonderland yet
	mov ax, @data
	mov ds, ax
	
	; register tweedledee and tweedledum
	mov ebx, 0deadbeefh
	mov eax, offset tweedledee
	call npk_register
	
	mov ebx, 0feedabeeh
	mov eax, offset tweedledum
	call npk_register
	
	; let the looping begin!
	call npk_start
	
	; No termination code since our NPK will be in an eternal loop  ;-)

main endp


; Function: Registers a function and context into the cabinet
; Receives: task address in AX
; Requires: Nothing
;  Returns: Nothing
; Clobbers: Nothing
npk_register proc
	pushad
	pushfd
	; STEP 1: point to the correct offset and then increment number_registered
	; (after registering ax into the array of registered function addresses)
	
	push ebx
	movzx ebx, [number_registered]
	;call DumpRegs
	add bx, [number_registered] ; number_registered is added twice since it is 2 bytes long (a "word")
	mov [registered + bx], ax 
	pop ebx
	
	push eax
	push ebx
	mov eax, 0
	mov ebx, 0
	
	movzx eax, [number_registered]
	mov bl, 40
	mul bl
	add ax, offset cabinet
	mov ebx, eax
	
	movzx eax, [number_registered]
	inc ax
	mov [number_registered], ax
	
	; STEP 2:
    ; Registration!
    pop eax
	mov [bx + offset_ebx], eax
    pop eax	
    mov [bx + offset_eax], eax
    mov [bx + offset_ecx], ecx
    mov [bx + offset_edx], edx	
	pop eax
	mov [bx + offset_flags], eax
	mov [placeholder], bx
	
	; STEP 3:
    ; Subtract from the stack section in increments of 256 as necessary
	mov ax, bx
    mov bx, 0FFFFh
	movzx ecx, [number_registered]
	inc ecx
	
stack_pointy_loop:	
    sub bx, 100h
	loop stack_pointy_loop
	
	; Finally, register ESP with the current task stack section
	push eax
	mov eax, ss:[bx]
	mov bx, [placeholder]
    mov [bx + offset_esp], eax
	pop eax
	
	
    popad
    ret

npk_register endp


; Function: Saves current context and swaps to the next "cabinet drawer" context
; Receives: Nothing
; Requires: Nothing
;  Returns: Nothing
; Clobbers: Nothing
npk_yield proc

	; STEP 1: Save registers and flags to the current cabinet drawer
	pushfd
	push ebx
    push eax
	
    mov ebx, 0
	mov eax, 0
	
	mov al, [cabinet_drawer]
	mov bl, 40
	mul bl
	mov bx, ax
	add bx, offset cabinet
	
    mov [bx + offset_esp], esp
	pop eax
    mov [bx + offset_eax], eax
    pop eax
    mov [bx + offset_ebx], eax
    mov [bx + offset_ecx], ecx
    mov [bx + offset_edx], edx
	
	pop eax
	mov [bx + offset_flags], eax
	
	; STEP 2: Unload the next cabinet drawer into the registers and flags
    mov eax, 0
	mov al, [cabinet_drawer]
	inc al
	cmp ax, [number_registered]
	jne J1
	mov al, 0

J1:
	; ...and then use the cabinet_drawer number to dynamically point at the cabinet offset
	mov [cabinet_drawer], al
	

    ; STEP 3: Unload the context from the cabinet based on a multiple of cabinet_drawer
	mov eax, 0 ; clear these to avoid any complications...
	mov ebx, 0
	
	movzx ax, [cabinet_drawer]
	cmp [cabinet_drawer], 0 ; if it's 0 then we can skip multiplying
	je J2
	mov bx, 40
	mul bx

J2:
    add bx, offset cabinet
	mov eax, [bx + offset_flags]
	pushd eax
	popfd
	
	mov eax, [bx + offset_eax]
	mov ecx, [bx + offset_ecx]
	mov edx, [bx + offset_edx]
	mov esp, [bx + offset_esp]
	mov ebx, [bx + offset_ebx]

	; STEP 3: Go to the next function	
	mov [placeholder], bx
	movzx bx, [cabinet_drawer]
	add bx, bx ; added because offsets are 2 bytes (a "word")
	push [registered + bx]
	mov bx, [placeholder]
	ret


npk_yield endp


; Function: Starts the happiness
; Receives: Nothing
; Requires: Nothing
;  Returns: Nothing
; Clobbers: Nothing
npk_start proc
	; Load the first context cabinet into the registers and flags and start runnin'!
	mov bx, offset cabinet
	mov eax, [bx + offset_flags]
	push eax
	popfd
	mov eax, [bx + offset_eax]
	mov ecx, [bx + offset_ecx]
	mov edx, [bx + offset_edx]
	mov esp, [bx + offset_esp]
	mov ebx, [bx + offset_ebx]
	push [registered]
	ret
npk_start endp


; Function: Just a dumb loop with a reference to Alice in Wonderland
; Receives: Nothing
; Requires: Nothing
;  Returns: Nothing
; Clobbers: Nothing
tweedledee proc
tweedledee_loop:
	call DumpRegs
	pusha
	; Pause a second
	mov cx, 0Fh
	mov dx, 4240h
	mov ah, 86h
	int 15h
	popa
	call npk_yield
	jmp tweedledee_loop
tweedledee endp


; Function: Just another dumb loop with a reference to Alice in Wonderland
; Receives: Nothing
; Requires: Nothing
;  Returns: Nothing
; Clobbers: Nothing
tweedledum proc
tweedledum_loop:
	call DumpRegs
	pusha
	; Pause a second
	mov cx, 0Fh
	mov dx, 4240h
	mov ah, 86h
	int 15h
	popa
	call npk_yield
	jmp tweedledum_loop
tweedledum endp

; Function: Prints out a null-terminated string to the screen
; Receives: DX (which must hold an offset)
;  Returns: Nothing
; Requires: Nothing
; Clobbers: Nothing
print_string proc	
	pusha
	mov bx, dx
	
L1:							;Loop through each character of string	
	cmp al, 0 				;Check to see if character is null-terminator
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

end main