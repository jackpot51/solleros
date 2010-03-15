;RTL8169 NIC DRIVER
rtl8169:
	call .init
	jmp .end

;REGISTERS
.CMD equ 0x37
.TXPOLL equ 0x38
.TCR equ 0x40
.RCR equ 0x44
.IMR equ 0x3C
.ISR equ 0x3E
.LOCK equ 0x50
.CONFIG1 equ 0x52
.TDSAR equ 0x20
.RDSAR equ 0xE4
.MAXRX equ 0xDA
.MAXTX equ 0xEC
;IMPORTANT VALUES
.OWN equ 0x80000000
.EOR equ 0x40000000
.POLLING equ 0x40
;CODE
.init:	;should find card, get mac, and initialize card
	xor eax, eax
	mov [pcifunction], al
	mov [pcibus], al
	mov [pcidevice], al
	mov al, 0x02 ;type code
	mov [pcitype], al
	mov eax, 0x816910EC
	mov [pcidevid], eax
	mov ebx, 0xFFF0FFFF
	mov [pcidevidmask], ebx
	call getpciport
	cmp ebx, 0xFFFFFFFF
	jne .initnic
	ret
.initnic:
	mov [.basenicaddr], edx
	mov ecx, edx
	call showhex	;for debugging, please remove
	mov esi, rbuffstart
	mov ecx, 8192
	xor eax, eax
.clearrbuff:		;clear receive buffer which starts at rbuffstart
	mov [esi], al
	inc esi
	dec cx
	cmp cx, 0
	jne .clearrbuff
.findmac:
	mov edx, [.basenicaddr]
	mov edi, .mac
	mov ecx, 6
.macputloop:
	in al, dx
	mov [edi], al
	inc edi
	inc edx
	dec ecx
	jnz .macputloop
	mov ecx, .mac
	call showmac
	call .resetnic
	mov esi, .name
	call print
	mov esi, .initmsg
	call print
	xor ebx, ebx
	ret
.resetnic:
	mov edx, [.basenicaddr]
	add edx, .CMD
	mov al, 0x10
	out dx, al	;Reset
.resetnicwait:
	in al, dx
	test al, 0x10
	jnz near .resetnicwait
	mov edx, [.basenicaddr]
	add edx, .LOCK
	mov al, 0xC0
	out dx, al	;unlock config registers
	mov edx, [.basenicaddr]
	add edx, .RCR
	mov eax, 0x0000E70F
	out dx, eax	;recieve packets from all matches
	mov edx, [.basenicaddr]
	add edx, .TCR
	mov eax, 0x03000700
	out dx, eax	;set up tcr
	mov edx, [.basenicaddr]
	add edx, .MAXRX
	mov ax, 0x1FFF
	out dx, ax	;setup max rx size
	mov edx, [.basenicaddr]
	add edx, .MAXTX
	mov al, 0x3B
	out dx, al	;setup max tx size
	mov edx, [.basenicaddr]
	add edx, .TDSAR
	mov eax, [basecache]
	shl eax, 4
	add eax, .txdesc
	out dx, eax
	mov edx, [.basenicaddr]
	add edx, .RDSAR
	mov eax, [basecache]
	shl eax, 4
	add eax, .rxdesc
	out dx, eax
	mov edx, [.basenicaddr]
	add edx, .CMD
	mov al, 0x0C
	out dx, al	;use transmit and receive
	mov edx, [.basenicaddr]
	add edx, .LOCK
	xor al, al
	out dx, al
	mov byte [.nicconfig], 1
	ret
	
.sendpacket:	;packet with beginning in edi and end in esi
	cmp byte [.nicconfig], 1
	je .sendcachedata
	push esi
	push edi
	call .init
	pop edi
	pop esi
	cmp ebx, 0xFFFFFFFF
	jne .sendpacket
	ret
.sendcachedata:
	mov ecx, [.mac]
	mov [edi + 6], ecx
	mov cx, [.mac + 4]
	mov [edi + 10], cx	;copy the correct mac
	mov eax, [basecache]
	shl eax, 4
	add eax, edi
	mov [.txdesc + 8], eax	;put packet start in tx descriptor
	sub esi, edi
	mov [.txdesc], si	;put packet size in tx descriptor
	or dword [.txdesc], .OWN	;set own bit
	mov edx, [.basenicaddr]
	add edx, .TXPOLL
	mov al, .POLLING
	out dx, al	;set up TX Polling
.sendloop:
	mov eax, [.txdesc]
	mov ecx, eax
	call showhex
	call getchar
	test eax, .OWN
	jnz .sendloop
	ret
	
.basenicaddr dd 0
.nicconfig db 0
.mac db 0,0,0,0,0,0
.name db "RTL8169 ",0
.initmsg db "Initialized",10,0
align 256, nop
.txdesc:
	dd .EOR	;command
	dd 0	;vlan
	dd 0	;low buf
	dd 0	;high buf
align 256, nop
.rxdesc:
	dd .OWN | .EOR | (rbuffend - rbuffstart)	;command
	dd 0	;vlan
	dd rbuffstart	;low buf
	dd 0	;high buf
.end:
