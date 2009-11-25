;PC Speaker Drivers
PCSpeakerPWM:
	cmp al,0x90	;If the byte taken from the memory is less than 80h,
				;turn off the speaker to prevent "unwanted" sounds,
	jb TurnOffBeeper	;like: ASCII strings (e.g. "WAVEfmt" signature etc).
	call Sound_On
	jmp Sound_Done
TurnOffBeeper:
	call Sound_Off
Sound_Done:
	inc esi	;Increment ESI to load the next byte
	jmp keyinterrupt

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
	
;this is code that I got from
;http://forum.osdev.org/viewtopic.php?f=13&t=17293
;that plays wave files
WAVEDIV dw 0

Sound_On:	; A routine to make sounds with BX = frequency in Hz
   mov bx, [WAVEDIV]
   in al,0x61
   test al,3
   jnz A99               
   or al,3	;Turn on the speaker itself
   out 0x61,al               
   mov al,0xb6
   out 0x43,al
A99:   
   mov al,bl
   out 0x42,al             
   mov al,bh
   out 0x42,al
Done1:
   ret

Sound_Off:
   in al,0x61                 
   and al,11111100b                               ;Turn off the speaker
   out 0x61,al
   ret