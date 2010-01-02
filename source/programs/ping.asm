db 255,44,"ping",0
ping:
	mov esi, [currentcommandloc]
	add esi, 5
	call strtoip
	mov [.destip], ecx
	call showip
	mov ecx, [sysip]
	mov [.sourceip]. ecx
	mov eax, [sysmac]
	mov [.sourcemac], eax
	mov ax, [sysmac + 4]
	mov [.sourcemac + 4], ax
	xor eax, eax
	xor ebx, ebx
	mov [.checksum], ax
	mov [.icmpchecksum], ax
	mov edi, .header
	mov esi, .headerend
	call getchecksum
	mov [.checksum], cx
	mov edi, .icmp
	mov esi, .packetend
	call getchecksum
	mov [.icmpchecksum], cx
	mov edi, .packet
	mov esi, .packetend
	call sendpacket
	mov esi, line
	call print
	ret
	
	
	
.packet:
.destinationmac db 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
.sourcemac	db 0,0,0,0,0,0
.ethertype	db 8,0	;ip is 0x800
.header:
.version	db 0x45
.services	db 0
.length	db 0,0x3C
.id		dw 0
.flags	db 0
.fragment db 0
.ttl	db 128
.protocol db 1 ;ICMP
.checksum dw 0
.sourceip dd 0
.destip dd 0
.headerend:
.icmp:
.icmptype db 8 ;Ping request
.icmpcode db 0
.icmpchecksum dd 0
.icmpid dw 1
.sequence dw 0
db "abcdefghijklmnopqrstuvwabcdefghi" ;this is what microsoft includes
.packetend