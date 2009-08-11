;to make programming for solleros easier, i have created this include file that you may include at the beginning of your program so that you need only focus on your code. It will contain easy to use calls like print, read, or exit that you may use instead of interrupts.
[BITS 32]
[ORG 0x400000]
db "EX"
jmp ___progstart___
print:
	mov al, 0
	mov ah, 1
	mov bl, 7
	int 0x30
	ret
read:
	ret
exit:
	mov ah, 0
	int 0x30
___progstart___: