;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	16-bit real mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
[BITS 16]
pmode:
	mov dx, 0x92
	in al, dx	;;A20
	or al, 2
	out dx, al
	xor ebx,ebx
	mov bx,cs		; EBX=segment
	shl ebx,4		;	<< 4
	lea eax,[ebx]		; EAX=linear address of segment base
	mov [gdt2 + 2],ax
	mov [gdt3 + 2],ax
	shr eax,16
	mov [gdt2 + 4],al
	mov [gdt3 + 4],al
	mov [gdt2 + 7],ah
	mov [gdt3 + 7],ah
; fix up gdt and idt
	lea eax,[ebx + gdt]	; EAX=linear address of gdt
	mov [gdtr + 2],eax
	lea eax,[ebx + idt]	; EAX=linear address of idt
	mov [idtr + 2],eax
	cli
	lgdt [gdtr]
	lidt [idtr]
	mov ax, ds
	mov [cscache], ax
	mov eax,cr0
	or al,1
	mov cr0,eax
	jmp SYS_CODE_SEL:do_pm
[BITS 32]
do_pm:
	mov ax, SYS_DATA_SEL
	mov ds,ax
	mov ss,ax
	nop
	mov es,ax
	mov fs,ax
	mov gs,ax

	mov edi, [physbaseptr]
	mov eax, 0
	mov ax, [cscache]
	shl eax, 4
	sub edi, eax
	mov [physbaseptr], edi
	
	cmp byte [guinodo], 0
	je near gui
	jmp os
	
user2codepoint dw 0,0
cscache dw 0

handled:
	ret

unhand:	
	%assign i 0
	%rep 40
	cli
	mov byte [intprob], i
	jmp unhand2
	%assign i i+1
	%endrep
unhand2:
	pushad
	mov dword [user2codepoint], 0
	mov esi, esp
	add esi, 36
	mov [esploc], esi
	mov esi, unhandmsg
	mov [esiloc], esi
	mov ecx, 0
	mov cl, [intprob]
	call expdump
dumpstack:
	mov esi, [esploc]
	cmp esi, esp
	jb donedump
	mov ecx, [esi]
	sub esi, 4
	mov [esploc], esi
	call expdump
	jmp dumpstack
donedump:
	mov esi, [esploc]
	mov edi, [esp + 32]
	mov ecx, [edi - 4]
	call expdump
	mov esi, [esploc]
	mov edi, [esp + 32]
	mov ecx, [edi]
	call expdump
	mov esi, [esploc]
	mov edi, [esp + 32]
	mov ecx, [edi + 4]
	call expdump
	jmp $
expdump:
	mov esi, [esiloc]
	mov edi, esi
	add edi, 13
	add esi, 4
	mov [esiloc], edi
	dec edi
	call converthex
	sub esi, 4
	cmp byte [guion], 0
	je near expdumptext
	mov cx, [locunhand]
	add word [locunhand], 16
	mov dx, 2
	mov ax, 1
	mov bx, 0
	call showstring
	ret
expdumptext:
	call print
	mov esi, line
	call print
	ret
esploc dd 0
esiloc dd 0
locunhand dw 1
intprob db 0
	unhandmsg	db "INT 00000000",0
			db "CS:=00000000",0
			db "EIP=00000000",0
			db "EAX=00000000",0
			db "ECX=00000000",0
			db "EDX=00000000",0
			db "EBX=00000000",0
			db "ESP=00000000",0
			db "EBP=00000000",0
			db "ESI=00000000",0
			db "EDI=00000000",0
			db "CMD=00000000",0
			db "CMD=00000000",0
			db "CMD=00000000",0
unhandmsgend:

[BITS 16]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	16-bit limit/32-bit linear base address of GDT and IDT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gdtr:	dw gdt_end - gdt - 1	; GDT limit
	dd gdt			; linear, physical address of GDT

idtr:	dw idt_end - idt - 1	; IDT limit
	dd idt			; linear, physical address of IDT


gdt:	dw 0			; limit 15:0
	dw 0			; base 15:0
	db 0			; base 23:16
	db 0			; type
	db 0			; limit 19:16, flags
	db 0			; base 31:24
; linear data segment descriptor
LINEAR_SEL	equ	$-gdt
	dw 0xFFFF		; limit 0xFFFFF
	dw 0			; base for this one is always 0
	db 0
	db 0x92			; present, ring 0, data, expand-up, writable
	db 0xCF			; page-granular, 32-bit
	db 0
; code segment descriptor
SYS_CODE_SEL	equ	$-gdt
gdt2:	dw 0xFFFF
	dw 0			; (base gets set above)
	db 0
	db 0x9A			; present, ring 0, code, non-conforming, readable
	db 0xCF
	db 0
; data segment descriptor
SYS_DATA_SEL	equ	$-gdt
gdt3:	dw 0xFFFF
	dw 0			; (base gets set above)
	db 0
	db 0x92			; present, ring 0, data, expand-up, writable
	db 0xCF
	db 0
gdt_end:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	interrupt descriptor table (IDT)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 32 reserved interrupts:
db "IDT"
dw unhand
idt:	
%assign i 0 
%rep    8
        dw unhand + i*13,SYS_CODE_SEL,0x8E00,0
%assign i i+1 
%endrep

	dw handled, SYS_CODE_SEL, 0x8E00, 0

%assign i 9
%rep    39
        dw unhand + i*13,SYS_CODE_SEL,0x8E00,0
%assign i i+1 
%endrep

;;INT 30h for os use and 3rd party use:
	dw newints,SYS_CODE_SEL,0x8E00,0
idt_end:
[BITS 32]