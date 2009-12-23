	bootfilename db "boot.sh",0
	notfound1 db "shush: ",0
	notfound2 db  ": command not found",10,0
	userask db "username:",0
	pwdask	db	"password:",0
	computer db "@"
	computername	db	"SollerOS ",0
	endprompt db "]$ ",0
	crlf 	db  13
	line	db	10,0
	userlst:
			db "root",0
			db "awesomepower",0
			db "user",0
			db "password",0
			db "n",0	;;abuse for quick entry-a quick double n followed by a double enter will get you in
			db 0
	userlstend:
	
fonts:	incbin "source/precompiled/fonts.pak"
fontend:
osend:	;this is the end of the operating system's space on disk
