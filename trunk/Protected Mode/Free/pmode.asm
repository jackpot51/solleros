        ; these are used in the processor identification
        ; Here's the locations of my IDT and GDT.  Remember, Intel's are
        ; little endian processors, therefore, these are in reversed order.
        ; Also note that lidt and lgdt accept a 32-bit address and 16-bit 
        ; limit, therefore, these are 48-bit variables.
        pIDT            dw 7FFh         ; limit of 256 IDT slots
                        dd 0000h        ; starting at 0000

	GDTR
		        dw 17FFh
			dd 0800h

pmode:
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
        mov cx, 14h
wait_kbc:                       ; this is approx. a 25uS delay to wait

        loop wait_kbc           ; command.

        ; the A20 line is on now.  Let's load in our IDT and GDT tables...
        ; Ideally, there will actually be data in their locations (by loading 
        ; the kernel)
        lidt [pIDT]
        lgdt [GDTR]
        ; now let's enter pmode...

        mov eax, cr0            ; load the control register in
        or  al, 1               ; set bit 1: pmode bit
        mov cr0, eax            ; copy it back to the control register
        jmp $+2                 ; and clear the prefetch queue
        nop
        nop 
pm:	
	ret


	pmodemsg	db "[root@SollerOS-0.8.2]",0
