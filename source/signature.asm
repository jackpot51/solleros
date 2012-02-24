header:
	jmp short boot
signature:
db 0xA7,"ollerOS Beta ",0 ;Operating system name
dd 290	;version number
signatureend: