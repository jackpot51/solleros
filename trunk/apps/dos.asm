[BITS 32]
[ORG 0x400000]
start:
db "EX"
;finding out the ways to emulate certain dos calls.
mov eax, [edi]
mov edx, start
mov edi, start
mov esi, start
mov ebx, start
cmp eax, "prin"
je near printex
cmp eax, "char"
je near charex
cmp eax, "read"
je near readex
cmp eax, "time"
je near timeex
cmp eax, "help"
je near help
mov ax, 0x4C00
int 21h

help:
	mov dx, helpmsg
	mov ah, 9
	int 21h
	mov ax, 0x4C00
	int 21h

helpmsg db "print - print a string",10,13,"char - print a character",10,13,"read - read and print string",10,13,"help - never!",10,13,"$"

printex:
	mov dx, dosmsg
	mov ah, 9
	int 21h
	mov ax, 0x4C00
	int 21h
	
charex:
	mov al, "$"
	mov ah, 2
	int 21h
	mov ax, 0x4C00
	int 21h
	
readex:
	mov dx, dosbuf
	mov ah, 0xA
	int 21h
	mov dx, line
	mov ah, 9
	int 21h
	;mov di, dosbuf
	;mov cx, 0
	;mov cl, [dosbuf + 2]
	;add di, cx
	;inc di
	;mov al, "$"
	;mov [edi], al
	mov dx, dosbuf
	add dx, 3
	mov ah, 9
	int 21h
	mov dx, line
	mov ah, 9
	int 21h
	mov ax, 0x4C00
	int 21h
	
timeex:
	mov ax, 0x4C00
	int 21h

dosmsg db "Hello from dos!",10,13,"$"
line db 10,13,"$"
dosbuf db 30,0,0
	   times 30 db 0
	   db "$"