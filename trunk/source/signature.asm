sigjump:
	jmp signatureend
signature:
db "SollerOS ",0 ;Operating system name
dd 270	;version number
signatureend:
