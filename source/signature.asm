sigjump:
	jmp signatureend
signature:
db "SollerOS ",0 ;Operating system name
dd 267	;version number
signatureend:
