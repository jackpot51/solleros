;Sound Blaster Drivers
sblaster:
.init:
		call ResetDSP			;If the system is Sound Blaster 16 compatible, reset the DSP
		mov [SoundBlaster], al	;if the reset worked, show an available card
		cmp al, 0
		je .noinit
		mov	al,0D1h 		; turn speaker(s) on
		call WriteDSP
		mov	al,088h 		; Left = 8, Right = 8 (15-highest)
		call MstrVol 		; L = Hi Nibble, R = Lo Nibble
		mov esi, .initmsg
		call print
.noinit:
		ret
.initmsg db "Soundblaster Initialized",10,0
sblaster.cont: ;this function goes to the next available portion of a sound, if necessary
	cmp dword [Length0], 0
	je near .done
	dec dword [Length0]
	jmp .notodd
.oddlength:
	xor ecx, ecx
	mov [OddLength], cl
.notodd:
	mov esi, [NextMemLoc]
	xor ecx, ecx
	mov cx, [Length1]
	shr ecx, 1
	inc cx
	xor ebx, ebx
	mov bx, [SegLoc]
	add bx, cx
	mov [SegLoc], bx
	add ebx, 0x80000 ;linear address of sb buffer
	mov [MemLoc], esi
	mov eax, ecx
	add eax, esi
	mov [NextMemLoc], eax
	call DMACopy
	;call DMAPlay
	call PlayDSP
	mov dx, (BasePort+0xE)
	in al, dx ;acknowledge the interrupt 
	jmp handled2 ;it is part of an interrupt routine
.done:
	cmp byte [OddLength], 1
	je .oddlength
	xor eax, eax
	mov [Length1], ax
	mov ax, 0xD0
	call WriteDSP
	mov dx, (BasePort+0xE)
	in al, dx ;acknowledge the interrupt 
	jmp handled2
	
DMACopy:
		mov ax, LINEAR_SEL
		mov fs, ax
		shr ecx, 2
.loop:
		mov eax, [esi]
		mov [fs:ebx], eax
		add esi, 4
		add ebx, 4
		loop .loop
		mov ax, NEW_DATA_SEL
		mov fs, ax
		ret
		

DMAPlay:    ;uses eax ebx edx
		mov	byte [Page1],00h

		mov	al,(Channel+4)
		mov	dx,0Ah
		out	dx,al
		xor	al,al
		mov	dx,0Ch
		out	dx,al
		mov	al,ModeReg
		mov	dx,0Bh
		out	dx,al
		mov	eax,0x80000
		mov	dx,AddPort
		out	dx,al
		xchg al,ah
		out	dx,al
		mov	eax,0x80000
		mov	edx,eax
		and	eax,65536
		jz	MemLocN1
		inc	byte [Page1]
MemLocN1:
		mov	eax,edx
		and	eax,131072
		jz	MemLocN2
		add	byte [Page1],02
MemLocN2:
		mov	eax,edx
		and	eax,262144
		jz	MemLocN3
		add	byte [Page1],04
MemLocN3:
		mov	eax,edx
		and	eax,524288
		jz	MemLocN4
		add	byte [Page1],08
MemLocN4:
		mov	dx,PgPort
		mov	al,[Page1]
		out	dx,al
		mov	dx,LenPort
		mov	ax,[Length1]
		dec ax
		out	dx,al
		xchg al,ah
		out	dx,al
		mov	dx,0Ah
		mov	al,Channel
		out	dx,al
		ret
		
PlayDSP:
		mov	al,40h
		call WriteDSP
		xor	edx,edx
		mov	eax,1000000
		mov	ebx,[Freq]
		cmp byte [Stereo], 0
		je .nost
		shl ebx, 1
.nost:
		div	ebx
		mov	ebx,eax
		mov	eax,256
		sub	eax,ebx
		call WriteDSP
		mov	al,14h	;write the mode
		cmp byte [Stereo], 0
		je .nost2
		
.nost2:
		call WriteDSP
		mov	ax,[Length1]
		shr ax, 1
		call WriteDSP
		xchg al,ah
		call WriteDSP
		ret

MstrVol:    ;uses ax dx
	   push ax
	   mov	dx,(BasePort+4)
	   mov	al,22h
	   out	dx,al
	   pop	ax
	   inc	dx
	   out	dx,al
	   ret
	   
ResetDSP:   ; uses cx dx
			mov	dx,(BasePort+6)
			mov	al,01
			out	dx,al
			mov	cx,50
WaitIt1:	in	al,dx
			loop WaitIt1
			xor	al,al
			out	dx,al
			mov	cx,50
WaitIt2:	in	al,dx
			loop WaitIt2
			mov	ah,0FFh 		; part of Return Code
			mov	dx,(BasePort+14)
			in	al,dx
			and	al,80h
			cmp	al,80h
			jne	ResetErr
			mov	dx,(BasePort+10)
			in	al,dx
			cmp	al,0AAh
			jne	ResetErr
ResetOK:	mov al, 1		; return ax = 0 if reset ok
			ret
ResetErr:	xor al, al
			ret

WriteDSP:   ;uses ax dx
		push ax
		mov	dx,(BasePort+12)
WaitIt:	in	al,dx
		and	al,80h
		jnz	WaitIt
		pop	ax
		out	dx,al
		ret

Stereo db 0
OddLength db 0
Length0 dd	0
Length1	dw  0
NextMemLoc dd 0
MemLoc	dd  0
SegLoc  dw 0
Page1	db  0
Freq	dd	0
PgPort	equ 83h
AddPort	equ 02h
LenPort	equ 03h
ModeReg	equ 59h
Channel	equ 01h
BasePort	equ 220h
SoundBlaster	db 0