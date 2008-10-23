        ; these are used in the processor identification
        ; Here's the locations of my IDT and GDT.  Remember, Intel's are
        ; little endian processors, therefore, these are in reversed order.
        ; Also note that lidt and lgdt accept a 32-bit address and 16-bit 
        ; limit, therefore, these are 48-bit variables.
        idtr            dw idt_end-idt-1 ; limit IDT slots
                        dd idt        ; starting at IDT

	gdtr
		        dw gdt_end-gdt-1
			dd gdt
[BITS 16]

pmode:
	;;jmp a20set	;;fuck all this stuff down below

; set base of code/data descriptors to CS<<4/DS<<4 (CS=DS)
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
	
	xor ebx, ebx
	mov bx, videobuf2
	shl ebx, 4
	lea eax, [ebx]
	mov [gdt5 + 2], ax
	shr eax, 16
	mov [gdt5 + 4], al
	mov [gdt5 + 7], ah
	
	xor ebx, ebx
	mov bx, 0xA000
	shl ebx, 4
	lea eax, [ebx]
	mov [gdt4 + 2], ax
	shr eax, 16
	mov [gdt4 + 4], al
	mov [gdt4 + 7], ah

a20set:
        ; set A20 line
	cli		;no more ints
        xor ax, ax
clear_buf:
        in al, 64h              ; get input from keyboard status port
        test al, 02h            ; test the buffer full flag
        loopnz clear_buf        ; loop until buffer is empty
        mov al, 0D1h            ; keyboard: write to output port
        out 64h, al             ; output command to keyboard
clear_buf2:
        in al, 64h              ; wait 'till buffer is empty again
        test al, 02h
        loopnz clear_buf2
        mov al, 0dfh            ; keyboard: set A20
        out 60h, al             ; send it to the keyboard controller
        mov cx, 140h
wait_kbc:                       ; this is approx. a 25uS delay to wait

        loop wait_kbc           ; command.

        ; the A20 line is on now.  Let's load in our IDT and GDT tables...
        ; Ideally, there will actually be data in their locations (by loading 
        ; the kernel)
        lidt [idtr]
        lgdt [gdtr]
        ; now let's enter pmode...

        mov eax, cr0            ; load the control register in
        or  al, 1               ; set bit 1: pmode bit
        mov cr0, eax            ; copy it back to the control register
        jmp $+2     ; and clear the prefetch queue
        nop
        nop
[BITS 32] 
pm:	
	;;ret	;;;let's just return for now
		;;;
	mov ax, SYS_DATA_SEL
	mov ds,ax
	mov ss,ax
	nop
	mov es,ax
	;mov ax, TEXT_SEL
	;mov fs,ax
	;mov ax, GRAPHICS_SEL
	;mov gs,ax
	ret

unhand:
	cli
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	global descriptor table (GDT)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; null descriptor
gdt:	dw 0			; limit 15:0
	dw 0			; base 15:0
	db 0			; base 23:16
	db 0			; type
	db 0			; limit 19:16, flags
	db 0			; base 31:24

;;gdt_end:	;;;
		;;;NEW GDT END FOR COMPATABILITY
		;;;
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
GRAPHICS_SEL	equ	$-gdt
gdt4:	dw 0xFFFF
	dw 0
	db 0
	db 0x92
	db 0xCF
	db 0
TEXT_SEL	equ	$-gdt
gdt5:	dw 0xFFFF
	dw 0
	db 0
	db 0x92
	db 0xCF
	db 0
gdt_end: 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	interrupt descriptor table (IDT)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 32 reserved interrupts:
idt:	dw unhand		; entry point 15:0
	dw SYS_CODE_SEL		; selector
	db 0			; word count
	db 0x8E			; type (32-bit Ring 0 interrupt gate)
	dw 0			; entry point 31:16 (XXX - unhand >> 16)

	dw unhand
	dw SYS_CODE_SEL
	db 0
	db 0x8E
	dw 0

	dw unhand
	dw SYS_CODE_SEL
	db 0
	db 0x8E
	dw 0

	dw unhand
	dw SYS_CODE_SEL
	db 0
	db 0x8E
	dw 0

	dw unhand
	dw SYS_CODE_SEL
	db 0
	db 0x8E
	dw 0

	dw unhand
	dw SYS_CODE_SEL
	db 0
	db 0x8E
	dw 0

	dw unhand
	dw SYS_CODE_SEL
	db 0
	db 0x8E
	dw 0

	dw unhand
	dw SYS_CODE_SEL
	db 0
	db 0x8E
	dw 0

	dw unhand
	dw SYS_CODE_SEL
	db 0
	db 0x8E
 	dw 0
; INT 8 is IRQ0 (timer interrupt). The 8259's can (and should) be
; reprogrammed to assign the IRQs to higher INTs, since the first
; 32 INTs are Intel-reserved. Didn't IBM or Microsoft RTFM?
;	dw 0
;	dw SYS_TSS
;	db 0
;	db 0x85			; Ring 0 task gate
;	dw 0

	dw unhand
	dw SYS_CODE_SEL
	db 0
	db 0x8E
	dw 0

	dw unhand
	dw SYS_CODE_SEL
	db 0
	db 0x8E
	dw 0

	dw unhand
	dw SYS_CODE_SEL
	db 0
	db 0x8E
	dw 0

	dw unhand
	dw SYS_CODE_SEL
	db 0
	db 0x8E
	dw 0

	dw unhand
	dw SYS_CODE_SEL
	db 0
	db 0x8E
	dw 0

	dw unhand
	dw SYS_CODE_SEL
	db 0
	db 0x8E
	dw 0

	dw unhand
	dw SYS_CODE_SEL
	db 0
	db 0x8E
	dw 0

	dw unhand
	dw SYS_CODE_SEL
	db 0
	db 0x8E
	dw 0

	dw unhand
	dw SYS_CODE_SEL
	db 0
	db 0x8E
	dw 0

	dw unhand
	dw SYS_CODE_SEL
	db 0
	db 0x8E
	dw 0

	dw unhand
	dw SYS_CODE_SEL
	db 0
	db 0x8E
	dw 0

	dw unhand
	dw SYS_CODE_SEL
	db 0
	db 0x8E
	dw 0

	dw unhand
	dw SYS_CODE_SEL
	db 0
	db 0x8E
	dw 0

	dw unhand
	dw SYS_CODE_SEL
	db 0
	db 0x8E
	dw 0

	dw unhand
	dw SYS_CODE_SEL
	db 0
	db 0x8E
	dw 0

	dw unhand
	dw SYS_CODE_SEL
	db 0
	db 0x8E
	dw 0

	dw unhand
	dw SYS_CODE_SEL
	db 0
	db 0x8E
	dw 0

	dw unhand
	dw SYS_CODE_SEL
	db 0
	db 0x8E
	dw 0

	dw unhand
	dw SYS_CODE_SEL
	db 0
	db 0x8E
	dw 0

	dw unhand
	dw SYS_CODE_SEL
	db 0
	db 0x8E
	dw 0

	dw unhand
	dw SYS_CODE_SEL
	db 0
	db 0x8E
	dw 0

	dw unhand
	dw SYS_CODE_SEL
	db 0
	db 0x8E
	dw 0

	dw unhand
	dw SYS_CODE_SEL
	db 0
	db 0x8E
	dw 0
idt_end: