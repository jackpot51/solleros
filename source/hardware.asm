%ifdef gui.included
	%include "source/drivers/video/vesa.asm"
	%include "source/drivers/input/mouse.asm"
%endif
%include "source/drivers/sound/pcspkr.asm"
%ifdef sound.included
	%include "source/drivers/sound/sblaster.asm"
%endif
%ifdef io.serial
	%include "source/drivers/input/serial.asm"
%else
	%include "source/drivers/input/keyboard.asm"
%endif
;drivers will soon be handled intelligently
;every driver's source will be scanned for a .init function
;that will be called and if it returns 0
;the hardware was found and the driver initialized properly
initializelater: ;these have debugging messages and should be initialized after the screen
	%ifdef sound.included
		call sblaster.init
	%endif
	%ifdef network.included
		call network.init
	%endif
	ret
initialize:
;Now I will initialise the interrupt controllers and remap irq's
	call .pic
%ifdef terminal.vsync
	call .rtc
%endif
	call .pit
	call .fpu
	call .sse
	xor eax, eax
	xor ecx, ecx
%ifdef io.serial
	call serial.init
%endif
	call .time
	ret
	
.time:
	call time
	call timeconvert
	mov [timeseconds], ecx
	xor ecx, ecx
	mov [timenanoseconds], ecx
	mov byte [istimeset], 1
	ret
	
.pic:
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
	ret
.rtc:
	mov al, 0x8
	mov ah, al
	mov dx, 0x70
	out dx, al
	inc dx
	in al, dx
	xchg al, ah
	dec dx
	out dx, al
	inc dx
	xchg al, ah
	or al, 0x40
	out dx, al
	
	mov al, 0xA
	dec dx
	out dx, al
	xchg al, ah
	inc dx
	in al, dx
	and al, 0xF0
	or al, [rtcrate]
	xchg al, ah
	dec dx
	out dx, al
	inc dx
	xchg al, ah
	out dx, al
	ret
	
.pit:
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
	ret
.fpu:
	;And now to initialize the fpu
	mov eax, cr4
	or eax, 0x200
	mov cr4, eax
	mov eax, 0xB7F
	push eax
	fldcw [esp]
	pop eax
	ret
	
.sse:
	mov eax, cr0
	and al, 11111011b
	or al, 00000010b
	mov cr0, eax
	mov eax, cr4
	or ax, 0000011000000000b
	mov cr4, eax
	ret
