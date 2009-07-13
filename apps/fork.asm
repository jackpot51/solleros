[BITS 32]
[ORG 0x400000]
db "EX"
forktest:		;;this program will test multithreading by "forking" the program
	mov esi, forkstart
	mov al, 0
	mov ah, 10
	int 0x30
	mov esi, fork1
	mov al, 0
	mov ah, 1
	int 0x30
	mov ah, 0
	int 0x30
	jmp $

forkstart:
	mov esi, fork2
	mov al, 0
	mov ah, 1
	int 0x30
	mov ah, 0
	int 0x30
	jmp $
	
fork1 db "This is the main thread.",10,13,0
fork2 db "This is the forked thread.",10,13,0