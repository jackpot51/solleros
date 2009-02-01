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

failpackettest db "FAIL",0

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
	jmp $
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

addfcs:			;;return arp packet is already in buffer for now, tehehe	
				;;simply appends FCS and sends frame, or at least tries to
	mov esi, ethernetoutputcache
crcget:			;;beginning of block in esi, end in edi, puts result in eax
			;;uses x32 + x26 + x23 + x22 + x16 + x12 + x11 + x10 + x8 + x7 + x5 + x4 + x2 + x + 1 algorithm
			;;length in cx, base in esi, puts CRC in eax
	mov ebx, 0	; CRC-table
	mov eax, 0xFFFFFFFF	; initialize
	mov edx, 0
calcbyte:		; process a single byte:		; crc = table[(unsigned char)crc ^ byte] ^ (crc >> 8)
	mov dl, al
	xor dl, [esi]
	shr eax, 8
	add bx, dx
	add bx, dx
	add bx, dx
	add bx, dx
	xor eax, [crctable + bx]
	mov bx, 0
	mov dx, 0
	inc esi
	cmp esi, edi
	jb near calcbyte
	mov [edi], eax
	add edi, 4
	mov esi, ethernetoutputcache
	mov [ethernetend], edi
	
nic2:		;;here come the low level drivers :(
			;;frame begins at esi, ends at edi 			;;0x0200 is the class code for ethernet cards
	cmp byte [nicconfig], 1
	je near sendcachedata
nicdump:
	mov eax, 0
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
	call showhex
	mov esi, rbuffstart
	mov ecx, 8000
	mov eax, 0
clearrbuff:		;;clear receive buffer which starts at rbuffstart
	mov [esi], al
	inc esi
	dec cx
	cmp cx, 0
	jne clearrbuff
	mov edx, [basenicaddr]
	add edx, 0x52
	mov al, 0
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
sendcachedata:
	mov edx, [basenicaddr]
	add edx, 0x23
	mov eax, ethernetoutputcache
	out dx, eax	;;here's Johnny!
	mov esi, ethernetoutputcache
	mov edi, [ethernetend]
	sub edi, esi
	mov eax, 0
	mov eax, edi
	mov edx, [basenicaddr]
	add edx, 0x13
	out dx, eax
checknicstatus1:
	mov edx, [basenicaddr]
	add edx, 0x13
	in eax, dx
	and eax, 0x2000
	cmp eax, 0x2000
	jne checknicstatus1
checknicstatus:
	mov edx, [basenicaddr]
	add edx, 0x13
	in eax, dx
	and eax, 0x8000
	cmp eax, 0x8000
	jne checknicstatus
	mov edi, [dstmac]
	mov esi, [srcmac]
	ret

	
ethernetend dw 0,0
nicconfig db 0
nonicfoundmsg db "NO NIC",0
initnicmsg	db "Initiating NIC",0
basenicaddr	db 0,0,0,0
pcibus		db 0
pcidevice	db 0
pcifunction	db 0
pciregister	db 0
pcireqtype db 0

getpciport:
	mov al, 1
	mov [pcireqtype], al
	jmp searchpci
pcidump:
	mov eax, 0
	mov [pcifunction], al
	mov [pcibus], al
	mov [pcidevice], al
	mov [pcireqtype], al
	jmp searchpci
searchpci:		;;return in ebx, start X in pciX
	mov al, 0
	mov [pciregister], al
	call getpciaddr
	mov edx, 0xCF8
	out dx, eax	;;request pci config
	mov edx, 0xCFC
	in eax, dx 	;;read in pci config
	cmp eax, 0xFFFF0000
	jb near checkpcidevice
searchpciret:
nextpcidevice:
	mov al, 0
	mov [pcifunction], al
	mov al, [pcidevice]
	cmp al, 11111b
	jae near nextpcibus
	inc al
	mov [pcidevice], al
	jmp searchpci
	mov al, [pcifunction]
	cmp al, 111b
	jae near nextpcidevice
	inc al
	mov [pcifunction], al
	jmp searchpci
pcitype: db 0,0,0,0
checkpcidevice:
	mov al, 0
	cmp [pcireqtype], al
	je near dumppcidevice
	mov al, 0x08
	mov [pciregister], al	;;class code, subclass, revision id
	call getpciaddr
	mov edx, 0xCF8
	out dx, eax
	mov edx, 0xCFC
	in eax, dx
	rol eax, 8
	mov bl, [pcitype]
	cmp al, bl
	je near foundpciaddr
	jmp searchpciret
dumppcidevice:
	mov al, 0
	mov [pciregister], al
	call getpciaddr
	mov ecx, eax
	mov byte [firsthexshown],3
	call showhex
dumppcidevicelp:
	mov [pciregister], al
	call getpciaddr
	mov edx, 0xCF8
	out dx, eax
	mov edx, 0xCFC
	in eax, dx
	mov ecx, eax
	mov al, [pciregister]
	add al, 4
	cmp al, 0x3C
	jae dumppcidn
	mov byte [firsthexshown],0
	call showhex
	jmp dumppcidevicelp
dumppcidn:	
	mov byte [firsthexshown],2
	call showhex
	jmp searchpciret
nextpcibus:
	mov al, 0
	mov [pcidevice], al
	mov al, [pcibus]
	cmp al, 1111111b
	jae donesearchpci
	inc al
	mov [pcibus], al
	jmp searchpci
donesearchpci:
	mov edx, 0
	ret
foundpciaddr:
	mov al, 0x10
	mov [pciregister], al
findpciioaddr:
	call getpciaddr
	mov edx, 0xCF8
	out dx, eax
	mov edx, 0xCFC
	in eax, dx
	mov ebx, eax
	and ebx, 1
	cmp ebx, 0
	je near notpciioaddr
	sub eax, 1
	mov edx, eax
	ret
notpciioaddr:
	mov al, [pciregister]
	add al, 4
	cmp al, 0x28
	ja near searchpciret
	mov [pciregister], al
	jmp findpciioaddr
getpciaddr:		;;puts it in eax and ebx
			mov eax, 0
			mov ebx, 0x80000000
			mov al, [pcibus]
			shl eax, 16
			add ebx, eax
			mov eax, 0
			mov al, [pcidevice]
			shl eax, 11
			add ebx, eax
			mov eax, 0
			mov al, [pcifunction]
			shl eax, 8
			add ebx, eax
			mov eax, 0
			mov al, [pciregister]
			add ebx, eax
			mov eax, ebx
			ret
			
broadcastmac db 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF

arppacket: 	db 0x00,0x01
arpprotocol: 	db 0x08,0x00
	   	db 0x06,0x04
arpoperation: 	db 0x00,0x01
arpsenderinfo:	db 0x00,0x00,0x00,0x00,0x00,0x00
		db 0,0,0,0
arptargetinfo:	db 0x00,0x00,0x00,0x00,0x00,0x00
		db 0,0,0,0
		
sysmac	db 0x11,0x22,0x33,0x44,0x55,0x66		;;my mac address
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

arptablegateway db 192,168,0,1,0x12,0x34,0x56,0x78,0x90,0xAB	;;gateway address
		db 192,168,0,5,0x11,0x22,0x33,0x44,0x55,0x66	;;my address
		db 192,168,0,8,0x00,0x11,0x22,0x33,0x44,0x55	;;server address
		db 0,0,0,0,0x00,0x00,0x00,0x00,0x00,0x00

arptable	db 192,168,0,5,0x11,0x22,0x33,0x44,0x55,0x66	;;my address
		db 192,168,0,1,0x12,0x34,0x56,0x78,0x90,0xAB	;;gateway address
		db 0,0,0,0,0x00,0x00,0x00,0x00,0x00,0x00	;;server mac and ip?
		db 0,0,0,0,0x00,0x00,0x00,0x00,0x00,0x00
arptableend	db 0


crctable:
dd 0x00000000, 0x77073096, 0xEE0E612C, 0x990951BA
dd 0x076DC419, 0x706AF48F, 0xE963A535, 0x9E6495A3
dd 0x0EDB8832, 0x79DCB8A4, 0xE0D5E91E, 0x97D2D988
dd 0x09B64C2B, 0x7EB17CBD, 0xE7B82D07, 0x90BF1D91
dd 0x1DB71064, 0x6AB020F2, 0xF3B97148, 0x84BE41DE
dd 0x1ADAD47D, 0x6DDDE4EB, 0xF4D4B551, 0x83D385C7
dd 0x136C9856, 0x646BA8C0, 0xFD62F97A, 0x8A65C9EC
dd 0x14015C4F, 0x63066CD9, 0xFA0F3D63, 0x8D080DF5
dd 0x3B6E20C8, 0x4C69105E, 0xD56041E4, 0xA2677172
dd 0x3C03E4D1, 0x4B04D447, 0xD20D85FD, 0xA50AB56B
dd 0x35B5A8FA, 0x42B2986C, 0xDBBBC9D6, 0xACBCF940
dd 0x32D86CE3, 0x45DF5C75, 0xDCD60DCF, 0xABD13D59
dd 0x26D930AC, 0x51DE003A, 0xC8D75180, 0xBFD06116
dd 0x21B4F4B5, 0x56B3C423, 0xCFBA9599, 0xB8BDA50F
dd 0x2802B89E, 0x5F058808, 0xC60CD9B2, 0xB10BE924
dd 0x2F6F7C87, 0x58684C11, 0xC1611DAB, 0xB6662D3D
dd 0x76DC4190, 0x01DB7106, 0x98D220BC, 0xEFD5102A
dd 0x71B18589, 0x06B6B51F, 0x9FBFE4A5, 0xE8B8D433
dd 0x7807C9A2, 0x0F00F934, 0x9609A88E, 0xE10E9818
dd 0x7F6A0DBB, 0x086D3D2D, 0x91646C97, 0xE6635C01
dd 0x6B6B51F4, 0x1C6C6162, 0x856530D8, 0xF262004E
dd 0x6C0695ED, 0x1B01A57B, 0x8208F4C1, 0xF50FC457
dd 0x65B0D9C6, 0x12B7E950, 0x8BBEB8EA, 0xFCB9887C
dd 0x62DD1DDF, 0x15DA2D49, 0x8CD37CF3, 0xFBD44C65
dd 0x4DB26158, 0x3AB551CE, 0xA3BC0074, 0xD4BB30E2
dd 0x4ADFA541, 0x3DD895D7, 0xA4D1C46D, 0xD3D6F4FB
dd 0x4369E96A, 0x346ED9FC, 0xAD678846, 0xDA60B8D0
dd 0x44042D73, 0x33031DE5, 0xAA0A4C5F, 0xDD0D7CC9
dd 0x5005713C, 0x270241AA, 0xBE0B1010, 0xC90C2086
dd 0x5768B525, 0x206F85B3, 0xB966D409, 0xCE61E49F
dd 0x5EDEF90E, 0x29D9C998, 0xB0D09822, 0xC7D7A8B4
dd 0x59B33D17, 0x2EB40D81, 0xB7BD5C3B, 0xC0BA6CAD
dd 0xEDB88320, 0x9ABFB3B6, 0x03B6E20C, 0x74B1D29A
dd 0xEAD54739, 0x9DD277AF, 0x04DB2615, 0x73DC1683
dd 0xE3630B12, 0x94643B84, 0x0D6D6A3E, 0x7A6A5AA8
dd 0xE40ECF0B, 0x9309FF9D, 0x0A00AE27, 0x7D079EB1
dd 0xF00F9344, 0x8708A3D2, 0x1E01F268, 0x6906C2FE
dd 0xF762575D, 0x806567CB, 0x196C3671, 0x6E6B06E7
dd 0xFED41B76, 0x89D32BE0, 0x10DA7A5A, 0x67DD4ACC
dd 0xF9B9DF6F, 0x8EBEEFF9, 0x17B7BE43, 0x60B08ED5
dd 0xD6D6A3E8, 0xA1D1937E, 0x38D8C2C4, 0x4FDFF252
dd 0xD1BB67F1, 0xA6BC5767, 0x3FB506DD, 0x48B2364B
dd 0xD80D2BDA, 0xAF0A1B4C, 0x36034AF6, 0x41047A60
dd 0xDF60EFC3, 0xA867DF55, 0x316E8EEF, 0x4669BE79
dd 0xCB61B38C, 0xBC66831A, 0x256FD2A0, 0x5268E236
dd 0xCC0C7795, 0xBB0B4703, 0x220216B9, 0x5505262F
dd 0xC5BA3BBE, 0xB2BD0B28, 0x2BB45A92, 0x5CB36A04
dd 0xC2D7FFA7, 0xB5D0CF31, 0x2CD99E8B, 0x5BDEAE1D
dd 0x9B64C2B0, 0xEC63F226, 0x756AA39C, 0x026D930A
dd 0x9C0906A9, 0xEB0E363F, 0x72076785, 0x05005713
dd 0x95BF4A82, 0xE2B87A14, 0x7BB12BAE, 0x0CB61B38
dd 0x92D28E9B, 0xE5D5BE0D, 0x7CDCEFB7, 0x0BDBDF21
dd 0x86D3D2D4, 0xF1D4E242, 0x68DDB3F8, 0x1FDA836E
dd 0x81BE16CD, 0xF6B9265B, 0x6FB077E1, 0x18B74777
dd 0x88085AE6, 0xFF0F6A70, 0x66063BCA, 0x11010B5C
dd 0x8F659EFF, 0xF862AE69, 0x616BFFD3, 0x166CCF45
dd 0xA00AE278, 0xD70DD2EE, 0x4E048354, 0x3903B3C2
dd 0xA7672661, 0xD06016F7, 0x4969474D, 0x3E6E77DB 
dd 0xAED16A4A, 0xD9D65ADC, 0x40DF0B66, 0x37D83BF0 
dd 0xA9BCAE53, 0xDEBB9EC5, 0x47B2CF7F, 0x30B5FFE9 
dd 0xBDBDF21C, 0xCABAC28A, 0x53B39330, 0x24B4A3A6 
dd 0xBAD03605, 0xCDD70693, 0x54DE5729, 0x23D967BF
dd 0xB3667A2E, 0xC4614AB8, 0x5D681B02, 0x2A6F2B94 
dd 0xB40BBE37, 0xC30C8EA1, 0x5A05DF1B, 0x2D02EF8D

rbuffstart: ;for use with networking
times 8212 db 0
