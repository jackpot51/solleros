	db 255,44,"fi",0
	xor al, al
	cmp [BATCHISON], al
	je near notbatch
fi:	mov al, 1
	sub [IFON],al
	ret 