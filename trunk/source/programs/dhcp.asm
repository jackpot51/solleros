db 255,44,"dhcp",0
dhcp:
	mov esi, .dhcp.mac
	mov ebx, .dhcp.option.mac
	mov edi, .mac
	xor ecx, ecx
	mov [.ip.checksum], cx
	mov [.udp.checksum], cx
	mov ecx, [sysmac]
	mov [ebx], ecx
	mov [edi], ecx
	mov [esi], ecx
	mov cx, [sysmac + 4]
	mov [ebx + 4], cx
	mov [esi + 4], cx
	mov [edi + 4], cx
	mov edi, .ip.header
	mov esi, .ip.headerend
	call getchecksum
	mov [.ip.checksum], cx
	mov edi, .udp.header
	mov esi, .udp.end
	call getchecksum
	mov [.udp.checksum], cx
	mov edi, .frame
	mov esi, .udp.end
	call sendpacket
	ret
.udpsize equ (.udp.end - .ip.header)
.frame:
	.destmac db 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
	.mac db 0,0,0,0,0,0
	db 8,0
.ip.header:
	db (0x40 | (.ip.headerend - .ip.header)/4)
	db 0
	db .udpsize/256, .udpsize % 256
	dw 0
	dw 0
	db 0x80
	db 17
.ip.checksum dw 0
	db 0,0,0,0
	db 255,255,255,255	
.ip.headerend:
.udp.header:
	db 0,68	;source port
	db 0,67 ;destination port
	db .udpsize/256, .udpsize % 256
.udp.checksum dw 0
.udp.headerend:
.dhcp.data:
	db 1	;message type
	db 1	;hardware type
	db 6	;hardware address length
	db 0	;hops
	db 0xEC,0x2B,0x23,0x69	;transaction ID
	db 0,0	;seconds elapsed
	db 0,0	;flags
	db 0,0,0,0	;client ip address
	db 0,0,0,0	;your ip address
	db 0,0,0,0	;server ip address
	db 0,0,0,0	;relay agent ip address
.dhcp.mac db 0,0,0,0,0,0	;client hardware address
	times 10 db 0	;padding
	times 64 db 0	;server host name
	times 128 db 0	;boot file name
	db 0x63,0x82,0x53,0x63	;magic cookie
.dhcp.option.type:
	db 53,1,3	;DHCP Request
	db 50,4,192,168,0,2	;requested IP
	db 61,7 ;client id(mac)
	db 1	;Type=Ethernet
.dhcp.option.mac:	db 0,0,0,0,0,0
	db 12,8 ;host name
.dhcp.option.name 	db "SollerOS"
	db 55,4,1,3,15,6	;request subnet, router, domain name, name server
	db 0xFF	;end DHCP options
.dhcp.end:
.udp.end:
	
