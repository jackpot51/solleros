db 255,44,"ifconfig",0
ifconfig:
	mov esi, [currentcommandloc]
	add esi, 9
	cmp byte [esi], 0
	je .noip
	call strtoip
	mov [sysip], ecx
.noip:
%ifdef ne2000.included
	cmp byte [ne2000.nicconfig], 1
	jne .none2000
	mov esi, ne2000.name
	call print
	mov ecx, ne2000.mac
	call showmac
	mov esi, line
	call print
.none2000:
%endif
%ifdef rtl8139.included
	cmp byte [rtl8139.nicconfig], 1
	jne .nortl8139
	mov esi, rtl8139.name
	call print
	mov ecx, rtl8139.mac
	call showmac
	mov esi, line
	call print
.nortl8139:
%endif
	mov ecx, [sysip]
	call showip
	mov esi, line
	call print
	ret
	