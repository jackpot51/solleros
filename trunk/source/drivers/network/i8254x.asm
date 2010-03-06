;Intel 8254x NIC DRIVER
i8254x:
	call .init
	jmp .end

;REGISTERS
.EEC equ 0x10
.EERD equ 0x14
.RAL equ 0x5400
.RAH equ 0x5404
;CODE
.init:	;should find card, get mac, and initialize card
	xor eax, eax
	mov [pcifunction], al
	mov [pcibus], al
	mov [pcidevice], al
	mov al, 0x02 ;type code
	mov [pcitype], al
	mov eax, 0x10008086
	mov [pcidevid], eax
	mov ebx, 0xFE00FFFF
	mov [pcidevidmask], ebx
	call getpcimem
	cmp ebx, 0xFFFFFFFF
	jne .initnic
	ret
.initnic:
	mov [.basenicaddr], edx
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
	mov edi, .mac
	mov ebx, [.basenicaddr]
	add ebx, .RAL
	xor edx, edx
	mov ecx, 3
.macloop:
	call .eepromread
	mov [edi], ax
	mov [ebx], ax
	inc edx
	add ebx, 2
	add edi, 2
	loop .macloop
	mov ax, 0x8000
	mov [ebx], ax	;set address valid bit

	mov ecx, .mac
	call showmac
	call .resetnic
	mov esi, .name
	call print
	mov esi, .initmsg
	call print
	xor ebx, ebx
	ret
.resetnic:
	mov byte [.nicconfig], 1
	ret

.eepromread:	;location in EEPROM in edx (actually just dl)
	mov esi, [.basenicaddr]
	mov eax, [esi + .EEC]
	or eax, 1000000b
	mov [esi + .EEC], eax	;turn software access on
.waiteeprom:
	mov eax, [esi + .EEC]
	and eax, 10000000b
	cmp eax, 10000000b
	jne .waiteeprom
	mov eax, [esi + .EERD]
	xor eax, eax
	mov ah, dl 	;eeprom address
	or al, 1	;start read
	mov [esi + .EERD], eax
.waiteepromread:
	mov eax, [esi + .EERD]
	and eax, 10000b
	cmp eax, 10000b
	jne .waiteepromread
	mov eax, [esi + .EERD]
	mov ax, [esi + .EEC]
	and al, 10111111b
	mov [esi + .EEC], ax	;turn software access off
	shr eax, 16	;AX has the requested word
	ret
	
.basenicaddr dd 0
.nicconfig db 0
.mac db 0,0,0,0,0,0
.name db "I8254X ",0
.initmsg db "Initialized",10,0
.end:
