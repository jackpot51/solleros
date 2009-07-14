[BITS 16]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	16-bit real mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pmode:
	mov dx, 0x92
	in al, dx	;;A20
	or al, 2
	out dx, al
	xor ebx, ebx
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
	xor ebx, ebx
	mov bx, ds
	mov [basecache], ebx
	mov eax,cr0
	or al,1
	mov cr0,eax
	jmp SYS_CODE_SEL:do_pm
[BITS 32]
	nop
	nop
	nop
	nop
do_pm:
	xor eax, eax
	mov ax, SYS_DATA_SEL
	mov ds,ax
	mov ss,ax	;;can switch back to STACK_SEL later
	mov esp, stackend	;;can switch back to 4096 later
	nop
	nop
	mov es, ax
	mov fs, ax
	mov ax, NEW_DATA_SEL
	mov gs, ax
	
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
	
;Now I will initialise the interrupt controllers and remap irq's
	mov al, 0x11
	out 0x20, al
	out 0xA0, al
	mov al, 0x40	;interrupt for master
	out 0x21, al
	mov al, 0x48	;interrupt for slave
	out 0xA1, al
	mov al, 4
	out 0x21, al
	mov al, 2
	out 0xA1, al
	mov al, 0x1
	out 0x21, al
	mov al, 0x1
	out 0xA1, al
	;masks are set to zero so as not to mask
	xor al, al
	out 0x21, al
	xor al, al
	out 0xA1, al
	mov al, 0x20
	out 0xA0, al
	out 0x20, al
	;And now to initialize the fpu
	mov eax, cr4
	or eax, 0x200
	mov cr4, eax
	mov eax, 0xB7F
	push eax
	fldcw [esp]
	pop eax
	xor eax, eax
	xor ecx, ecx

	mov eax, [newcodecache]
	shr eax, 4
	mov [basecache], eax
	
	mov ebx, eax
	shl ebx, 4
	mov edi, [physbaseptr]
	sub edi, ebx
	mov [physbaseptr], edi
	
	mov esi, bssstart
	xor eax, eax
clearkernelbuffers:
	mov [esi], eax
	add esi, 4
	cmp esi, bssend
	jb clearkernelbuffers
	cmp byte [guinodo], 1
	je guidonot
	jmp gui
guidonot:
	jmp os
	
user2codepoint dw 0,0
basecache dd 0
newcodecache dd 0x100000

surekillmsg db 10,13,"Kill this application?",10,13,0

timerinterrupt:
	cmp byte [threadson], 1
	jne userinterrupt
	jmp threadswitch
userinterrupt:		;checks for escape, if pressed, it quits the program currently running
	cli
	cmp byte [threadson], 0
	je near handled3
	pusha
	in al, 64h
	test al, 20h
	jnz handled2
	in al, 60h
	cmp al, 1		;escape
	je userint
	jmp handled2
userint:
	mov esi, surekillmsg
	call print
	sti
	call getkey
	cmp al, 'y'
	jne handled2
	mov al, 0x20
	out 0x20, al
	popa
	sti
	jmp nwcmd
handled2:
	popa
handled3:
	sti
handled:
	push eax
	mov al, 0x20
	out 0x20, al
	pop eax
	iret
	jmp $
[BITS 16]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	16-bit limit/32-bit linear base address of GDT and IDT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gdtr:	dw gdt_end - gdt - 1	; GDT limit
	dd 0    		; filled with linear, physical address of GDT

idtr:	dw idt_end - idt - 1	; IDT limit
	dd 0			; filled with linear, physical address of IDT


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
%rep    33
		dw unhand + i*13,NEW_CODE_SEL,0x8E00,0
%assign i i+1
%endrep
		;dw handled,NEW_CODE_SEL,0x8E00,0
		dw int21h,NEW_CODE_SEL,0x8E00,0
%assign i 0x22
%rep 14
		dw unhand + i*13,NEW_CODE_SEL,0x8E00,0
		;dw handled,NEW_CODE_SEL,0x8E00,0
%assign i +1
%endrep
;INT 30h for os use and 3rd party use:
		dw newints,NEW_CODE_SEL,0x8E00,0
;here are all the irq's
%assign i 0x31
%rep 15
		dw unhand + i*13,NEW_CODE_SEL,0x8E00,0
		;dw handled,NEW_CODE_SEL,0x8E00,0
%assign i +1
%endrep
		dw timerinterrupt,NEW_CODE_SEL,0x8E00,0
		dw userinterrupt,NEW_CODE_SEL,0x8E00,0
;%assign i 0x42
%rep 14
		;dw unhand + i*13, NEW_CODE_SEL,0x8E00,0
		dw handled,NEW_CODE_SEL,0x8E00,0
;%assign i +1
%endrep
;This brings me up to something
%assign i 0x50
%rep 176
		dw unhand + i*13, NEW_CODE_SEL,0x8E00,0
		;dw handled,NEW_CODE_SEL,0x8E00,0
%assign i +1
%endrep
idt_end:
[BITS 32]
