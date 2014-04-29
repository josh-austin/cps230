include irvine16.inc

.data

.code

; Function: Saves current context and swaps to the next "cabinet drawer" context
; Receives: Nothing
; Requires: Nothing
;  Returns: Nothing
; Clobbers: Nothing
npk_yield proc
    
    ; STEP 1: iterate to the next cabinet "drawer" unless we are at cabinet_index, in which case we go back to the first
    
    ; STEP 2:
    ; Context swap!
    
    ; STEP 3:
    ; Put the ESP, which is the return addr of the next function we want to run, and push it to the top of the stack...
    ret ; ...and then this will start the next function

npk_yield endp