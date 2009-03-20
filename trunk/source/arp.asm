;;let's try something else
;;arp.asm
arpinit:
	mov esi, arptable
	mov edi, sysmac
	mov ebx, sysip
	mov ecx, [edi]
	mov [esi], ecx
	mov cx, [edi + 4]
	mov [esi + 4], ecx
	mov ecx, [ebx]
	mov [esi + 6], ecx
	mov byte [arpconfig], 1
	ret
arptest:
	cmp byte [arpconfig], 1
	je arptest2
	call arpinit
arptest2:	;;try to reach 192.168.0.1
	mov ecx, [sysmac]
	mov bx, [sysmac + 4]
	mov [sourcemac], ecx
	mov [sourcemac + 4],bx
	mov [arpsenderinfo], ecx
	mov [arpsenderinfo + 4], bx
	mov edi, frame
	mov esi, framend
	call sendframe
	ret
	
;;example frame
frame:
destinationmac:	db 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
sourcemac:		db 0,0,0,0,0,0
ethertype:		dw 0x0806			;;arp
	;;example packet
	arppacket: 		dw 1				;;ethernet is 1
	arpprotocol: 	dw 0x0800			;;ip is 0x800
					db 6,4				;;length of mac, length of ip
	arpoperation: 	dw 1				;;one for arp request
	arpsenderinfo:	db 0x00,0x00,0x00,0x00,0x00,0x00	;;mac
					db 192,168,0,5			;;ip
	arptargetinfo:	db 0x00,0x00,0x00,0x00,0x00,0x00	;;ignored in requests
					db 192,168,0,1			;;ip
padding:		times (64-($-frame)) db 0
framend:

arpconfig db 0
arptable:	;;mac,ip
	times 10 db 0,0,0,0,0,0,0,0,0,0
arptableend: