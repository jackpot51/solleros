[BITS 32]
[ORG 0x100]
start:
;finding out the ways to emulate certain dos calls.
mov ax, [0x81]
cmp eax, "prin"
je near printex
cmp eax, "char"
je near charex
cmp eax, "read"
je near readex
cmp eax, "time"
je near timeex

help:
	mov dx, helpmsg
	mov ah, 9
	int 21h
	int 20h

helpmsg db "print - print a string",10,13,"char - print a character",10,13,"read - read and print string",10,13,"help - never!",10,13,"$"

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