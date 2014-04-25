include irvine16.inc

.code

; Function: Registers a function and context into the cabinet
; Receives: task address in AX
; Requires: Nothing
;  Returns: Nothing
; Clobbers: Nothing
npk_register proc
	pushad
	
	jmp AFTER_REGISTER_DATA
	
	cabinet  dword 256 dup(0) 
	temp_ebx dword ?
	low_stack_section word 0FFFFh
	
AFTER_REGISTER_DATA:

	mov [temp_ebx], ebx
    
    mov ebx, offset cabinet 
    call DumpRegs
    size_of_cabinet equ sizeof cabinet    

    offset_eax equ 0
    offset_ebx equ 32
    offset_ecx equ 64
    offset_edx equ 96
    offset_esp equ 128
	
	; STEP 1:
    ; If this is not the first register ever, then set the latest registered
    ; context's ESP to what you're registering.  Otherwise let it point to itself(?) since it will be changed later
	mov [size_of_cabinet + bx + offset_esp], ax

	
	; STEP 2:
    ; Registration!  While you're at it, set our newly-registered context's
    ; ESP to the offset of the first-ever registered function
    ; so we have a nice looping construction (function 1 -> function 2 -> function 3 -> function 1 again...)
    
    mov [bx + offset_eax], eax
    mov eax, [temp_ebx]
    mov [bx + offset_ebx], eax
    mov [bx + offset_ecx], ecx
    mov [bx + offset_edx], edx
    
	; STEP 3:
    ; Subtract 100h from low_stack_section
    mov bx, [low_stack_section]
    sub bx, 100h
	
	mov [temp_ebx], ebx
	
	; Pointy, pointy!
    mov [low_stack_section], bx
    mov ss:[bx], ax
	
	mov ebx, [temp_ebx]
    mov [size_of_cabinet + bx + offset_esp], ax
	COMMENT ~
	~
    popad
    ret

npk_register endp