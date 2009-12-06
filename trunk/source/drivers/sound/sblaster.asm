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
.noinit:
		ret
		
sblastercont: ;this function goes to the next available portion of a sound, if necessary
	cmp word [Length0], 0
	je near handled2
	mov di, [Length0]
	dec di
	mov [Length0], di
	mov eax, [NextMemLoc]
	mov [MemLoc], eax
	xor ecx, ecx
	mov cx, 0xFFFF
	mov [Length1], cx
	add eax, ecx
	mov [NextMemLoc], eax
	call DMAPlay
	jmp handled2 ;it is part of an interrupt routine

DMAPlay:    ;uses eax ebx edx
		dec	word [Length1]
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
		mov	eax,[MemLoc]
		mov	dx,AddPort
		out	dx,al
		xchg al,ah
		out	dx,al
		mov	eax,[MemLoc]
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
		out	dx,al
		xchg al,ah
		out	dx,al
		mov	dx,0Ah
		mov	al,Channel
		out	dx,al
		
		mov	al,40h
		call WriteDSP
		xor	edx,edx
		mov	eax,1000000
		mov	ebx,[Freq]
		div	ebx
		mov	ebx,eax
		mov	eax,256
		sub	eax,ebx
		call WriteDSP
		mov	al,[WAVEMode]	;write the mode
		call WriteDSP
		mov	ax,[Length1]
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

Length0 dw	0
Length1	dw  0
NextMemLoc dd 0
MemLoc	dd  0
Page1	db  0
Freq	dd	0
WAVEMode db 14h

PgPort	equ 83h
AddPort	equ 02h
LenPort	equ 03h
ModeReg	equ 49h
Channel	equ 01h
BasePort	equ 220h
SoundBlaster	db 0