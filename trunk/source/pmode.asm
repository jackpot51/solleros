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
	
	mov eax, [newcodecache]
	mov [gdt4 + 2],ax
	mov [gdt5 + 2],ax
	mov [gdtv8086 + 2], ax
	mov [gdtv80862 + 2], ax
	shr eax,16
	mov [gdt4 + 4],al
	mov [gdt5 + 4],al
	mov [gdtv8086 + 4],al
	mov [gdtv80862 + 4],al
	mov [gdt4 + 7],ah
	mov [gdt5 + 7],ah
	mov [gdtv8086 + 7],ah
	mov [gdtv80862 + 7],ah
	
	mov eax, dosprogloc
	add eax, [newcodecache]
	mov [gdtdos + 2],ax
	mov [gdtdos2 + 2],ax
	shr eax,16
	mov [gdtdos + 4],al
	mov [gdtdos2 + 4],al
	mov [gdtdos + 7],ah
	mov [gdtdos2 + 7],ah
	
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
do_pm:
	xor eax, eax
	mov ax, SYS_DATA_SEL
	mov ds,ax
	mov ss,ax	;;can switch back to STACK_SEL later
	mov esp, stackend	;;can switch back to 4096 later
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
	mov es, ax
	mov fs, ax
	mov ax, SYS_DATA_SEL
	mov gs, ax
	
	call initialize	;initialize drivers
	
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
	sti

getmemoryspace:
	mov esi, memlistbuf
	xor edi, edi
	mov di, [memlistend]
	add edi, esi
	xor eax, eax
memoryspaceaddition:
	cmp esi, edi
	jae finishedmemspacecalc
	add esi, 8
	mov ecx, [esi]
	add esi, 8
	mov ebx, [esi]
	add esi, 8
	cmp ebx, 1
	jne memoryspaceaddition
	add eax, ecx
	jmp memoryspaceaddition
finishedmemspacecalc:
	mov [memoryspace], eax
	
	cmp byte [guion], 0
	jne near guistartup
	jmp os
guistartup:	;this prevents weird issues
	jmp gui
	
basecache dd 0
newcodecache dd 0x100000

testingcpuspeed db 0
cpuspeedperint dd 0
memoryspace dd 0
pitdiv dw 2685
timeseconds dd 0
timenanoseconds dd 0
timeinterval dd 2250286;4500572
soundon db 0
soundrepititions dw 0
soundpos dd 0
soundendpos dd 0
WAVSamplingRate dw 0
WAVFileSize         dd 0
EnableDigitized     db 0

cpuspeedend:
	mov byte [testingcpuspeed], 0
	mov [cpuspeedperint], eax
	mov eax, cpuspeedloopend
	mov [esp], eax
	jmp handled

;if using the rtc, the default frequency yeilds a period of 976562.5ns
;if using the pit, div=451 is 377981.0004, div=5370 is 4500572.00007ns
;div=55483 is 46500044.000006ns, div=2685 is 2250286.00004ns, div=902 is 755962.0008

pitinterrupt: ;this controls threading
	cli
	cmp byte [testingcpuspeed], 1	;check to see if the cpu speed test is running
	je cpuspeedend
	
	cmp byte [EnableDigitized], 1
	je near PCSpeakerPWM
	
	call timekeeper ;this updates the internal time
	
	cmp byte [soundon], 1
	je near PCSpeakerRAW
timerinterrupt:	;put this into the interrupt handler that controls threading
	cmp byte [threadson], 1
	je near threadswitch
keyinterrupt:		;checks for escape, if pressed, it quits the program currently running
	cmp byte [threadson], 0
	je near handled
	cli
	pusha
	in al, 60h
	cmp al, 1		;escape
	je userint
	jmp handled2
userint:
	;UNMASK ALL INTS
	xor al, al
	out 0x21, al
	xor al, al
	out 0xA1, al
	mov al, 0x20
	out 0xA0, al
	out 0x20, al
	;RESET PIT DIVISOR
	mov ax, [pitdiv]
	out 0x40, al
	rol ax, 8
	out 0x40, al
	;RESET PIC
	mov al, 0x20
	out 0x20, al
	popa
	sti
	jmp nwcmd

rtl8139.irq:
	cli
	pusha
	mov edx, [basenicaddr]
	add edx, rtl8139.ISR
	xor eax, eax
	in ax, dx
	mov ecx, eax
	call showhex
	mov esi, rtl8139.irq.msg
	call print
	jmp handled2
.msg db 10,"ZOMG TEH RTL8139 REZPONDED",10,0
sblaster.irq:
	cli
	pusha
	cmp byte [SoundBlaster], 1
	je near sblastercont
	jmp handled2
	
timekeeper:
	push eax
	mov eax, [timenanoseconds]
	add eax, [timeinterval]
	cmp eax, 1000000000
	jb nonanosecondrollover
	inc dword [timeseconds]
	sub eax, 1000000000
nonanosecondrollover:
	mov [timenanoseconds], eax
	pop eax
	ret
	
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
V8086_CODE_SEL	equ $-gdt
gdtv8086: dw 0xFFFF
	dw 0
	db 0
	db 0x9A
	db 0x8F
	db 0
V8086_DATA_SEL	equ $-gdt
gdtv80862: dw 0xFFFF
	dw 0
	db 0
	db 0x92
	db 0x8F
	db 0
DOS_CODE_SEL	equ $-gdt	;this gives dos programs complete access to one megabyte at the beginning of memory
gdtdos:	dw 256	;give it 1 MB
	dw 0
	db 0
	db 0x9A
	db 0x8F ;16 bit
	db 0
DOS_DATA_SEL 	equ $-gdt
gdtdos2:	dw 256
	dw 0
	db 0
	db 0x92
	db 0x8F ;16 bit
	db 0
gdt_end:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	interrupt descriptor table (IDT)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 32 reserved interrupts:
idt:	
%assign i 0
%rep    32
		dw unhand + i*13,NEW_CODE_SEL,0x8E00,0
%assign i i+1
%endrep
		dw int20h,NEW_CODE_SEL,0x8E00,0
		dw int21h,NEW_CODE_SEL,0x8E00,0
%assign i 0x22
%rep 14
		dw unhand + i*13,NEW_CODE_SEL,0x8E00,0
%assign i +1
%endrep
;INT 30h for os use and 3rd party use:
		dw newints,NEW_CODE_SEL,0x8E00,0
%assign i 0x31
%rep 15
		dw unhand + i*13,NEW_CODE_SEL,0x8E00,0
%assign i +1
%endrep
;and here we are at 0x40
;here are all the irq's
		dw pitinterrupt,NEW_CODE_SEL,0x8E00,0 ;IRQ 0 = PIT
		dw handled,NEW_CODE_SEL,0x8E00,0 ;IRQ 1 = keyboard
		dw handled,NEW_CODE_SEL,0x8E00,0 ;IRQ 2
		dw handled,NEW_CODE_SEL,0x8E00,0 ;IRQ 3
		dw handled,NEW_CODE_SEL,0x8E00,0 ;IRQ 4
		dw sblaster.irq,NEW_CODE_SEL,0x8E00,0 ;IRQ 5 = default SoundBlaster
		dw handled,NEW_CODE_SEL,0x8E00,0 ;IRQ 6
		dw handled,NEW_CODE_SEL,0x8E00,0 ;IRQ 7
		dw handled,NEW_CODE_SEL,0x8E00,0 ;IRQ 8 = RTC
		dw handled,NEW_CODE_SEL,0x8E00,0 ;IRQ 9
		dw handled,NEW_CODE_SEL,0x8E00,0 ;IRQ 10
		dw rtl8139.irq,NEW_CODE_SEL,0x8E00,0 ;IRQ 11 = default RTL8139
		dw handled,NEW_CODE_SEL,0x8E00,0 ;IRQ 12
		dw handled,NEW_CODE_SEL,0x8E00,0 ;IRQ 13
		dw handled,NEW_CODE_SEL,0x8E00,0 ;IRQ 14
		dw handled,NEW_CODE_SEL,0x8E00,0 ;IRQ 15
;This brings me up to 0x50
%assign i 0x50
%rep 176
		dw handled, NEW_CODE_SEL,0x8E00,0
		;dw unhand + i*13, NEW_CODE_SEL,0x8E00,0
%assign i +1
%endrep
idt_end:
[BITS 32]
