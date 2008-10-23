	BATCHISON db 0
	exitmsg db	"exit",0
	mathmsg	db	"Type ",34,"exit",34," to exit math mode or press enter to calculate.",10,13,"Note that you can use variables($) in the numbers.",13,10,"However, only positive answers under a certain amount can be displayed.",13,10,"No decimal points or signs are allowed.",13,10,0
	mathmsg2 db	"Math:",0
	hours	db	"Hours",13,10,0
	minutes db	"Minutes",13,10,0
	notfound1 db "Program ",34,0
	notfound2 db  34," not found.",13,10,0
	charmsg db	"Enter char:",10,13,0
	universe1 db	"Only two things are infinite, the universe and human stupidity,",13,10,"and I'm not sure about the former.",13,10,0
	wrongpass db	"Wrong password!",13,10,0
	fullmsg	db	13,10,"Buffer Full",7,0
	pwdask	db	"Enter Password:",0
	pwd	db	"password",0
	cmd	db	"[user@SollerOS-v0.8.9$]",0
	dosmode db "Horrible DOS Compatability enabled.",13,10,0
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
    jeremymsg:  db '        ________   ________   ______     ________   ___        __  __    __',10,13
		db '       |__    __| |   _____| |   __ \   |______  | |   \      /  \ \ \  / /',10,13
		db '          |  |    |  |_____  |  |__| |   _____|  | | |\ \    / /\ \ \ \/ /',10,13
		db '     ___  |  |    |   _____| |   _   |  |_____   | | | \ \  / /  \ \ \  /',10,13
		db '     \  \_|  |    |  |_____  |  | \  \   _____|  | | |  \ \/ /    \ \ \ \',10,13
		db '      \______|    |________| |__|  \__\ |________| |_|   \__/      \_\ \_\',10,13
		db '    _______________________________________________________________________',10,13
		db '       ______      ________   __    ___  ________   _     __        __  __',10,13
		db '      /  _   |    |   _____| |  |  /  / |______  | | |   /  \      / / / /',10,13
		db '     /__/ |  |    |  |_____  |  |_/  /   _____|  | | |  / /\ \    / / / / ',10,13
		db '          |  |    |   _____| |   __  |  |_____   | | | / /  \ \  / / /  \',10,13
		db '        __|  |__  |  |_____  |  |__| |   _____|  | | |/ /    \ \/ / / /\ \ ',10,13
		db '       |________| |________| |______/   |________| |___/      \__/ /_/  \_\ ',10,13
		db '    ________________________________________________________________________ ',10,13
		db '        ________  _________  _______     _________  ____  |   __  __    __ ',10,13
		db '       /__&&&__/ /&&______/ /&&___&&\   /______&&/ /&&&&\ |  /&&\ \&\  /&/ ',10,13
		db '         /&&/   /&&/_____  /&&/__/&&/  ______/&&/ /&&/\&&\| /&/\&\ \&\/&/ ',10,13
		db '  ___   /&&/   /&&______/ /&&_&&&__/  /______&&/ /&&/  \&&\/&/  \&\ \&&/ ',10,13
		db '  \&&\_/&&/   /&&/_____  /&&/ \&&\   ______/&&/ /&&/    \&&&/    \&\ \&\',10,13
		db '   \_____/   /________/ /__/   \__\ /________/ /__/      \_/      \_\ \_\ ',10,13
		db '                                                          | ',10,13
		db '                                                   Yd 3bAM|MAdE bY ',10,13
		db '                                                       JaCkPoT',10,13,0
    jeremymsg2: db '   ___________________________________      __    __',13,10
		db '  /____&&&/&&______/&&___&&&/______&&/\    /\&\  /&/',13,10
		db '      /&&/&&/_____/&&/__/&&/_____/&&/&&\  /&&\&\/&/',13,10
		db '___  /&&/&&______/&&_&&&__/______&&/&/\&\/&/\&\&&/',13,10
		db '\&&\/&&/&&/_____/&&/ \&&\______/&&/&/  \&&/  \&\&\',13,10
		db ' \____/________/__/   \_/________/_/    \/    \_\_\',13,10
		db '',13,10
		db 'MADE by JaCkPoT',13,10
		db "A ",21,"oller",21,"oft project",0
    loadmsg  db 'Loading...',0
	clearmsg db 10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,0
    protectmsg db "We are now in protected mode.",13,10,0
    number1	db "First Number:",0
    number2	db "Second Number:",0
    operandmsg	db 10,13,"Operand:",0
    dskmsg	db "Bytes free for user variables.",10,13,0
    sectormsg	db "Loading OS...(SollerOS floppy must be inserted)",0
 

	batchmsg db "To run this batch type runbatch and press enter.",10,13,0
fonts:	times 2159 db 0
	
fontend2:
	db	128
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
	db	129
	times 16 db 0xFF
fontend:

bufferhelper:	db 0,0
variables: times 500 db 0
varend:
buftxt: times 200 db 0
buf2:	times 20 db '0'
numbuf:	db 0,0
copybuffer times 500 db 0
videobuf2 times 0x12C0 	db ' '
videobufend:
rbuffstart:
