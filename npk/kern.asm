; Kernel stuff

.model tiny
.386
.stack 4096d


.code


main proc

	; Set up the data segment
	mov ax, cs
	mov ds, ax
    
    jmp after_data
    
    ; DATA GOES HERE
    low_stack_section word 0FFFFh    
    cabinet dword 256 dup(0)    
    temp_ebx dword ?


after_data:

    mov [low_stack_section], sp ; delete this line when we connect this with the bootloader
    
    mov dx, offset greeting
    call print_string
    call print_newline

	mov ax, 4c00h
    int 21h ; Terminate

main endp



; Function: Registers a function and context into the cabinet
; Receives: task address in AX
; Requires: Nothing
;  Returns: Nothing
; Clobbers: Nothing
npk_register_function proc

    ; STEP 1:
    ; If this is not the first register ever, then set the latest registered
    ; context's ESP to what you're registering.  Otherwise let it point to itself(?) since it will be changed later


    ; STEP 2:
    ; Subtract 100h from low_stack_seg

    ; STEP 3:
    ; Registration!  While you're at it, set our newly-registered context's
    ; ESP to the offset of the first-ever registered function
    ; so we have a nice looping construction (function 1 -> function 2 -> function 3 -> function 1 again...)

    ret

npk_register_function endp



; Function: Saves current context and swaps to the next context in the looped chain
; Receives: Nothing
; Requires: Nothing
;  Returns: Nothing
; Clobbers: Nothing
npk_yield proc
    
    ; STEP 1: save the current ESP, which is the return address of the next function we want to run
    
    ; STEP 2:
    ; Subtract 100h from current_seg if it is not equal to low_stack_seg.
    ; Otherwise set current_seg to 0FEFFh
    
    ; STEP 3:
    ; Point to the appropriate context using low_stack_seg to find the offset and load it
    
    ; STEP 4:
    ; Put the ESP, which was the return addr of the next function, which we saved earlier and push it to the top of the stack...
    ret ; ...and then this will start the next function

npk_yield endp

end main