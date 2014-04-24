.code

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