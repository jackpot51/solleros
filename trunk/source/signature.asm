header:
	jmp short boot
signature:
db "SollerOS ",0 ;Operating system name
dd 274	;version number
signatureend: