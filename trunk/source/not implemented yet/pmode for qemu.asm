[BITS 16]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	16-bit real mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
	mov eax, 0x100000
	mov [gdt4 + 2],ax
	mov [gdt5 + 2],ax
	shr eax,16
	mov [gdt4 + 4],al
	mov [gdt5 + 4],al
	mov [gdt4 + 7],ah
	mov [gdt5 + 7],ah	
	mov eax, stack
	mov [gdts + 2],ax
	shr eax,16
	mov [gdts + 4],al
	mov [gdts + 7],ah
; fix up TSS entries, too
	lea eax,[ebx + stss]	; EAX=linear address of stss
	mov [gdt6 + 2],ax
	shr eax,16
	mov [gdt6 + 4],al
	mov [gdt6 + 7],ah
	lea eax,[ebx + utss1]	; EAX=linear address of utss1
	mov [gdt7 + 2],ax
	shr eax,16
	mov [gdt7 + 4],al
	mov [gdt7 + 7],ah
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
	mov ax, STACK_SEL
	mov ss, ax
	mov esp, 4096
	nop
	nop
	mov ax, SYS_DATA_SEL
	mov es,ax
	mov fs,ax
	mov ax, NEW_DATA_SEL
	mov gs,ax
	mov eax,user1
	mov [utss1_eip],eax
	mov eax, 4096
	sub eax, 512
	mov [utss1_esp],eax
	mov esi, 0
copykernel:
	mov eax, [fs:esi]
	mov [gs:esi], eax
	add esi, 4
	cmp esi, bssstart
	jb copykernel
	mov eax, 0
	mov esi, bssstart
clearkernelbuffers:
	mov [gs:esi], eax
	add esi, 4
	cmp esi, bssend
	jb clearkernelbuffers
	jmp NEW_CODE_SEL:done_copy

done_copy:
	mov ax, NEW_DATA_SEL
	mov ds, ax
	mov ax, STACK_SEL
	mov ss, ax
	mov esp, 4096
	nop
	mov ax, NEW_DATA_SEL
	mov es, ax
	mov fs, ax
	mov ax, SYS_DATA_SEL
	mov gs, ax
	mov ax,SYS_TSS
	ltr ax
	mov eax, 0x100000
	shr eax, 4
	mov [basecache], eax
	jmp user1
	mov al, 0xFE
	out 0x21, al
sched:
	jmp USER1_TSS:0
	mov [gs:gdt7 + 5],byte 0x89
	mov al, 0x20
	out 0x20, al
	jmp sched
user1:
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

;handled:
;	ret
	
;switchprocess:	;;get all stuff off stack
;	cli
;	pushad
;	mov esi, esp
;	add esi, 40
;	mov [swesploc], esi
;	mov esi, swprcsstack
;swdumpstack:
;	mov esi, [swesploc]
;	cmp esi, esp
;	jb swdonedump
;	mov ecx, [esi]
;	sub esi, 4
;	mov [swesploc], esi
;	jmp swdumpstack
;swdonedump:
;	jmp $
	;jmp processswitch
	
;swesploc dd 0	
;swprcsstack:	;;copied code from unhand
;swflags dd  0
;swcs	dd 	0
;sweip	dd	0
;sweax	dd 	0
;swecx	dd	0
;swedx	dd	0
;swebx	dd	0
;swesp	dd	0
;swebp	dd	0
;swesi	dd	0
;swedi	dd	0

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
	add esi, ((unhndrgend - unhndrg)/13)*4
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
	unhandmsg	
			db "INT 00000000",0
unhndrg:
			db "EFL=00000000",0
			db "CS:=00000000",0
			db "EIP=00000000",0
			db "EAX=00000000",0
			db "ECX=00000000",0
			db "EDX=00000000",0
			db "EBX=00000000",0
			db "ESP=00000000",0
			db "EBP=00000000",0
			db "ESI=00000000",0
unhndrgend:	db "EDI=00000000",0
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
STACK_SEL	equ	$-gdt
gdts:	dw 1
	dw 0			; (base gets set above)
	db 0
	db 0x92			; present, ring 0, data, expand-up, writable
	db 0xC0
	db 0
; system TSS
SYS_TSS		equ	$-gdt
gdt6:	dw 103
	dw 0			; set to stss
	db 0
	db 0x89			; present, ring 0, 32-bit available TSS
	db 0
	db 0
; user TSS 1
USER1_TSS	equ	$-gdt
gdt7:	dw 103
	dw 0			; set to utss1
	db 0
	db 0x89			; present, ring 0, 32-bit available TSS
	db 0
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
        dw unhand + i*13,NEW_CODE_SEL,0x8E00,0
%assign i i+1 
%endrep

;;timer interrupt
	dw 0
	dw SYS_TSS
	db 0
	db 0x85			; Ring 0 task gate
	dw 0

%assign i 9
%rep    39
        dw unhand + i*13,NEW_CODE_SEL,0x8E00,0
%assign i i+1 
%endrep
;;INT 30h for os use and 3rd party use:
	dw newints,NEW_CODE_SEL,0x8E00,0
idt_end:

stss:	dw 0, 0			; back link
	dd 0			; ESP0
	dw 0, 0			; SS0, reserved
	dd 0			; ESP1
	dw 0, 0			; SS1, reserved
	dd 0			; ESP2
	dw 0, 0			; SS2, reserved
	dd 0, 0, 0		; CR3, EIP, EFLAGS
	dd 0, 0, 0, 0		; EAX, ECX, EDX, EBX
	dd 0, 0, 0, 0		; ESP, EBP, ESI, EDI
	dw 0, 0			; ES, reserved
	dw 0, 0			; CS, reserved
	dw 0, 0			; SS, reserved
	dw 0, 0			; DS, reserved
	dw 0, 0			; FS, reserved
	dw 0, 0			; GS, reserved
	dw 0, 0			; LDT, reserved
	dw 0, 0			; debug, IO perm. bitmap

utss1:	dw 0, 0			; back link
	dd 0			; ESP0
	dw 0, 0			; SS0, reserved
	dd 0			; ESP1
	dw 0, 0			; SS1, reserved
	dd 0			; ESP2
	dw 0, 0			; SS2, reserved
	dd 0			; CR3
utss1_eip:
	dd 0, 0x200		; EIP, EFLAGS (EFLAGS=0x200 for ints)
	dd 0, 0, 0, 0		; EAX, ECX, EDX, EBX
utss1_esp:
	dd 0, 0, 0, 0		; ESP, EBP, ESI, EDI
	dw NEW_DATA_SEL, 0	; ES, reserved
	dw NEW_CODE_SEL, 0	; CS, reserved
	dw NEW_DATA_SEL, 0	; SS, reserved
	dw NEW_DATA_SEL, 0	; DS, reserved
	dw NEW_DATA_SEL, 0	; FS, reserved
	dw NEW_DATA_SEL, 0	; GS, reserved
	dw 0, 0			; LDT, reserved
	dw 0, 0			; debug, IO perm. bitmap	
[BITS 32]