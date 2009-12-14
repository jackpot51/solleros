;RTL8139 NIC DRIVER
rtl8139:
.RBSTART equ 0x30
.IMR equ 0x3C
.ISR equ 0x3E
.CMD equ 0x37
.RCR equ 0x44
.CONFIG1 equ 0x52
.TSD0 equ 0x10
.TSAD0 equ 0x20
.initcard:	;should find card, get mac, and initialize card
	xor eax, eax
	mov [pcifunction], al
	mov [pcibus], al
	mov [pcidevice], al
	mov al, 0x02 ;;type code
	mov [pcitype], al
	call getpciport
.initnic:	;Here i tried the rtl8139 interface, fuck it
	mov [basenicaddr], edx
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
	mov edx, [basenicaddr]
	mov edi, sysmac
	mov ecx, 6
.macputloop:
	in al, dx
	mov [edi], al
	inc edi
	inc edx
	dec ecx
	jnz .macputloop
	mov ecx, sysmac
	call showmac
.resetnic:
	mov edx, [basenicaddr]
	add edx, .CONFIG1
	xor al, al
	out dx, al	;WAKE UP!!!!
	mov edx, [basenicaddr]
	add edx, .CMD
	mov al, 0x10
	out dx, al	;Reset
.resetnicwait:
	mov edx, [basenicaddr]
	add edx, .CMD
	in al, dx
	and al, 0x10
	cmp al, 0x10
	je near .resetnicwait
	mov edx, [basenicaddr]
	add edx, .RBSTART
	mov eax, rbuffstart
	add eax, 0x100000 ;change virtual to physical address
	out dx, eax	;give nic receive buffer location
	mov edx, [basenicaddr]
	add edx, .IMR
	in ax, dx
	or ax, 0xE07F ;set all possible interrupts to enabled
	out dx, ax	;set TOK and ROK
	mov edx, [basenicaddr]
	add edx, .RCR
	mov eax, 0xf
	add eax, 128 ;enable wrap option
	out dx, eax	;recieve packets from all matches
	mov edx, [basenicaddr]
	add edx, .CMD
	mov al, 0x0C
	out dx, al	;use transmit and receive
	mov byte [nicconfig], 1
	ret
	
.sendpacket:	;packet with beginning in edi and end in esi
	push esi
	push edi
.nic2:		;here come the low level drivers :(
			;frame begins at esi, ends at edi
 			;0x0200 is the class code for ethernet cards
	cmp byte [nicconfig], 1
	je .sendcachedata
	call .initcard
.sendcachedata:
	mov edx, [basenicaddr]
	add edx, .TSAD0
	pop edi
	mov eax, edi
	add eax, 0x100000 ;base address
	out dx, eax	;here's Johnny!
	pop esi
	sub esi, edi
	mov edx, [basenicaddr]
	add edx, .TSD0
	in eax, dx ;get tsd
	and eax, 0xFFFFE000 ;clear off thirteen bits
	add eax, esi ;add length to tsd
	and eax, 0xFFFFDFFF ;clear own bit
	out dx, eax
.checknicownbit:
	mov edx, [basenicaddr]
	add edx, .TSD0
	in eax, dx
	and eax, 0x2000 ;check own bit
	cmp eax, 0x2000
	jne .checknicownbit
.checknictokbit:
	mov edx, [basenicaddr]
	add edx, .TSD0
	in eax, dx
	and eax, 0x8000	;check tok bit
	cmp eax, 0x8000
	jne .checknictokbit
	ret
	
showmac:	;mac begins in [ecx]
	mov esi, macprint
	mov edi, ecx
	add ecx, 6
showmacloop:
	mov al, [edi]
	mov ah, [edi]
	shr al, 4
	shl ah, 4
	shr ah, 4
	add al, 48
	cmp al, "9"
	jbe .goodal
	sub al, 48
	sub al, 0xA
	add al, "A"
.goodal:
	add ah, 48
	cmp ah, "9"
	jbe .goodah
	sub ah, 48
	sub ah, 0xA
	add ah, "A"
.goodah:
	mov [esi], ax
	add esi, 3
	inc edi
	cmp edi, ecx
	jb showmacloop
	mov esi, macprint
	call print
	ret
	
macprint db "00:00:00:00:00:00  ",0
ethernetend dw 0,0
nicconfig db 0
basenicaddr	db 0,0,0,0
sysip db 192,168,0,5
sysmac	db 0,0,0,0,0,0		;my mac address