db 255,44,"exit",0
	cmp byte [ranboot], 1
	je near returnfromexp
	jmp nobootfile