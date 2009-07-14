
unhand:	
	%assign i 0
	%rep 256
	cli
	mov byte [intprob], i
	jmp unhand2
	%assign i i+1
	%endrep
unhand2:
	cli
	push ds
	push es
	push fs
	push gs
	push ss
	pushad
	cmp byte [guion], 0
	je near noguiunhandstuff
	mov word [locunhandy], 8
	mov word [locunhandx], 8
	mov bx, [background]
	mov [backgroundcache], bx
	mov byte [mousedisabled],1
	mov bx, 1111100000000000b
	mov [background], bx
noguiunhandstuff:
	mov esi, esp
	mov [espfirst], esi
	add esi, ((unhndrgend - unhndrg)/15)*4
	mov [esploc], esi
	mov esi, unhandmsg
	mov [esiloc], esi
	xor ecx, ecx
	mov cl, [intprob]
	mov ebx, errortypes
	shl ecx, 2
	add ebx, ecx
	cmp ebx, errortypesend
	jb gooderrortype
	mov ebx, errortypesend
gooderrortype:
	mov esi, [ebx]
	cmp byte [guion], 0
	je near errortext
	mov cx, [locunhandy]
	mov dx, [locunhandx]
	mov ax, 1
	xor bx, bx
	call showstring2
	mov [locunhandy], cx
	mov [locunhandx], dx
	jmp errortextdone
errortext:
	call print		;;get the error message and print it
errortextdone:
	xor ecx, ecx
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
	mov ecx, cr0
	call expdump
	mov ecx, cr2
	call expdump
	mov ecx, cr3
	call expdump
	mov ecx, cr4
	call expdump
	mov esi, [esploc]
	mov edi, [ss:esp + 52]
	add edi, 16
	mov [codelocend], edi
	sub edi, 32
dumpcodeloop:
	mov [codeloc], edi
	mov ecx, [edi]
	call expdump
	mov edi, [codeloc]
	add edi, 4
	cmp edi, [codelocend]
	jb dumpcodeloop
	mov esi, backtoosmsg
	cmp byte [guion], 0
	jne guibacktomsg
	call print
	jmp backtomsgdone
guibacktomsg:
	mov dx, [locunhandx]
	mov cx, [locunhandy]
	mov ax, 1
	xor bx, bx
	call showstring2
backtomsgdone:
	xor al, al
	call int302
	cmp byte [intprob], 3
	jne nodebugint
	cmp byte [guion], 0
	je nodebuggui
	mov bx, [backgroundcache]
	mov [background], bx
	xor bx, bx
	mov byte [mousedisabled], 0
	call guiclear
	call reloadallgraphics
nodebuggui:
	mov esi, [espfirst]
	mov esp, esi
	popad
	pop ss
	pop gs
	pop fs
	pop es
	pop ds
	iret
nodebugint:
	popad
	pop ss
	pop gs
	pop fs
	pop es
	pop ds
	cmp byte [guion], 0
	je returnunhandgui
	mov bx, [backgroundcache]
	mov [background], bx
	xor bx, bx
	mov byte [mousedisabled], 0
	call guiclear
	call reloadallgraphics
	jmp gui
returnunhandgui:
	jmp nwcmd
backtoosmsg db "Please post any problems in the Issues section at solleros.googlecode.com",10,13
			db "Press any key to return to SollerOS",10,13,0
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
	mov cx, [locunhandy]
	mov dx, [locunhandx]
	mov ax, 1
	xor bx, bx
	call showstring2
	mov [locunhandy], cx
	mov [locunhandx], dx
	ret
expdumptext:
	call print
	ret
esploc dd 0
espfirst dd 0
esiloc dd 0
esiregbuf dd 0
locunhandy dw 1
locunhandx dw 1
backgroundcache dw 0
intprob db 0
codeloc dd 0
codelocend dd 0
	unhandmsg:	
			db "INT=00000000",10,13,0
unhndrg:
	times 7 db 255,255,255,255,"00000000  ",0	;;this dumps the stack before the stack frame in question
			db 255,255,255,255,"00000000",10,13,0
	times 7 db 255,255,255,255,"00000000  ",0	;;this dumps the stack before the stack frame in question
			db 255,255,255,255,"00000000",10,13,0
	times 7 db 255,255,255,255,"00000000  ",0	;;this dumps the stack before the stack frame in question
			db 255,255,255,255,"00000000",10,13,0
	times 7 db 255,255,255,255,"00000000  ",0	;;this dumps the stack before the stack frame in question
			db 255,255,255,255,"00000000",10,13,0
unhandregs:
			db "EFL=00000000  ",0
			db "CS:=00000000  ",0
			db "EIP=00000000",10,13,0
			db "DS:=00000000  ",0
			db "ES:=00000000  ",0
			db "FS:=00000000  ",0
			db "GS:=00000000  ",0
			db "SS:=00000000",10,13,0
			db "EAX=00000000  ",0
			db "ECX=00000000  ",0
			db "EDX=00000000  ",0
			db "EBX=00000000",10,13,0
			db "ESP=00000000  ",0
			db "EBP=00000000  ",0
			db "ESI=00000000  ",0
unhndrgend:	db "EDI=00000000",10,13,0
			db "CR0=00000000  ",0
			db "CR2=00000000  ",0
			db "CR3=00000000  ",0
			db "CR4=00000000",10,13,0
unhandcode: times 2 db 255,255,255,255,"00000000  ",0	;;this dumps the code before and after the interrupt in question
			db 255,255,255,255,"00000000 ",255,0
			db 255,255,255,"[00000000] ",0
			times 3 db 255,255,255,255,"00000000  ",0
			db 255,255,255,255,"00000000",10,13,0
unhandmsgend:

errortypes:
			dd err0
			dd err1
			dd err2
			dd err3
			dd err4
			dd err5
			dd err6
			dd err7
			dd err8
			dd err9
			dd err10
			dd err11
			dd err12
			dd err13
			dd err14
			dd err15
errortypesend:
			dd unknownerror
			
err0	db "Division by zero:",10,13
		db "Technically lim a",246,"x = ",236," when a is any real number. Happy Easter!",10,13
		db "            x",26,"0",10,13,0
		
err1	db "Single-step/Breakpoint:",10,13
		db "A breakpoint fault, breakpoint trap, or single-step trap was triggered.",10,13,0
		
err2	db "Nonmaskable interrupt:",10,13
		db "A hardware interrupt was triggered that could not be masked",10,13,0
		
err3	db "Breakpoint:",10,13
		db "This interrupt is used in programs to show the stack and registers and can be",10,13
		db "ignored.",10,13,0
		
err4	db "Overflow:",10,13
		db "The processor ran into an INTO instruction with the overflow flag set.",10,13,0
		
err5	db "Bounds check:",10,13
		db "The processor rebounded from a BOUND instruction run on an operand that was out",10,13
		db "of bounds.",10,13,0
		
err6	db "Invalid opcode:",10,13
		db "The processor has no idea what it was trying to execute. Don't run SSE4 code",10,13
		db "on 486's!",10,13,0
		
err7	db "Coprocessor not available:",10,13
		db "Don't you know they don't make those anymore!",10,13,0
		
err8	db "Double fault:",10,13
		db "The exception handler could not handle that it could not handle an exception.",10,13,0
		
err9	db "Coprocessor segment overrun:",10,13,0
		db "This never happens in modern computers, and never should.",10,13,0

err10	db "Invalid TSS:",10,13
		db "The TSS that was switched to is invalid. Nothing funny here.",10,13,0
		
err11	db "Segment not present:",10,13
		db "The present bit of the segment descriptor is set to zero.",10,13,0
		
err12	db "Stack exception:",10,13
		db "The SS descriptor is invalid or not present or its limit is too small.",10,13,0
		
err13	db "General protection violation:",10,13
		db "You violated the computer. Step away slowly. The FBI is on its way.",10,13,0
		
err14	db "Page fault:",10,13
		db "The page that was requested was not available.",10,13,0
		
err15	db "Reserved for Plan R:",10,13
		db "This interrupt is reserved for usage only by the military when it is necessary",10,13
		db "to initiate a full-scale coup d'",130,"tat.",10,13,0
		
unknownerror db "What the hell just happened? Is everyone okay? Hard drive? Video card?",10,13
			db	"Memory? Are you there?",10,13,0