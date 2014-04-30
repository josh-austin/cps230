TITLE Non-Preemptive Kernel (npk.asm)
include irvine16.inc
;include strings.inc

.data
number_registered byte 0
cabinet_drawer byte 0
cabinet  dword 256 dup(0) 
temp_ebx dword ?
temp_eax dword ?
low_stack_section word 0FFFFh

offset_eax equ 0
offset_ebx equ 4
offset_ecx equ 8
offset_edx equ 12
offset_esp equ 16
offset_flags equ 20

.code

tweedledee proc
	;call DumpRegs
	; TODO: delay 1 second
	call npk_yield
tweedledee endp

tweedledum proc
	;call DumpRegs
	; TODO: delay 1 second
	call npk_yield
tweedledum endp

main proc
	mov ax, @data
	mov ds, ax

	mov ebx, 0deadbeefh
	mov eax, offset tweedledee
	call npk_register
	;call DumpRegs
	
	mov ebx, 0abadfeedh
	mov eax, offset tweedledum
	call npk_register
	;call DumpRegs
	
	mov ebx, 0
	mov edx, 0
	
	mov ebx, [offset cabinet]
	mov ebx, [bx + offset_ebx]
	call DumpRegs
	
	mov ebx, [offset cabinet]
	mov ebx, [bx + 40 + offset_ebx]
	call DumpRegs
	
	;pushw offset tweedledee
	
	exit

main endp


; Function: Saves current context and swaps to the next "cabinet drawer" context
; Receives: Nothing
; Requires: Nothing
;  Returns: Nothing
; Clobbers: Nothing
npk_yield proc
    
	; STEP 1: Save the current context in the cabinet!
	pushfd

	mov [temp_ebx], ebx
    
    mov ebx, offset cabinet
    mov [bx + offset_esp], esp
    mov [bx + offset_eax], eax
    mov eax, [temp_ebx]
    mov [bx + offset_ebx], eax
    mov [bx + offset_ecx], ecx
    mov [bx + offset_edx], edx
	
	pop eax
	mov [bx + offset_flags], eax
	
    ; STEP 2: increment to the next cabinet_drawer unless we are at number_registered, in which case we go back to the first
    mov al, [cabinet_drawer]
	inc al
	cmp al, [number_registered]
	jne J1
	mov al, 0

J1:
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
	
	mov eax, 0
	mov eax, [bx + offset_ebx]
	mov [temp_ebx], eax
	
	mov eax, [bx + offset_eax]
	mov ecx, [bx + offset_ecx]
	mov edx, [bx + offset_edx]
	mov esp, [bx + offset_esp]
	mov ebx, [temp_ebx]
	
	
    ; STEP 4:
    ; Put the ESP, which is the return addr of the next function we want to run, and push it to the top of the stack...
    ret ; ...and then this will start the next function

npk_yield endp


; Function: Registers a function and context into the cabinet
; Receives: task address in AX
; Requires: Nothing
;  Returns: Nothing
; Clobbers: Nothing
npk_register proc
	pushad
	pushfd

	; STEP 1: point to the correct offset and then increment number_registered
	push eax
	push ebx
	mov [temp_ebx], ebx
	mov eax, 0
	mov ebx, 0
	mov al, [number_registered]
	mov bl, 40
	mul bl
	add ax, offset cabinet
	mov bx, ax
	
	
	mov al, [number_registered]
	inc al
	mov [number_registered], al
	
	; STEP 2:
    ; Registration!
    pop eax
	mov [bx + offset_ebx], eax
	;call DumpRegs
    pop eax	
    mov [bx + offset_eax], eax
    mov [bx + offset_ecx], ecx
    mov [bx + offset_edx], edx
	mov [bx + offset_esp], esp
	
	pop eax
	mov [bx + offset_flags], eax
    
	; STEP 3:
    ; Subtract 100h from low_stack_section
    movzx ebx, [low_stack_section]
    sub ebx, 100h
	
	; Pointy, pointy!
    mov [low_stack_section], bx
	mov eax, 0
    mov ss:[bx], ax
	
	mov ax, sizeof cabinet
	add ebx, eax
    mov [ebx + offset_esp], ebx
	
	mov [temp_ebx], ebx
	
    popad
    ret

npk_register endp



end main