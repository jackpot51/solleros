;Intel 8254x NIC DRIVER
i8254x:
	call .init
	jmp .end

;REGISTERS
.EEC equ 0x10
.EERD equ 0x14
.TCTL equ 0x400
.TIPG equ 0x410
.TDBAL equ 0x3800
.TDBAH equ 0x3804
.TDLEN equ 0x3808
.TDH equ 0x3810
.TDT equ 0x3818
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
	mov ebx, [.basenicaddr]
	; Setup Control Register
	mov eax, 0x361
	mov [ebx], eax
	; Setup Transmission Descriptors
	mov edi, .tdesc
	mov eax, [basecache]
	shl eax, 4
	add eax, edi
	mov [ebx + .TDBAL], eax
	xor eax, eax
	mov [ebx + .TDH], eax
	mov [ebx + .TDT], eax
	mov [ebx + .TDBAH], eax
	mov ax, 128
	mov [ebx + .TDLEN], eax
	mov eax, 0x104010A
	mov [ebx + .TCTL], eax	;turn on transmission, set up other registers
	mov eax, 0x50280A
	mov [ebx + .TIPG], eax	;setup TIPG
	;Setup Receive Registers
	mov edi, .mac
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
	mov esi, .name
	call print
	mov esi, .initmsg
	call print
	mov byte [.nicconfig], 1
	xor ebx, ebx
	ret
	
.sendpacket:
	cmp byte [.nicconfig], 0
	jne .sendit
	push esi
	push edi
	call .init
	pop edi
	pop esi
	cmp ebx, 0
	je .sendit
	ret
.sendit	;packet start in edi, packet end in esi
	mov ecx, [.mac]
	mov [edi + 6], ecx
	mov cx, [.mac + 4]
	mov [edi + 10], cx	;copy the correct mac
	mov ebx, [.basenicaddr]
	sub esi, edi
	mov eax, [basecache]
	shl eax, 4
	add eax, edi	;ALWAYS ADD THE VIRTUAL MEMORY OFFSET!
	mov [.tdesc], eax	;Low Address
	mov [.tdesc + 8], esi	;Length
	mov eax, 0xB00
	mov [.tdesc + 10], eax	;Command
	mov eax, 16
	mov [ebx + .TDT], eax	;Trail of TDESC ring buffer
.checksta:
	mov ecx, [.tdesc + 12]
	and ecx, 1
	cmp ecx, 0
	je .checksta
	xor ebx, ebx
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
align 16, db 0
.tdesc:
	dd 0	;Address Low = 0
	dd 0	;Address High = 4
	dw 0	;Length = 8
	db 0	;CSO = 10
	db 0	;CMD = 11
	db 0	;STA, RSV = 12
	db 0	;CSS = 13
	dw 0	;Special = 14
times (128-16) db 0
.end:
