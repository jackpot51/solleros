;to make programming for solleros easier, i have created this include file that you may include at the beginning of your program so that you need only focus on your code. It will contain easy to use calls like print, read, or exit that you may use instead of interrupts.
[BITS 32]
[ORG 0x400000]
db "EX"
jmp ___progstart___

line db 10,13,0

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
	ret
exit:
	xor eax, eax
	int 0x30
___progstart___: