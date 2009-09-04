db "SN"
dd soundend
	dw 30,C4#
	dw 30,B3
	dw 100,C4#
	dw 25,0
	dw 150,F3#
	
	dw 35,D4
	dw 35,C4#
	dw 35,D4
	dw 50,C4#
	dw 150,B3
	
	dw 30,D4
	dw 30,C4#
	dw 100,D4
	dw 25,0
	dw 150,F3#
	
	dw 35,B3
	dw 35,A3
	dw 40,B3
	dw 40,A3
	dw 50,G3#
	dw 50,B3
	dw 150,A3
	
	dw 30,C4#
	dw 30,B3
	dw 100,C4#
	dw 150,F3#
	
	dw 35,D4
	dw 35,C4#
	dw 35,D4
	dw 50,C4#
	dw 150,B3
	
	dw 30,D4
	dw 30,C4#
	dw 100,D4
	dw 150,F3#
	dw 35,B3
	dw 35,A3
	dw 40,B3
	dw 40,A3
	dw 50,G3#
	dw 50,B3
	dw 70,A3
	
	dw 70,A3
	dw 35,G3#
	dw 35,A3
	dw 80,B3
	dw 35,A3
	dw 35,B3
	dw 80,C4#
	dw 35,B3
	dw 35,A3
	dw 40,G3#
	dw 50,F3#
	
	dw 70,D4
	dw 150,C4#
	dw 35,C4#
	
	dw 35,D4
	dw 35,C4#
	dw 35,B3
	dw 150,C4#
	
	dw 30,B3
	dw 30,G3#
	dw 200,F3#
soundend:
%include 'music.asm'