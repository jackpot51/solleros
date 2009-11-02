db 255,44,"shush",0
	mov esi, shushmsg
	call print
	jmp shush
	shushmsg db "Welcome to the SollerOS Hardly Unix-Compatible Shell!",10,0