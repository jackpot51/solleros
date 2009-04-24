[BITS 16]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	16-bit real mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pmode:
	mov dx, 0x92
	in al, dx	;;A20
	or al, 2
	out dx, al
	mov ebx, 0
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
	mov eax, stack
	mov [gdts + 2],ax
	shr eax,16
	mov [gdts + 4],al
	mov [gdts + 7],ah
	mov eax, [newcodecache]
	mov [gdt4 + 2],ax
	mov [gdt5 + 2],ax
	shr eax,16
	mov [gdt4 + 4],al
	mov [gdt5 + 4],al
	mov [gdt4 + 7],ah
	mov [gdt5 + 7],ah
; fix up gdt and idt
	lea eax,[ebx + gdt]	; EAX=linear address of gdt
	mov [gdtr + 2],eax
	lea eax,[ebx + idt]	; EAX=linear address of idt
	mov [idtr + 2],eax
	cli
	lgdt [gdtr]
	lidt [idtr]
	mov ebx, 0
	mov bx, ds
	mov [basecache], ebx
	mov eax,cr0
	or al,1
	mov cr0,eax
	jmp SYS_CODE_SEL:do_pm
[BITS 32]
do_pm:
	mov ax, SYS_DATA_SEL
	mov ds,ax
	mov ss, ax	;;can switch back to STACK_SEL later
	mov esp, stackend	;;can switch back to 4096 later
	nop
	nop
	mov ax, SYS_DATA_SEL
	mov es,ax
	mov fs,ax
	mov ax, NEW_DATA_SEL
	mov gs,ax
	mov esi, 0
	
copykernel:
	mov eax, [fs:esi]
	mov [gs:esi], eax
	add esi, 4
	cmp esi, bssstart
	jb copykernel
	jmp NEW_CODE_SEL:done_copy
	
done_copy:
	mov ax, NEW_DATA_SEL	;;these MUST be setup AFTER the kernel switches places!!!
	mov ds, ax
	mov ss, ax
	mov esp, stackend
	nop
	nop
	mov ax, NEW_DATA_SEL
	mov es, ax
	mov fs, ax
	mov ax, SYS_DATA_SEL
	mov gs, ax
	
	mov eax, [newcodecache]
	shr eax, 4
	mov [basecache], eax
	mov esi, bssstart
	mov eax, 0
clearkernelbuffers:
	mov [esi], eax
	add esi, 4
	cmp esi, bssend
	jb clearkernelbuffers	
	
	mov edi, [physbaseptr]
	mov eax, [basecache]
	shl eax, 4
	sub edi, eax
	mov [physbaseptr], edi
	call indexfiles
	cmp byte [guinodo], 0
	je near guido
	jmp os
	
guido:
	jmp gui
	
user2codepoint dw 0,0
basecache dd 0
newcodecache dd 0x110000
	

unhand:	
	%assign i 0
	%rep 40
	cli
	mov byte [intprob], i
	jmp unhand2
	%assign i i+1
	%endrep
unhand2:
	push ds
	push es
	push fs
	push gs
	push ss
	pushad
	mov esi, esp
	add esi, ((unhndrgend - unhndrg)/15)*4
	mov [esploc], esi
	mov esi, unhandmsg
	mov [esiloc], esi
	mov esi, line
	call print
	mov ecx, 0
	mov cl, [intprob]
	call expdump
dumpstack:
	mov esi, [esploc]
	cmp esi, esp
	jb donedump
	mov ecx, [ss:esi]
	sub esi, 4
	mov [esploc], esi
	call expdump
	jmp dumpstack
donedump:
	mov esi, [esploc]
	mov edi, [ss:esp + 32]
	mov ecx, [edi - 4]
	call expdump
	mov esi, [esploc]
	mov edi, [ss:esp + 32]
	mov ecx, [edi]
	call expdump
	mov esi, [esploc]
	mov edi, [ss:esp + 32]
	mov ecx, [edi + 4]
	call expdump
	mov esi, backtoosmsg
	call print
	mov al, 0
	call int302
	cmp byte [intprob], 3
	jne nodebugint
	mov esi, [esploc]
	mov esp, esi
	popad
	pop ss
	pop gs
	pop fs
	pop es
	pop ds
	iret
nodebugint:
	cmp byte [guion], 0
	jne returnunhandgui
	jmp nwcmd
returnunhandgui:
	call guiclear
	call reloadallgraphics
	jmp guistart
backtoosmsg db "Press any key to return to SollerOS",10,13,0
expdump:
	mov esi, [esiloc]
	mov edi, esi
	add edi, 15
	add esi, 4
	mov [esiloc], edi
	sub edi, 3
	call converthex
	sub esi, 4
	cmp byte [guion], 0
	je near expdumptext
	mov cx, [locunhand]
	add word [locunhand], 16
	mov dx, 2
	mov ax, 1
	mov bx, 0
	call showstring2
	ret
expdumptext:
	call print
	ret
esploc dd 0
esiloc dd 0
locunhand dw 1
intprob db 0
	unhandmsg:	
			db "INT=00000000",10,13,0
unhndrg:
   times 40 db "  ",8,8,"00000000  ",0	;;this dumps the stack before the stack frame in question
			db "EFL=00000000",10,13,0
			db "CS:=00000000",10,13,0
			db "EIP=00000000",10,13,0
			db "DS:=00000000",10,13,0
			db "ES:=00000000",10,13,0
			db "FS:=00000000",10,13,0
			db "GS:=00000000",10,13,0
			db "SS:=00000000",10,13,0
			db "EAX=00000000",10,13,0
			db "ECX=00000000",10,13,0
			db "EDX=00000000",10,13,0
			db "EBX=00000000",10,13,0
			db "ESP=00000000",10,13,0
			db "EBP=00000000",10,13,0
			db "ESI=00000000",10,13,0
unhndrgend:	db "EDI=00000000",10,13,0
			db "CMD=00000000",10,13,0
			db "CMD=00000000",10,13,0
			db "CMD=00000000",10,13,0
unhandmsgend:

timerinterrupt:
	cmp byte [threadson], 1
	jne handled
	jmp threadswitch
	
handled:
	iret

align 4, db 0	;;this makes me feel safer
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
STACK_SEL	equ	$-gdt	;;this is no longer used for various reasons
gdts:	dw 1
	dw 0			; (base gets set above)
	db 0
	db 0x92			; present, ring 0, data, expand-up, writable
	db 0xC0
	db 0
currentcodesel  equ $-gdt		;move this to wherever it should be
NEW_CODE_SEL	equ	$-gdt
gdt4:	dw 0xFFFF
	dw 0			; (base gets set above)
	db 0
	db 0x9A			; present, ring 0, code, non-conforming, readable
	db 0xCF
	db 0
; data segment descriptor
NEW_DATA_SEL	equ	$-gdt
gdt5:	dw 0xFFFF
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
idt:	
%assign i 0
%rep    8
        dw unhand + i*13,currentcodesel,0x8E00,0
%assign i i+1 
%endrep
		dw timerinterrupt,currentcodesel,0x8E00,0
%assign i 9
%rep    6
        dw unhand + i*13,currentcodesel,0x8E00,0
%assign i i+1 
%endrep
		dw handled,currentcodesel,0x8E00,0		;;irq 7 or int 0xF is random, unusable, and usually reserved
%assign i 16
%rep    32
		dw unhand + i*13,currentcodesel,0x8E00,0
%assign i i+1
%endrep
		
;;INT 30h for os use and 3rd party use:
	dw newints,currentcodesel,0x8E00,0
idt_end:
[BITS 32]
