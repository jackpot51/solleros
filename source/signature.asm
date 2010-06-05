sigjump:
	jmp signatureend
signature:
db "SollerOS ",0 ;Operating system name
dd 271	;version number
signatureend:
