%include "include.inc"
;this program starts 2 threads from the main thread and a third from the first child thread
;all 4 have a race to see which thread finishes first
	mov eax, 1
	xor edx, edx
	mov esi, bthread
	mov ah, 11
	int 0x30 ;start b thread
	mov esi, cthread
	mov ah, 11
	int 0x30 ;start c thread
athread:
	mov ecx, 0xAAAAAA00
	mov bl, "A"
	call threadmain
.hlt:
	hlt
	cmp byte [threadsdone], 4
	jb .hlt
	mov esi, threadmsg
	call print
	mov ecx, [pidfinish]
	mov al, 1
	mov ah, 9
	int 0x30
	mov esi, threadmsg2
	call print
	jmp exit

bthread:
	call fork ;start d thread using a style similar to fork() in C
	push ebx
	mov ah, 15
	int 0x30
	pop ebx
	mov eax, edx
	xor edx, edx
	cmp ebx, eax
	je dthread
.lp:
	mov ecx, 0xBBBBBB00
	mov bl, "B"
	call threadmain
	jmp hlt

cthread:
	mov ecx, 0xCCCCCC00
	mov bl, "C"
	call threadmain
	jmp hlt

dthread:
	mov ecx, 0xDDDDDD00
	mov bl, "D"
	call threadmain
	jmp hlt

hlt:
	hlt
	jmp hlt

fork:
	xor esi, esi
	mov ah, 11
	int 0x30	
	ret

threadmain:
	add ecx, edx
	mov ah, 9
	int 0x30
	sub ecx, edx
	inc edx
	cmp edx, 0xFF
	jbe threadmain
	inc byte [threadsdone]
	cmp byte [threadfinish], 0
	jne .ret
	mov [threadfinish], bl
	mov ah, 15
	int 0x30
	mov [pidfinish], edx
.ret:
	ret
	
threaditerations dd 0xFF
threadsdone db 0 ;hooray for semaphores
pidfinish dd 0
threadmsg db "Thread "
threadfinish db 0," with a PID of ",0
threadmsg2 db 8,"finished first.",10,0
