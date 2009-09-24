	shushmsg db "Welcome to the SollerOS Hardly Unix-Compatible Shell!",10,13,0
	exitmsg db	"exit",0
	notfound1 db "Program ",34,0
	notfound2 db  34," not found.",13,10,0
	userask db "username:",0
	pwdask	db	"password:",0
	computer db "@"
	computername	db	"SollerOS",0
	location db " "
	locationname db "/",0
	endprompt db "]$ ",0
	line	db	13,10,0
	dirtab 	db " ",9,0
	userlst:
			db "user",0
			db "password",0
			db "root",0
			db "awesomepower",0
			db "n",0	;;abuse for quick entry-a quick double n followed by a double enter will get you in
			db 0
	userlstend:
	
fonts:	incbin 'source/precompiled/fonts.pak'
fontend:


mcursor:
	db	00000001b
	db	10000001b
	db	11000001b
	db	11100001b
	db	11110001b
	db	11111001b
	db	11111101b
	db	11111111b
	db	11111001b
	db	10111001b
	db	00111001b
	db	00011100b
	db	00011100b
	db	00001110b
	db	00001110b
	db	00001100b

osend:	;this is the end of the operating system's space on disk