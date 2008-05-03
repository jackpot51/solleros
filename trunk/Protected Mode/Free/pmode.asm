        ; these are used in the processor identification
        ; Here's the locations of my IDT and GDT.  Remember, Intel's are
        ; little endian processors, therefore, these are in reversed order.
        ; Also note that lidt and lgdt accept a 32-bit address and 16-bit 
        ; limit, therefore, these are 48-bit variables.
        pIDT            dw 7FFh         ; limit of 256 IDT slots
                        dd 0000h        ; starting at 0000

        pGDT            dw 17FFh        ; limit of 768 GDT slots
                        dd 0800h        ; starting at 0800h (after IDT)
	linenum:	db 0
	charnum:	db 0
	attrib:		db 7

pmode:
	mov ax, 3h
	int 10h
	mov ax, 0B800h
	mov gs, ax
	mov byte [gs:0], '1'

        ; set A20 line
	cli		;no more ints
        xor cx, cx
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
        mov cx, 14h
wait_kbc:                       ; this is approx. a 25uS delay to wait
        out 0edh, ax            ; for the kb controler to execute our 
        loop wait_kbc           ; command.

        ; the A20 line is on now.  Let's load in our IDT and GDT tables...
        ; Ideally, there will actually be data in their locations (by loading 
        ; the kernel)
        lidt [pIDT]
        lgdt [pGDT]

        ; now let's enter pmode...

        mov eax, cr0            ; load the control register in
        or  al, 1               ; set bit 1: pmode bit
        mov cr0, eax            ; copy it back to the control register
        jmp $+2                 ; and clear the prefetch queue
        nop
        nop 
	mov byte [gs:2], '2'
	mov bx, 4
	mov byte [gs:bx], '3'
	add bx, 2
	jmp pm

pm:
	ret


	pmodemsg	db "[root@SollerOS-0.8.2]",0
