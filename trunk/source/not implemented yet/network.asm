packettest: 		;;test the ARP protocol and TCP/IP protocol
			;;http wants to send "Hello" to "http://www.webserver.com", DNS changes this to 192.168.0.8:80
getmac:	mov ecx, 0
	mov edx, 0
	mov esi, 0
	mov edi, 0
	mov eax, 0
	mov ebx, 0
	mov al, 0
	mov ah, 8
	shl eax, 16
	mov al, 192		;;IP is 192.168.0.8
	mov ah, 168
	mov bh, 0x00 	;;port is 80
	mov bl, 0x50
	mov esi, data
	mov edi, data2
	call senddata	;;returns with response in memory at ebx with length in cx
	cmp ebx, data2
	jne near packettestfail
	add ebx, ecx
	cmp ebx, data3
	jne near packettestfail
	mov esi, data2
	call print
	jmp nwcmd

failpackettest db "FAIL",10,13,0

packettestfail:
	mov esi, failpackettest
	call print
	jmp nwcmd

dataoffseti dw 0,0
dataoffsetf dw 0,0
targetip db 0,0,0,0
targetport db 0,0

senddata:
		mov [targetip], eax
		mov [targetport], bx
		mov [dataoffseti], esi
		mov [dataoffsetf], edi
		mov edi, arptable
	checkarp:
		cmp [edi], eax
		je near foundmac
		add edi, 10
		cmp edi, arptableend
		jae near sendarprequest
		jmp checkarp
	foundmac:
		add edi, 4
		mov ecx, [edi]
		call showhex
		add edi, 4
		mov ecx, [edi]
		call showhex
		add edi, 4
		mov ecx, [edi]
		call showhex
		mov esi, sysmac
		mov bx, [targetport]
		mov esi, [dataoffseti]
		mov edi, [dataoffsetf]
		mov eax, [targetip]
		call sendpacket
		call receivepacket
		ret

sendpacket:
receivepacket:
		ret

sendarprequest:
	mov dl, 1
	mov [arpoperation + 1], dl
	mov edi, arpsenderinfo
	mov esi, sysmac
copyarpsenderinfo:
	mov edx, [esi]
	mov [edi], edx
	add esi, 4
	add edi, 4
	mov edx, [esi]
	mov [edi], edx
	add esi, 4
	add edi, 4
	mov dx, [esi]
	mov [edi], dx
copytargetipinfo:
	add edi, 8
	mov esi, targetip
	mov eax, [esi]
	mov [edi], eax
	add edi, 4
	mov ecx, edi
	sub ecx, arppacket
	mov edi, broadcastmac
	mov ebx, arppacket
	mov ah, 0x06
	mov al, 0x08
	mov esi, sysmac
	call sendframe
retarpsend:
	mov edi, sysmac
	mov ebx, arppacket
	mov cx, 40
	mov ah, 0x06
	mov al, 0x08
	mov esi, 0
	call receiveframe
retarprec:
	mov esi, arpsenderinfo
	mov edi, arptable
	mov ebx, 0
findemptyarpspot:		;;duh
	mov edx, [edi]
    mov eax, [edi + 4]
	mov bx, [edi + 8]
	or edx, eax
	or edx, ebx
	cmp edx, 0
	je near emptyarpspot
	add edi, 10
	cmp edi, arptableend
	jae noemptyarpspots
	jmp findemptyarpspot
noarps db "AHHHH!!! NO MORE ARP SPACE!!!!",0
noemptyarpspots:
	mov esi, noarps
	call print
	jmp $
emptyarpspot:
	mov eax, [targetip]
	mov bx, [targetport]
	mov [edi], eax
	add edi, 4
	mov edx, [esi]
	mov [edi], edx
	add edi, 4
	add esi, 4
	mov dx, [esi]
	mov [edi], dx
	sub edi, 8
	jmp foundmac

dstmac dw 0,0
srcmac dw 0,0

receiveframe:	;;ETHERTYPE IN AX, DATACACHE IN EBX WITH MAXLENGTH IN CX, DESTINATION MAC IN EDI, EXPECTED SOURCE IN ESI, DX  			;;IS EMPTY
		;;IF ESI IS 0, SOURCE MAC DOES NOT MATTER
		;;RETURNS DATA IN DATACACHE
	mov edx, [edi]
	cmp edx, [ethernetinputcache]
	jne near notexpecteddstmac
	add edi, 4
	mov dx, [edi]
	cmp dx, [ethernetinputcache + 4]
	jne near notexpecteddstmac
	sub edi, 4
	mov [dstmac], edi
	mov edi, ethernetinputcache
	add edi, 10
	cmp esi, 0
	je near noneedtochecksource
	sub edi, 4
	mov edx, [esi]
	cmp edx, [edi]
	jne near notexpectedsrcmac
	add esi, 4
	add edi, 4
	mov dx, [esi]
	cmp dx, [edi]
	jne near notexpectedsrcmac
noneedtochecksource:
	add edi, 2
	cmp ax, [edi]
	jne near notexpectedethertype
	mov [srcmac], esi
	add edi, 2
	mov esi, ethernetcacheend
	cmp cx, 0
	je donecopyreceivedpacket
copyreceivedpacket:
	mov dl, [edi]
	mov [ebx], dl
	inc ebx
	inc edi
	cmp edi, esi
	jae donecopyreceivedpacket
	dec cx
	cmp cx, 0
	jne copyreceivedpacket
donecopyreceivedpacket:
	mov esi, [srcmac]
	mov edi, [dstmac]
	ret

notexpectedsrcmac:
	mov esi, nexpsrcmac
	call print
	mov esi, line
	call print
	jmp $
notexpecteddstmac:
	mov esi, nexpdstmac
	call print
	mov esi, line
	call print
	ret
notexpectedethertype:
	mov esi, nexpethtyp
	call print
	mov esi, line
	call print
	jmp $

nexpsrcmac db "Not expected source MAC address.",0
nexpdstmac db "Not expected destination MAC address.",0
nexpethtyp db "Not expected EtherType.",0

sendframe:	;;ETHERTYPE IN AX, DATA IN EBX WITH LENGTH IN CX, SOURCE MAC IN ESI, DESTINATION MAC IN EDI, DX IS EMPTY
	mov edx, [edi]
	mov [ethernetoutputcache], edx
	mov dx, [edi + 4]
	mov [ethernetoutputcache + 4], dx
	mov [dstmac], edi
	mov edi, ethernetoutputcache
	add edi, 6
	mov edx, [esi]
	mov [edi], edx
	add edi, 4
	mov dx, [esi + 4]
	mov [edi], dx
	add edi, 2
	mov [edi], ax
	add edi, 2
	mov [srcmac], esi
	mov ax, 0
ethernetdatacacheloop:
	mov dl, [ebx]
	mov [edi], dl
	cmp edi, ethernetinputcache
	jae near doneethernetcacheloop
	inc edi
	inc ebx
	inc ax
	dec cx
	cmp cx, 0
	ja near ethernetdatacacheloop
doneethernetcacheloop:
	cmp ax, 64
	jae near nopadframe
padframe:
	mov dl, 0
	mov [edi], dl
	inc edi
	inc ax
	cmp ax, 64
	jb near padframe
nopadframe:
	jmp nic2
			
broadcastmac db 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF

arppacket: 	db 0x00,0x01
arpprotocol: 	db 0x08,0x00
	   	db 0x06,0x04
arpoperation: 	db 0x00,0x01
arpsenderinfo:	db 0x00,0x00,0x00,0x00,0x00,0x00
		db 0,0,0,0
arptargetinfo:	db 0x00,0x00,0x00,0x00,0x00,0x00
		db 0,0,0,0
		
sysip	db 192,168,0,5
data	db "Hello",0
data2	db "hELLO",0
data3:

ethernetoutputcache:	times 1500 db 0
ethernetinputcache:	db 0x11,0x22,0x33,0x44,0x55,0x66
			db 0x00,0x11,0x22,0x33,0x44,0x55
			db 0x08,0x06

			db 0x00,0x01
			db 0x08,0x00
			db 0x06,0x04
			db 0x00,0x02
			db 0x00,0x11,0x22,0x33,0x44,0x55
			db 192,168,0,8
			db 0x11,0x22,0x33,0x44,0x55,0x66
			db 192,168,0,5
ethernetcacheend:
