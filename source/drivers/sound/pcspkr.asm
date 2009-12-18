;PC Speaker Drivers
PCSpeakerRAW:
	pusha
nosoundrep:
	mov esi, [soundpos]
	xor ecx, ecx
	mov cx, [soundrepititions]
	cmp cx, 0
	jne near donesetpitch
	mov cx, [esi]
	mov bx, [esi + 2]
	mov [soundrepititions], cx
	add esi, 4
	mov [soundpos], esi
	cmp esi, [soundendpos]
	ja stopsound
	cmp word [soundrepititions], 0
	je nosoundrep
	cmp bx, 0
	je nosoundplay
	call setpitch
	call startsound
	jmp donesetpitch
nosoundplay:
	call killsound
donesetpitch:
	dec cx
	mov [soundrepititions], cx
	popa
	jmp timerinterrupt
stopsound:
	xor eax, eax
	mov [soundrepititions], ax
	mov [soundon], al
	mov [soundpos], eax
	mov [soundendpos], eax
	call killsound
	popa
	jmp timerinterrupt


setpitch:
	mov al, 0xB6
	out 0x43, al
	mov ax, bx
	out 0x42, al
	mov al, ah
	out 0x42, al
	ret
startsound:
	in al, 0x61
	or al, 3
	out 0x61, al
	ret
killsound:
	in al, 0x61
	and al, 0xFC
	out 0x61, al
	ret
	