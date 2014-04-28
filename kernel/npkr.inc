include irvine16.inc
.data
	cabinet  dword 256 dup(0) 
	temp_ebx dword ?
	low_stack_section word 0FFFFh

.code

; Function: Registers a function and context into the cabinet
; Receives: task address in AX
; Requires: Nothing
;  Returns: Nothing
; Clobbers: Nothing
npk_register proc
	pushad
	pushfd

	mov [temp_ebx], ebx
    
    mov ebx, offset cabinet
	
    size_of_cabinet equ sizeof cabinet    

    offset_eax equ 0
    offset_ebx equ 4
    offset_ecx equ 8
    offset_edx equ 12
    offset_esp equ 16
	offset_flags equ 20
	
	; STEP 1:
    mov [bx + offset_esp], esp

	
	; STEP 2:
    ; Registration!  While you're at it, set our newly-registered context's
    ; ESP to the offset of the first-ever registered function
    ; so we have a nice looping construction (function 1 -> function 2 -> function 3 -> function 1 again...)
    
    mov [bx + offset_eax], eax
    mov eax, [temp_ebx]
    mov [bx + offset_ebx], eax
    mov [bx + offset_ecx], ecx
    mov [bx + offset_edx], edx
	
	pop eax
	mov [bx + offset_flags], eax
    
	; STEP 3:
    ; Subtract 100h from low_stack_section
    movzx ebx, [low_stack_section]
    sub ebx, 100h
	
	mov [temp_ebx], ebx
	
	; Pointy, pointy!
    mov [low_stack_section], bx
    mov ss:[bx], ax
	
    mov [size_of_cabinet + ebx + offset_esp], ebx
	
    popad
    ret

npk_register endp