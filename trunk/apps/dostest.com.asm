[BITS 16]
[ORG 0x100]
start:
;finding out the ways to emulate certain dos calls.
mov eax, [0x81]
cmp eax, "prin"
je near printex
cmp eax, "char"
je near charex
cmp eax, "read"
je near readex
cmp eax, "time"
je near timeex
cmp eax, "exit"
je near exitnogood

help:
	mov dx, helpmsg
	mov ah, 9
	int 21h
	int 20h

exitnogood:
	mov ax, 0x4C10 ;exit with an error level of 0x10
	int 21h

helpmsg db "print - print a string",10,13,"char - print a character",10,13,"read - read and print string",10,13,"help - never!",10,13,"exit - exit with a bad error number",10,13,"$"

printex:
	mov dx, dosmsg
	mov ah, 9
	int 21h
	int 20h
	
charex:
	mov dl, "$"
	mov ah, 2
	int 21h
	int 20h
	
readex:
	mov dx, dosbuf
	mov ah, 0xA
	int 21h
	mov dx, line
	mov ah, 9
	int 21h
	mov dx, dosbuf
	add dx, 3
	mov ah, 9
	int 21h
	mov dx, line
	mov ah, 9
	int 21h
	int 20h
	
timeex:
	int 20h

dosmsg db "Hello from dos!",10,13,"$"
line db 10,13,"$"
dosbuf db 30,0,0
	   times 30 db 0
	   db "$"