;;rtl8139.asm
initcard:	;;should find card, get mac, and initialize card
	xor eax, eax
	mov [pcifunction], al
	mov [pcibus], al
	mov [pcidevice], al
	mov al, 0x02 ;;type code
	mov [pcitype], al
	call getpciport
initnic:		;;;;Here i tried the rtl8139 interface, fuck it
	mov [basenicaddr], edx
	mov ecx, edx
	mov byte [firsthexshown], 3
	call showhex	;;for debugging, please remove
	mov esi, rbuffstart
	mov ecx, 8192
	xor eax, eax
clearrbuff:		;;clear receive buffer which starts at rbuffstart
	mov [esi], al
	inc esi
	dec cx
	cmp cx, 0
	jne clearrbuff
findmac:
	mov edx, [basenicaddr]
	mov edi, sysmac
	mov ecx, 6
macputloop:
	in al, dx
	mov [edi], al
	inc edi
	inc edx
	dec ecx
	jnz macputloop
	mov ecx, sysmac
	call showmac
resetnic:
	mov edx, [basenicaddr]
	add edx, 0x52
	xor al, al
	out dx, al	;;WAKE UP!!!!
	mov edx, [basenicaddr]
	add edx, 0x37
	mov al, 0x10
	out dx, al	;;Reset
resetnicwait:
	mov edx, [basenicaddr]
	add edx, 0x37
	in al, dx
	and al, 0x10
	cmp al, 0x10
	je near resetnicwait
	mov edx, [basenicaddr]
	add edx, 0x30
	mov eax, rbuffstart
	out dx, eax	;;give nic receive buffer location
	mov edx, [basenicaddr]
	add edx, 0x3C
	mov ax, 0x0005
	out dx, ax	;;set TOK and ROK
	mov edx, [basenicaddr]
	add edx, 0x44
	mov eax, 0xf
	out dx, eax	;;recieve packets from all matches
	mov edx, [basenicaddr]
	add edx, 0x37
	mov al, 0x0C
	out dx, al	;;use transmit and receive
	mov byte [nicconfig], 1
	ret
	
sendframe:	;;padded frame with beginning in edi and end in esi
	push esi
	push edi
nic2:		;;here come the low level drivers :(
			;;frame begins at esi, ends at edi 			;;0x0200 is the class code for ethernet cards
	cmp byte [nicconfig], 1
	je sendcachedata
	call initcard
sendcachedata:
	mov edx, [basenicaddr]
	add edx, 0x10
	in eax, dx
	mov ecx, eax
	call showhex
	mov edx, [basenicaddr]
	add edx, 0x13
	in eax, dx
	mov ecx, eax
	call showhex
	mov edx, [basenicaddr]
	add edx, 0x23	;;23 or 20?
	pop edi
	mov eax, edi
	out dx, eax	;;here's Johnny!
	pop esi
	sub esi, edi
	mov eax, esi
	mov edx, [basenicaddr]
	add edx, 0x13	;;13 or 10?
	out dx, eax
checknicstatus1:
	mov edx, [basenicaddr]
	add edx, 0x13	;;13 or 10?
	in eax, dx
	and eax, 0x2000
	cmp eax, 0x2000
	jne checknicstatus1
checknicstatus:
	mov edx, [basenicaddr]
	add edx, 0x13	;;13 or 10?
	in eax, dx
	and eax, 0x8000
	cmp eax, 0x8000
	jne checknicstatus
	mov edx, [basenicaddr]
	add edx, 0x10
	in eax, dx
	mov ecx, eax
	call showhex
	mov edx, [basenicaddr]
	add edx, 0x13
	in eax, dx
	mov ecx, eax
	call showhex
	ret
	
showmac:	;;mac begins in [ecx]
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
	
macprint db "00-00-00-00-00-00  ",0
ethernetend dw 0,0
nicconfig db 0
nonicfoundmsg db "NO NIC",0
initnicmsg	db "Initiating NIC",0
basenicaddr	db 0,0,0,0
sysip db 192,168,0,5
sysmac	db 0,0,0,0,0,0		;;my mac address