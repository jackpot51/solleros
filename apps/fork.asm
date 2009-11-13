%include "include.asm"
forktest:		;;this program will test multithreading by forking the program
	mov esi, forkstart
	mov ah, 11
	int 0x30
	mov esi, fork1
	call print
fork2rantest:
	mov al, [fork2ran]
	cmp al, 0
	je fork2rantest
	jmp exit

forkstart:
	mov esi, fork2
	call print
	mov byte [fork2ran], 1
	jmp $

fork2ran db 0	
fork1 db "This is the main thread.",10,0
fork2 db "This is the forked thread.",10,0
