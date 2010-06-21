header:
	jmp short boot
signature:
db "SollerOS ",0 ;Operating system name
dd 280	;version number
signatureend: