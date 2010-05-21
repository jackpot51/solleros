sigjump:
	jmp signatureend
signature:
db "SollerOS ",0 ;Operating system name
dd 265	;version number
signatureend:
