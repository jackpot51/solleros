%include "include.inc"
;This program is designed to test the exception handler of SollerOS
;by generating exceptions with buggy code.
	mov ax, [edi]
	mov [numbuf], ax
	mov ecx, 0xB100D015
	mov edx, 0xBAD2FEED
	mov ebx, 0x2A11D095
	mov esi, 0xA11CA752
	mov edi, exceptions
exceptionloop:
	mov ax, [edi]
	cmp ax, [numbuf]
	je near foundexception
	add edi, 6
	cmp edi, exceptionsend
	jb near exceptionloop
nofoundexception:
	jmp exception3
foundexception:
	mov eax, 0xD15EA5ED
	add edi, 2
	mov edi, [edi]
	jmp edi
	
numbuf dw 0
exceptions:
	dw 0
	dd exception3
	db "0",0
	dd exception0
	db "1",0
	dd exception1
	db "2",0
	dd exception2
	db "3",0
	dd exception3
	db "4",0
	dd exception4
	db "5",0
	dd exception5
	db "6",0
	dd exception6
	db "7",0
	dd exception7
	db "8",0
	dd exception8
	db "9",0
	dd exception9
	db "1","0"
	dd exception10
	db "1","1"
	dd exception11
	db "1","2"
	dd exception12
	db "1","3"
	dd exception13
	db "1","4"
	dd exception14
	db "1","5"
	dd exception15
	db "1","6"
	dd exception16
exceptionsend:
	exception0:	;division by 0
		mov edi, 0
		div edi
		jmp exit
	exception1: ;debug
		int 1
		jmp exit
	exception2:	;non maskable interrupt
		int 2
		jmp exit
	exception3: ;breakpoint
		int3
		jmp exit
	exception4:	;into instruction is run if overflow is set
		int 4
		jmp exit
bounds:	dd 0
		dd 2
	exception5: ;bounds exceeded
		mov edi, 3
		bound edi, [bounds]
		jmp exit
	exception6:	;invalid opcode
		int 6
		jmp exit
	exception7:	;fpu not available
		int 7
		jmp exit
	exception8: ;double fault
		int 8
		jmp exit
	exception9:	;coprocessor overrun
		int 9
		jmp exit
	exception10: ;invalid tss
		int 10
		jmp exit
	exception11: ;segment not present
		int 11
		jmp exit
	exception12: ;stack segment fault
		int 12
		jmp exit
	exception13: ;general protection fault
		int 13
		jmp exit
	exception14: ;page fault
		int 14
		jmp exit
	exception15: ;reserved
		int 15
		jmp exit
	exception16: ;anything above 15
		int 16
		jmp exit