;RTL8139 NIC DRIVER
rtl8139:
	call .init
	jmp .end

.RBSTART equ 0x30
.IMR equ 0x3C
.ISR equ 0x3E
.CMD equ 0x37
.CAPR equ 0x38
.CBR equ 0x3A
.RCR equ 0x44
.CONFIG1 equ 0x52
.TSD0 equ 0x10
.TSAD0 equ 0x20
.init:	;should find card, get mac, and initialize card
	xor eax, eax
	mov [pcifunction], al
	mov [pcibus], al
	mov [pcidevice], al
	mov al, 0x02 ;type code
	mov [pcitype], al
	mov eax, 0x813910EC
	mov [pcidevid], eax
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
	mov dx, [.basenicaddr]
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
	mov dx, [.basenicaddr]
	add dx, .CONFIG1
	xor al, al
	out dx, al	;WAKE UP!!!!
	mov dx, [.basenicaddr]
	add dx, .CMD
	mov al, 0x10
	out dx, al	;Reset
.resetnicwait:
	in al, dx
	test al, 0x10
	jnz near .resetnicwait
	mov dx, [.basenicaddr]
	add dx, .RBSTART
	mov eax, rbuffstart
	add eax, [newcodecache] ;change virtual to physical address
	out dx, eax	;give nic receive buffer location
	mov dx, [.basenicaddr]
	add dx, .IMR
	;in ax, dx
	mov ax, 5
	out dx, ax	;set both TOK and ROK interrupts
	mov dx, [.basenicaddr]
	add dx, .RCR
	mov eax, 10001111b ;receive all packets, enable wrap
	out dx, eax
	mov dx, [.basenicaddr]
	add dx, .CMD
	mov al, 0x0C
	out dx, al	;use transmit and receive
	mov byte [.nicconfig], 1
	ret
	
.sendpacket:	;packet with beginning in edi and end in esi
	push esi
	push edi
	cmp byte [.nicconfig], 1
	je .sendit
	call .init
	pop edi
	pop esi
	cmp ebx, 0xFFFFFFFF
	jne .sendpacket
	ret
.sendit:
	call .resetnic
	mov dx, [.basenicaddr]
	add dx, .TSAD0
	pop edi
	mov ecx, [.mac]
	mov [edi + 6], ecx
	mov cx, [.mac + 4]
	mov [edi + 10], cx	;copy the correct mac
	mov eax, [newcodecache]
	add eax, edi
	out dx, eax	;here's Johnny!
	pop esi
	sub esi, edi
	mov dx, [.basenicaddr]
	add dx, .TSD0
	in eax, dx ;get tsd
	and eax, 0xFFFFC000 ;clear off length and own bits
	add eax, esi ;add length to tsd
	out dx, eax
.checknicownbit:
	in eax, dx
	and eax, 0x2000 ;check own bit
	cmp eax, 0x2000
	jne .checknicownbit
.checknictokbit:
	in eax, dx
	and eax, 0x8000	;check tok bit
	cmp eax, 0x8000
	jne .checknictokbit
	ret
.basenicaddr dd 0
.nicconfig db 0
.mac db 0,0,0,0,0,0
.name db "RTL8139 ",0
.initmsg db "Initialized",10,0

.end:
