%include "source/drivers/sound/pcspkr.asm"
%include "source/drivers/sound/sblaster.asm"
%include "source/drivers/network/rtl8139.asm"
%include "source/drivers/input/mouse.asm"
%include "source/drivers/input/keyboard.asm"
;drivers will soon be handled intelligently
;every driver's source will be scanned for a .init function
;that will be called and if it returns 0
;the hardware was found and the driver initialized properly
initialize:
;Now I will initialise the interrupt controllers and remap irq's
	mov al, 0x11
	out 0x20, al
	out 0xA0, al
	mov al, 0x40	;interrupt for master
	out 0x21, al
	mov al, 0x48	;interrupt for slave
	out 0xA1, al
	mov al, 4
	out 0x21, al
	mov al, 2
	out 0xA1, al
	mov al, 0x1
	out 0x21, al
	mov al, 0x1
	out 0xA1, al
	;masks are set to zero so as not to mask
	xor al, al
	out 0x21, al
	xor al, al
	out 0xA1, al
	mov al, 0x20
	out 0xA0, al
	out 0x20, al
	;initialize the PIT
	mov ax, [pitdiv] ;this is the divider for the PIT
	out 0x40, al
	rol ax, 8
	out 0x40, al
	;enable rtc interrupt
	mov al, 0xB
	out 0x70, al
	rol ax, 8
	in al, 0x71
	rol ax, 8
	out 0x70, al
	rol ax, 8
	or al, 0x40
	out 0x71, al

	;And now to initialize the fpu
	mov eax, cr4
	or eax, 0x200
	mov cr4, eax
	mov eax, 0xB7F
	push eax
	fldcw [esp]
	pop eax
	xor eax, eax
	xor ecx, ecx
	
	call sblaster.init
	ret
	