include npk_register.inc
include npk_yield.inc
include strings.inc

.code

jmp AFTER_DATA
; Data goes here instead of inside a data segment:


AFTER_DATA

main proc
main endp

end main