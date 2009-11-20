db "SN"
dd soundend
	dw 50,E4
	dw 50,0
	dw 70,E4
	dw 50,0
	dw 100,E4
	dw 50,0
	dw 50,C4
	dw 50,0
	dw 80,E4
	dw 50,0
	dw 140,G4
	dw 100,0
	dw 140,G3
soundend:
%include 'music.asm'