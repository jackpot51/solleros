	[BITS 32]
	[ORG 0x400000]
	db "EX"
		;use the PIT to turn on the pc speaker-then turn it off
	mov esi, edi
	mov ah, 10
	int 30h		;convert number
setpitch
	mov al, 0xB6
	out 0x43, al
	mov ax, cx
	out 0x42, al
	mov al, ah
	out 0x42, al
startsound:
	in al, 0x61
	or al, 3
	out 0x61, al
	
keytest:
	mov al, 0
	mov ah, 5
	int 30h	;wait for keypress
	test al, "="
	jnz near uppitch
	test al, "-"
	jnz near downpitch
	jmp killsound

uppitch:
	mov ax, cx
	bsr ax, ax	;log base 2 of ax
	shl ax, 4	;make it bigger
	sub cx, ax	;cx is a divisor
	jmp setpitch
	
downpitch:
	mov ax, cx
	bsr ax, ax
	shl ax, 4	;make it bigger
	add cx, ax
	jmp setpitch	
	
killsound:
	in al, 0x61
	and al, 0xFC
	out 0x61, al
	mov ax, 0
	int 30h