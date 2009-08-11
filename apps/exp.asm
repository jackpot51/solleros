%include "include.asm"
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
	mov ebx, [edi]
	jmp ebx
	
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
exceptionsend:
	exception0:	
		int 0
		mov ah, 0
		int 0x30
	exception1:	
		int 1
		mov ah, 0
		int 0x30
	exception2:	
		int 2
		mov ah, 0
		int 0x30
	exception3:	
		mov eax, 0xD15EA5ED
		int 3
		mov ah, 0
		int 0x30
	exception4:	
		int 4
		mov ah, 0
		int 0x30
	exception5:	
		int 5
		mov ah, 0
		int 0x30
	exception6:	
		int 6
		mov ah, 0
		int 0x30
	exception7:	
		int 7
		mov ah, 0
		int 0x30
	exception8:
		int 8
		mov ah, 0
		int 0x30
	exception9:	
		int 9
		mov ah, 0
		int 0x30
	exception10:  
		int 10
		mov ah, 0
		int 0x30
	exception11:	
		int 11
		mov ah, 0
		int 0x30
	exception12:		
		int 12
		mov ah, 0
		int 0x30
	exception13:	
		int 13
		mov ah, 0
		int 0x30
	exception14:
		int 14
		mov ah, 0
		int 0x30
	exception15:
		int 15
		mov ah, 0
		int 0x30