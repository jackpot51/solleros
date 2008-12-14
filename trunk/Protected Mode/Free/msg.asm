	BATCHISON db 0
	exitmsg db	"exit",0
	notfound1 db "Program ",34,0
	notfound2 db  34," not found.",13,10,0
	universe1 db	"Only two things are infinite, the universe and human stupidity,",13,10,"and I'm not sure about the former.",13,10,0
	pwdask	db	"Enter Password:",0
	pwd	db	"password",0
	cmd	db	"[user@SollerOS-v0.8.9$]",0
	line	db	13,10,0
	zeromsg db "0"
	unamemsg db	"SollerOS-v0.8.9 x86 Made from scratch with assembly by Jeremy Soller",10,13,0
	helpmsg db	"This operating system is way too simple to warrant the creation of a help file.",10,13,0
    msg:       db "SollerOS Beta version 0.8.9 - compiled by Jeremy Soller.",13,10,0
    menumsg:   db 13,10,"What do you want to do?",13,10,"GUI(g)",13,10,"Boot(b)",13,10,"Cold Reboot(c)",13,10,"Warm Reboot(w)",13,10,"Shutdown(s)",13,10,0
    bootmsg:   db "Booting...",13,10,"If there was something to boot...",0
    rebootmsg: db "Rebooting...",0
    shutdownmsg: db "Shuting Down...",0
    hangmsg:   db "Hanging...",0
    wrongmsg:  db "Please select one of the options above.",13,10,"You selected: ",0
	batchmsg db "To run this batch type runbatch and press enter.",10,13,0
fonts:	times 2048 db 0
fontend2:
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
fontend:
bufferhelper:	db 0,0
variables: times 500 db 0
varend:
buftxt: times 200 db 0
buf2:	times 20 db '0'
numbuf:	db 0,0
videobuf2 times 0x12C0 	db 0
videobufend:
rbuffstart:

;oldstuff:
