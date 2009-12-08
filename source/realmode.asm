realmode:	;make sure the real mode program's address is in realmodeptr 
			;and the return address is in realmodereturn
	cli
	mov [realmodeeax], eax
	mov [realmodeebx], ebx

	mov ebx, cr0old
rmcopytofirstmbyte:
	mov eax, [ebx]
	mov [gs:ebx], eax
	add ebx, 4
	cmp ebx, realmodeptr
	jbe rmcopytofirstmbyte

	jmp V8086_CODE_SEL:protected16bit

[BITS 16]
protected16bit:
	mov ax, V8086_DATA_SEL
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	mov eax, cr0
	mov [cr0old], eax
	and eax, 0x7FFFFFFE
	mov cr0, eax	;now in real mode
	jmp 0x1000:inrealmode

inrealmode:
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	
	mov al, 0x11
	out 0x20, al
	out 0xA0, al
	mov al, 0x8		;interrupt for master
	out 0x21, al
	mov al, 0x70	;interrupt for slave
	out 0xA1, al
	mov al, 4
	out 0x21, al
	mov al, 2
	out 0xA1, al
	mov al, 0x1
	out 0x21, al
	mov al, 0x1
	out 0xA1, al
	
	lidt [idt_real]
	sti

	mov eax, [realmodeeax]
	mov ebx, [realmodeebx]

	call word [realmodeptr] ;call the real mode program here

	mov [realmodeeax], eax
	mov [realmodeebx], ebx

	cli
	lgdt [gdtr]
	lidt [idtr]
	mov eax, cr0
	or al, 1
	mov cr0,eax
	jmp NEW_CODE_SEL:returntopmode

[BITS 32]
returntopmode:
	mov ax, NEW_DATA_SEL
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov ss, ax
	mov ax, SYS_DATA_SEL
	mov gs, ax

	mov ebx, cr0old
rmcopyfromfirstmbyte:
	mov eax, [gs:ebx]
	mov [ebx], eax
	add ebx, 4
	cmp ebx, realmodeptr
	jbe rmcopyfromfirstmbyte

	call initialize.pic ;reset irq's and masks
	sti
	mov eax, [realmodeeax]
	mov ebx, [realmodeebx]
	jmp dword [realmodereturn]

idt_real:
	dw 0x3FF
	dd 0
cr0old dd 0
realmodeebx dd 0
realmodeeax dd 0
realmodereturn dd 0
realmodeptr dw 0
dd 0 ;make sure the copy thing doesnt overflow
