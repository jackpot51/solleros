;RTL8169 NIC DRIVER

RTL_RBSTART equ 0x30
RTL_IMR equ 0x3C
RTL_ISR equ 0x3E
RTL_CMD equ 0x37
RTL_RCR equ 0x44
RTL_CONFIG1 equ 0x52
RTL_TSD0 equ 0x10
RTL_TSAD0 equ 0x20

rtl8169.initcard:	;should find card, get mac, and initialize card
	xor eax, eax
	mov [pcifunction], al
	mov [pcibus], al
	mov [pcidevice], al
	mov al, 0x02 ;;type code
	mov [pcitype], al
	call getpciport
rtl8169.initnic:	;Here i tried the rtl8139 interface, fuck it
	mov [basenicaddr], edx
	mov ecx, edx
	call showhex	;for debugging, please remove
	mov esi, rbuffstart
	mov ecx, 8192
	xor eax, eax
rtl8169.clearrbuff:		;clear receive buffer which starts at rbuffstart
	mov [esi], al
	inc esi
	dec cx
	cmp cx, 0
	jne clearrbuff
rtl8169.findmac:
	mov edx, [basenicaddr]
	mov edi, sysmac
	mov ecx, 6
rtl8169.macputloop:
	in al, dx
	mov [edi], al
	inc edi
	inc edx
	dec ecx
	jnz rtl8169.macputloop
	mov ecx, sysmac
	call showmac
rtl8169.resetnic:
	mov edx, [basenicaddr]
	add edx, RTL_CONFIG1
	xor al, al
	out dx, al	;WAKE UP!!!!
	mov edx, [basenicaddr]
	add edx, RTL_CMD
	mov al, 0x10
	out dx, al	;Reset
rtl8169.resetnicwait:
	mov edx, [basenicaddr]
	add edx, RTL_CMD
	in al, dx
	and al, 0x10
	cmp al, 0x10
	je near rtl8139.resetnicwait
	mov edx, [basenicaddr]
	add edx, RTL_RBSTART
	mov eax, rbuffstart
	out dx, eax	;give nic receive buffer location
	mov edx, [basenicaddr]
	add edx, RTL_IMR
	mov ax, 0x0005
	out dx, ax	;set TOK and ROK
	mov edx, [basenicaddr]
	add edx, RTL_RCR
	mov eax, 0xf
	out dx, eax	;recieve packets from all matches
	mov edx, [basenicaddr]
	add edx, RTL_CMD
	mov al, 0x0C
	out dx, al	;use transmit and receive
	mov byte [nicconfig], 1
	ret
	
rtl8139.sendframe:	;padded frame with beginning in edi and end in esi
	push esi
	push edi
rtl8139.nic2:		;here come the low level drivers :(
			;frame begins at esi, ends at edi
 			;0x0200 is the class code for ethernet cards
	cmp byte [nicconfig], 1
	je rtl8139.sendcachedata
	call rtl8139.initcard
rtl8139.sendcachedata:
	mov edx, [basenicaddr]
	add edx, RTL_TSAD0
	pop edi
	mov eax, edi
	add eax, 0x100000 ;base address
	out dx, eax	;here's Johnny!
	pop esi
	sub esi, edi
	mov edx, [basenicaddr]
	add edx, RTL_TSD0
	in eax, dx ;get tsd
	mov eax, esi ;add length to tsd
	and eax, 0xFFFFDFFF ;clear own bit
	out dx, eax
rtl8139.checknicownbit:
	mov edx, [basenicaddr]
	add edx, RTL_TSD0
	in eax, dx
	and eax, 0x2000 ;check own bit
	cmp eax, 0x2000
	jne rtl8139.checknicownbit
rtl8139.checknictokbit:
	mov edx, [basenicaddr]
	add edx, RTL_TSD0
	in eax, dx
	and eax, 0x8000	;check tok bit
	cmp eax, 0x8000
	jne rtl8139.checknictokbit
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
	add ah, 48
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