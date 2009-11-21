db 255,44,"play",0
	call playasync
	jmp nwcmd
playasync:
	mov edi, [currentcommandloc]
	add edi, 5
	mov esi, 0x400000
	call loadfile
	cmp edx, 404
	je nosoundfound
	mov ebx, 0x400000
	cmp dword [ebx + 8], "WAVE"
	je near wave_player
	cmp word [ebx], "SN"
	jne nosoundfound
	add ebx, 6
	mov [soundpos], ebx
	add ebx, [ebx - 4]
	mov [soundendpos], ebx
	mov word [soundrepititions], 0
	mov byte [soundon], 1
	ret
nosoundfound:
	mov esi, notfoundsound
	call print
	mov esi, [currentcommandloc]
	add esi, 5
	call print
	mov esi, notfound2
	call print
	ret
notfoundsound db "Sound ",34,0

wave_player:
	mov esi, 0x400000
	mov ecx, [esi + 24]
	mov [WAVSamplingRate], cx
	sub edi, esi
	sub edi, 44
	mov [WAVFileSize], edi
	;MASK ALL INTS EXCEPT IRQ 0
	mov al, 0xFE
	out 0x21, al
	inc al
	out 0xA1, al
	mov al, 0x20
	out 0xA0, al
	out 0x20, al
	;SET PIT DIVISOR
	xor edx, edx
	mov ecx, [esi + 24]
	mov eax, 1193182
	div ecx ;al should be the proper sample divisor
	out 0x40, al
	rol ax, 8
	out 0x40, al
	;GET WAVEDIV
   mov bx, [WAVSamplingRate]
   mov ax,0x34dd	; The sound lasts until NoSound is called
   mov dx,0x0012             
   div bx               
   mov [WAVEDIV],ax
	;PLAY WAVE
	add esi, 44
	call PlayWAV
	;UNMASK ALL INTS
	xor al, al
	out 0x21, al
	xor al, al
	out 0xA1, al
	mov al, 0x20
	out 0xA0, al
	out 0x20, al
	;RESET PIT DIVISOR
	mov ax, [pitdiv]
	out 0x40, al
	rol ax, 8
	out 0x40, al
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

PlayWAV:
   mov ecx,[WAVFileSize]                         ;Sets the loop point
   mov byte [EnableDigitized],1	;Tells the irq0 handler to process the routines
Play_Repeat:
   mov al, [esi]	;Loads a byte from ESI to AL
   hlt	;Wait for IRQ to fire
   loop Play_Repeat	;and the whole procedure is looped ECX times
   mov byte [EnableDigitized],0	;Tells the irq0 handler to disable the digitized functions
   call Sound_Off	;Turn the speaker off just in case
   ret
   
