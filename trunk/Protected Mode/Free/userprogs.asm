					;;;DEMO PROGRAMS, NOT INDEXED AUTOMATICALLY;;;

db 5,4,"Hello World",0			;file header
	hello:
		mov si, helloworldmsg		;location of message
		mov al, 0				;zero terminated
		mov ah, 1				;function 1
		mov bx, 7				;modifier = 7, light gray
		mov dx, 0				;first line, first column
		call word [13h]				;call int30h, word for 16 bit location
							;;5th 16 bit location: 5+(5*2)=F
		jmp word [15h]				;jump back to command prompt
							;;4th 16 bit location: 5+(4*2)=D
	helloworldmsg db "Hello World",10,13,0