	bootfilename db "boot.sh",0
	notfound1 db "shush: ",0
	notfound2 db  ": not found",10,0
	userask db "username:",0
	pwdask	db	"password:",0
	computer db "@"
%ifdef io.serial
	computername	db	"SollerOS.",io.serial," ",0
%else
	computername	db	"SollerOS ",0
%endif
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
	
	guion db 0
	DriveNumber db 0
	lbaad dd 0
	initialtsc dd 0,0
	lasttsc dd 0,0
	memlistbuf times 576 db 0
	memlistend: dd 0
%ifdef io.serial
%else
fonts:	incbin "source/fonts/fonts.pak"
fontend:
%endif
osend:	;this is the end of the operating system's space on disk
