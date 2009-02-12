;;sound.asm - I will try my best - uses SoundBlaster 16 standard for now
;0x220=base address in qemu
;0x226=DSP Reset
;0x22A=DSP Read
;0x22C=DSP Write
;0x22E=DSP Read buffer status and interrupt acknowledge
;0x22F=DSP 16-bit interrupt acknowledge

resetdsp:
	mov al, 1
	mov dx, 0x226
	out dx, al
	mov cx, 0xFFFF
	loop $	;;wait a bit, optimal would be 3 microseconds
	mov al, 0
	out dx, 0
	mov dx, 0x22E
rdbfst1:
	in al, dx
	and al, 01000000b
	cmp al, 0
	je rdbfst1
	mov dx, 0x22A
rddtst1:
	in al, dx
	cmp al, 0xAA
	jne rddtst1
	ret
	
writedsp:
	mov dx, 0x22C
	in al, dx
	and al, 01000000b
	cmp al, 0
	jne writedsp
	;;put write value in al
	out dx, al		
	ret
	
readdsp:
	mov dx, 0x22E
	in al, dx
	and al, 01000000b
	cmp al, 0
	je readdsp
	mov dx, 0x22A
	in al, dx
	ret