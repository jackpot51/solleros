sigjump:
	jmp signatureend
signature:
db "SollerOS ",0 ;Operating system name
dd 269	;version number
signatureend:
