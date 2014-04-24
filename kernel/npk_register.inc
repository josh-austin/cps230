.code

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