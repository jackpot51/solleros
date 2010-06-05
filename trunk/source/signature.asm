sigjump:
	jmp signatureend
signature:
db "SollerOS ",0 ;Operating system name
dd 268	;version number
signatureend:
