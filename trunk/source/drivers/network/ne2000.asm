ne2000:
;	PAGE0			PAGE 1			PAGE 2
;	READ	WRITE	READ	WRITE	READ	WRITE
;0	CR		CR		CR		CR		CR		CR
;1	CLDA0 	PSTART	PAR0	PAR0	PSTART	CLDA0
;2	CLDA1	PSTOP	PAR1	PAR1	PSTOP	CLDA1
;3	BNRY	BNRY	PAR2	PAR2	RNPP	RNPP
;4	TSR		TPSR	PAR3	PAR3	TPSR	N/A
;5	NCR		TBCR0	PAR4	PAR4	LNPP	LNPP
;6	FIFO	TCBR1	PAR5	PAR5	ACU		ACU
;7	ISR		ISR		CURR	CURR	ACL		ACL
;8	CRDA0	RSAR0	MAR0	MAR0	N/A		N/A
;9	CRDA1	RSAR1	MAR1	MAR1	N/A		N/A
;A	N/A		RBCR0	MAR2	MAR2	N/A		N/A
;B	N/A		RBCR1	MAR3	MAR3	N/A		N/A
;C	RSR		RCR		MAR4	MAR4	RCR		N/A
;D	CNTR0	TCR		MAR5	MAR5	TCR		N/A
;E	CNTR1	DCR		MAR6	MAR6	DCR		N/A
;F	CNTR2	IMR		MAR7	MAR7	IMR		N/A
.CR equ 0
	.CR.STP	equ 1		;Stop
	.CR.STA equ 2		;Start
	.CR.TXP equ 4		;Transmit
	.CR.RD0 equ 8		;Remote DMA 0
	.CR.RD1 equ 0x10	;Remote DMA 1
	.CR.RD2 equ 0x20	;Remote DMA 2
	.CR.PS0 equ 0x40	;Page Select 0
	.CR.PS1 equ 0x80	;Page Select 1
.PSTART equ 1
.PSTOP equ 2
.BNRY equ 3
.ISR equ 7
	.ISR.PRX equ 1		;Packet Received
	.ISR.PTX equ 2		;Packet Transmitted
	.ISR.RXE equ 4		;Receive Error
	.ISR.TXE equ 8		;Transmission Error
	.ISR.OVW equ 0x10	;Overwrite
	.ISR.CNT equ 0x20	;Counter Overflow
	.ISR.RDC equ 0x40	;Remote Data Complete
	.ISR.RST equ 0x80	;Reset status
.RSAR0 equ 8
.RSAR1 equ 9
.RBCR0 equ 0xA
.RBCR1 equ 0xB
.RCR equ 0xC
	.RCR.SEP equ 1		;Save Errored Packets
	.RCR.AR equ 2		;Accept Runt packet
	.RCR.AB equ 4		;Accept Broadcast
	.RCR.AM equ 8		;Accept Multicast
	.RCR.PRO equ 0x10	;Promiscuous Physical
	.RCR.MON equ 0x20	;Monitor Mode
.DCR equ 0xE
	.DCR.WTS equ 1		;Word Transfer Select
	.DCR.BOS equ 2		;Byte Order Select
	.DCR.LAS equ 4		;Long Address Select
	.DCR.LS equ 8		;Loopback Select
	.DCR.AR equ 0x10	;Auto-initialize Remote
	.DCR.FT0 equ 0x20	;FIFO Threshold Select 0
	.DCR.FT1 equ 0x40	;FIFO Threshold Select 1
.ASIC equ 0x10
.RESET equ 0x1F

.init:
	mov ebx, 0xFFFFFFFF
	xor eax, eax
	mov [pcifunction], al
	mov [pcibus], al
	mov [pcidevice], al
	mov al, 2 ;type code
	mov [pcitype], al
	mov eax, 0x802910EC
	mov [pcidevid], eax
	call getpciport
	cmp ebx, 0xFFFFFFFF
	jne .good0
	ret
.good0:
	mov [.basenicaddr], edx
	mov ecx, edx
.test:
	call .reset
	call .stop
	mov edx, ecx
	mov ecx, 0xFF
	loop $ ;wait for ~100 us
	mov ecx, edx
	in al, dx
	and al, (.CR.RD2 | .CR.TXP | .CR.STA | .CR.STP)
	cmp al, (.CR.RD2 | .CR.STP)
	je .good1
	mov edx, ecx
	add edx, .ISR
	in al, dx
	and al, .ISR.RST
	cmp al, .ISR.RST
	je .good1
	ret
.good1:
call showhex	;for debugging, please remove
	call .setup
call showmac
mov esi, .name
call print
mov esi, .initmsg
call print
	mov byte [.nicconfig], 1
	xor ebx, ebx
	ret
.reset:
	mov edx, [.basenicaddr]
	add edx, .RESET
	in al, dx
	out dx, al ;write its contents to itself
	ret
.page:
	shl ax, 14
	mov edx, [.basenicaddr]
	in al, dx
	and al, 00111111b
	or al, ah
	out dx, al
	ret
.start:
	mov edx, [.basenicaddr]
	mov al, .CR.RD2
	mov al, .CR.STA
	out dx, al
	ret
.stop:
	mov edx, [.basenicaddr]
	mov al, .CR.RD2
	or al, .CR.STP
	out dx, al
	ret
.setup:
	call .stop
	mov edx, [.basenicaddr]
	add edx, .DCR
	mov al, .DCR.FT1
	or al, .DCR.WTS
	or al, .DCR.LS
	out dx, al ;Set FIFO threshold, byte order, word-wide DMA
	call .getmac
	call .stop
	xor al, al
	mov edx, [.basenicaddr]
	add edx, .RBCR0
	out dx, al
	inc dx
	out dx, al ;Clear byte count
	mov eax, 16*1024
	mov [.ringstart], eax
	shr eax, 8
	mov [.pagestart], ax
	add eax, 64-2*6
	mov [.pageend], eax
	shl eax, 8
	mov [.ringend], ax ;set page and ring starts and ends
	mov edx, [.basenicaddr]
	add edx, .PSTART
	mov al, [.pagestart]
	out dx, al
	mov al, [.pageend]
	inc dx
	out dx, al
	mov al, [.pagestart]
	inc dx
	out dx, al
	call .stop
;INSERT INTERRUPT ENABLE HERE
	mov al, 1
	call .page
	mov edx, [.basenicaddr]
	mov edi, .rom
.copymactocard:
	inc edx
	outsb
	add edi, 2
	cmp edx, 6
	jbe .copymactocard
	mov edx, [.basenicaddr]
	add edx, 7
	mov al, [.pagestart]
	inc al
	out dx, al ;set page in CURR register
;INSERT MULTICAST INIT HERE
	call .stop
	mov edx, [.basenicaddr]
	add edx, .RCR
	mov al, .RCR.AB
	out dx, al ;accept broadcast
	inc dx
	xor al, al
	out dx, al ;stop loopback
	call .start
	ret
.getmac:
	mov edx, [.basenicaddr]
	mov al, 0x20
	or al, 2
	out dx, al	;set STA and RD2 bits
	add dx, .RBCR0
	mov al, 16
	out dx, al
	inc dx
	xor al, al
	out dx, al
	mov edx, [.basenicaddr]
	add dx, .RSAR0
	out dx, al
	inc dx
	out dx, al
	mov dx, [.basenicaddr]
	mov al, 8
	or al, 2
	out dx, al
	mov dx, [.basenicaddr]
	add dx, .ASIC
	mov ecx, 8
	mov edi, .rom
	rep insw
.copymac:
	mov edi, .rom
	mov esi, .mac
	mov ecx, 6
.lpmac:
	mov al, [edi]
	mov [esi], al
	add edi, 2
	inc esi
	loop .lpmac
	mov ecx, .mac
	ret
.sendpacket:
	cmp byte [.nicconfig], 0
	jne .sendit
	push esi
	push edi
	call .init
	pop edi
	pop esi
	cmp ebx, 0
	je .sendit
	ret
.sendit: ;packet start in edi, end in esi
	xchg esi, edi ;this helps with the outsw
	;now the packet start is in esi, end in edi
	mov ecx, [.mac]
	mov [esi + 6], ecx
	mov cx, [.mac + 4]
	mov [esi + 10], cx	;copy the correct mac
	mov edx, [.basenicaddr]
	mov al, .CR.RD2
	or al, .CR.STA
	out dx, al ;set RD2 and STA
	add edx, .ISR ; ISR
	mov al, .ISR.RDC
	out dx, al ;set RDC flag
	mov edx, [.basenicaddr]
	add dx, .RBCR0
	mov eax, edi
	sub eax, esi
	mov ebx, 1
	and ebx, eax
	cmp ebx, 1
	jne .nofixword
	inc eax
.nofixword:
	mov ecx, eax ;save length in ecx
	out dx, al
	xchg al, ah
	inc dx
	out dx, al ;send size
	mov edx, [.basenicaddr]
	add dx, .RSAR0
	mov ax, [.pagestart]
	shl eax, 8
	out dx, al
	xchg al, ah
	inc dx
	out dx, al ;send address in NIC memory
	mov edx, [.basenicaddr]
	mov al, .CR.RD1
	or al, .CR.STA
	out dx, al ;set RD and STA
	mov ebx, ecx ;save length in ebx
	shr ecx, 1
	mov edx, [.basenicaddr]
	add dx, 0x10
	rep outsw ;Send the packet data
	mov edx, [.basenicaddr]
	add dx, .ISR
.chkcopylp:
	mov ah, .ISR.RDC
	in al, dx
	and ah, al
	cmp ah, 0x40
	jne .chkcopylp	
	mov edx, [.basenicaddr]
	add dx, 4
	mov al, [.pagestart]
	out dx, al ;send start address in pages
	mov edx, [.basenicaddr]
	add edx, 0x5
	mov eax, ebx
	out dx, al
	xchg al, ah
	inc dx
	out dx, al ;send length
	mov edx, [.basenicaddr]
	mov al, 0x20
	or al, 4
	or al, 2
	out dx, al ;set RD2, TXP, and STA
	xor ebx, ebx
	ret
.basenicaddr dd 0
.nicconfig db 0
.name db "NE2000 ",0
.initmsg db "Initialized.",10,0
align 2, nop
.pagestart dw 0
.pageend dw 0
.ringstart dd 0
.ringend dd 0
.mac db 0,0,0,0,0,0
.rom times 16 db 0