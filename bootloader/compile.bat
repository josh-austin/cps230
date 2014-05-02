jwasm -3 -Fl -Fo bldr.obj bldr.asm
jwlink format raw bin option quiet, map file bldr.obj name bldr.bin

jwasm -3 -Fl -Fo npkb.obj npkb.asm
jwlink format raw bin option quiet, map file npkb.obj name npk.bin

copy floppy_zeros.img floppy.img
dd if=bldr.bin skip=62 of=floppy.img bs=512 conv=notrunc
dd if=npk.bin of=floppy.img bs=512 seek=1 conv=notrunc
