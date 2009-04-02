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
	mov byte [firsthexshown],0
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
	cmp al, 0x1A
	jae dumppcidn
	mov byte [firsthexshown],0
	call showhex
	jmp dumppcidevicelp
dumppcidn:
	mov byte [firsthexshown],0
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
			
