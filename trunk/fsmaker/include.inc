;to make programming for solleros easier, i have created this include file that you may include at the beginning of your program so that you need only focus on your code. It will contain easy to use calls like print, read, or exit that you may use instead of interrupts.
%include "start.inc"
jmp ___progstart___

line db 10,0

tester:			;si=user bx=prog cl=endchar returns 1 in al if true
			xor al, al
	.retest:
			mov al, [esi]
			mov ah, [ebx]
			cmp ah, cl
			je .testtrue
			cmp al, ah
			jne .testfalse
			inc ebx
			inc esi
			jmp .retest
	.testtrue:
			cmp al, cl
			jne .testalmost
			mov al, 1
			ret
	.testfalse:
			xor al, al
			ret
	.testalmost:
			mov al, 2
			ret	

print:
	mov al, 0
	mov ah, 1
	mov bl, 7
	int 0x30
	ret
	
read:
	mov al, 10
	mov ah, 4
	mov bl, 7
	int 0x30
	ret

showdec:
	xor al, al
	mov ah, 9
	int 0x30
	ret

showhex:
	mov al, 1
	mov ah, 9
	int 0x30
	ret

run:
	mov ah, 14
	int 0x30
	ret
	
exit:
	xor eax, eax
	int 0x30
			
%macro EXIT 1
	xor eax, eax
	mov ebx, %1
	int 0x30
%endmacro

%macro READ 1
	section .data
%%stringread:
    times %1 db 0
	db 0
	section .text
    mov esi, %%stringread
	mov edi, %%stringread + %1
	mov al, 13
	mov ah, 4
	mov bl, 7
	int 0x30
	mov esi, %%stringread
%endmacro

%macro RUN 1+
	section .data
%%stringrun:
	db %1,0
	section .text
	mov esi, %%stringrun
	mov ah, 14
	int 0x30
%endmacro

%macro PRINT 1+
	section .data
%%stringprint:
    db %1,0
	section .text
    mov esi, %%stringprint
	mov al, 0
	mov ah, 1
	mov bl, 7
	int 0x30
%endmacro

___progstart___:
