db "SN"
dd soundend
	dw 25,E4
	dw 25,0
	dw 35,E4
	dw 25,0
	dw 50,E4
	dw 25,0
	dw 25,C4
	dw 25,0
	dw 40,E4
	dw 25,0
	dw 70,G4
	dw 50,0
	dw 70,G3
soundend:
%include 'music.asm'