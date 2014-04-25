;include irvine16.inc
include npkr.inc

.data
.code

; Kinda like NOP!  :-P
really_dumb proc
	ret
really_dumb endp

runtest proc
	mov ax, @data
	mov ds, ax
	
	mov eax, offset really_dumb
	mov edx, 0deadbeefh
	call DumpRegs
	
	call npk_register	
	call DumpRegs
    
	exit

runtest endp

end runtest