	BATCHISON db 0
	exitmsg db	"exit",0
	mathmsg	db	"Type ",34,"exit",34," to exit math mode or press enter to calculate.",10,13,"Note that you can use variables($) in the numbers.",13,10,"However, only positive answers under a certain amount can be displayed.",13,10,"No decimal points or signs are allowed.",13,10,0
	mathmsg2 db	"Math:",0
	hours	db	"Hours",13,10,0
	minutes db	"Minutes",13,10,0
	notfound1 db "Program ",34,0
	cleanmsg times 60 db ' '
	notfound2 db  34," not found.",10,13,0
	charmsg db	"Enter char:",10,13,0
	universe1 db	"Only two things are infinite, the universe and human stupidity,",10,13,"and I'm not sure about the former.",13,10,0
	wrongpass db	"Wrong password!",13,10,0
	fullmsg	db	13,10,"Buffer Full",7,0
	pwdask	db	"Enter Password:",0
	pwd	db	"password",0
	cmd	db	"[user@SollerOS-v0.8.2$]",0
	dosmode db "Horrible DOS Compatability enabled.",13,10,0
	line	db	13,10,0
	blankmsg db 0
	zeromsg db "0"
	unamemsg db	"SollerOS-v0.8.5 x86 Made from scratch with assembly by Jeremy Soller",10,13,0
	helpmsg db	"This operating system is way too simple to warrant the creation of a help file.",10,13,0
    msg:       db "SollerOS Beta version 0.8.5 - compiled by Jeremy Soller.",13,10,"This is the eighth version, with MATH, VARIABLES,",10,13,"and BATCHES with NESTED IF COMMANDS, ELSE COMMANDS, AND LOOPS!!!!",13,10,0
    menumsg:   db 13,10,"What do you want to do?",13,10,"Hang(h)",13,10,"Boot(b)",13,10,"Cold Reboot(c)",13,10,"Warm Reboot(w)",13,10,"Shutdown(s)",13,10,0
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
    easteregg	db 13,10
db "                         ...uueW$$$$No.",13,10
db "                       .uod@$$$$RRRMMMMMMMMMMMMMM8$o",13,10
db "                .uoW$RRRRMMMMMMMMMMMMMMMMMMMMMMMM$RRRL",13,10
db "              4MRRMMMMMMMMMMMMMMM!?!!!!!!!!!MMMM??MRM&",13,10
db "              MMMMMMMMMMMM?!!!!!!!!~~``     !MMM!!XMSM!",13,10
db "             'MMMMMM!M!!!!!!!!~. !!TM?2X!(%!!XMXX!X?MM",13,10
db "             'MMMM!!!!!!!~`  .:+X:(??X!!!!!!`?XX?(",34,"`",34,13,10
db "             !XMMMX!!!~     :!XMH!!!X!%!?!!M!!!!!!MMx",13,10
db "             !MMMMM!!!      !!XMMS!!!!!!XX!!X.!!",13,10
db "             !!MMMM!!!      :!XX!!:!!!!/!!!X.~ ~!:",13,10
db "             !?MMMM!!!     mMRX!!!!!!!!(!!!!!(. ~!!!!",13,10
db "             !XMMMH!!!)   .X?MM$Xx(!!!!~((~!~(!  (~X@R$N",13,10
db "             `XMMMM!!!! -!!!!HMM!M!XX!!:~ ~!   : :RMMMMMB",13,10
db "             'MMMMX!!!! :X!!XMMMMSM!!!~`:(~ ..~':MMMMMMMM)",13,10
db "             'XMMMM!!!!:!!?XMMMMMM!!!!)~ '     XMMMMMMMMM)",13,10
db "              XMMMM!!!XHMMMMMMMMMM!!!!!~ ~    XMMMMMMMMMM",13,10
db "              !MMMM!!!!MMMMMMMMMMM!!!!!  ::  XMMMMMMMMMMf",13,10
db "              'XMM?!!!!!!/?MMMXX!!!!!!!~'(~~XMMMMMMMMMM",13,10
db "               MMMM!!!X!/ ?MMMMMM!!!!~:((` XMMMMMMMMMM!",13,10
db "               XHM!!!!!!~ !MMMMMM!!!((~(~ MMMMMMMMMMM~!",13,10
db "               ~M!!!~!!` '!MMMMM!!!~~ !~ XMMMMMMMMMXM!",13,10
db "               '!!(~~~.  (!MMMM!!!!~~~ ~XMMMMMMMMMM!!X",13,10
db "               '!!~     '!!!MM!!!!~    `SMMMMMMMM!!!XX!:    ",13,10
db "               X!(:(    !!!!!!!!!!:  .(XXMMMMMMMM!!!!!!!!!!!!",13,10
db "              '(~!!!!~~(!!!!!!!!!!!HMMMMMMMMMMMM!!!!!!!!!!!!!",13,10
db "              X/~-!!!!!!!!!!!!!!!MMMMMMMMMMMMMMX!!!!!!!!!!!!!",13,10
db "              X!!!!!!!!!!!!!XXHMMMMMMMMMMMMMMMM!!?!!!!!!!!!!!",13,10
db "             !X!!!!!!!!!!!XXMMMMMMMMMMMMMMMMMM!!X!!!!!!!!!!!!",13,10
db "          .!M%X!!!!!!!!!!MMMMMMMMMMMMMMMMMMMM!!!!X!!!!!!!!!!!",13,10
db "    !!!(xMMMMM!!!!!!!XXMMMMMMMMMMMMMMMMMMMMM!!~`!!!!!!!!!!!!!",13,10
db "    ~!!!?MMMM!!!!!XXMMMMMMMMMMMMMMMMMMMMMMM!!!) :!!!!!!!!!!!!",13,10
db "    '!!XHMM?!!!!HMMMMMMMMMMMMMMMMMMMMMMMM!!!'!:'~!!!!!!!!!!!!",13,10
db "    '!XHMMM!!!!MM!!MMMMMMMMMMMMMMMMMMMM!!!!~:`' ~!!!!!!!!!!!!",13,10
db "  :.!!!MMMX!!!MM!HMMMMMMMMMMMMMMMMMMMM~!:!~`!: ~(!!!!!!!!!!!!",13,10
db ":!!!X!!MMM!!!!!XMMMMMMMMMMMMMMMMMMMM!!!!!` ' ( ~!!!!!!!!!!!!!",13,10
db "MMX!!!!!!!!!!!!XMMMMMMMMMMMMMMMMMMM./!!!~     :!!!!!!!!!!!!!!",13,10
db "MM!!(~!!!!!!!!!XMMMMMMMMMMMMMMMMMM!(`!~!. :(!!!!!!!!XXMHXHMMM",13,10
db "!!!!!!!!!!!!!!!!MMMMMMMMMMMMMMMMM!!!(:!!!!!!!!!!!!!!?MMM$M$$M",13,10
db "!!!!!!!!!!!!!!!!!MMMMMMMMMMMMMMM ~!!!!!!!!!!!!!!!!!!!!!??MMMM",13,10
db "!~!~~~~!!!!!!!XXMMMMMMMMMMMMMMM~    `!!!!!!XMWWX!!!!!!!!!!!!!",13,10
db "~      !!!!!XMMMMMMMMMMMMMMMMMXx.    !!!!!!$$$$$$X!!!!!!!!!!!",13,10
db "~      !!!!!!MMMMMMMMMMMMMMMMM$$R:!!XXXXXXXXM$$$$MX!!XX!!!!!!",13,10
db "(     '!!!!!!MMMMMMMMMMMMMMMMM$R!M$$$$$$$$MMMMRMMMMMM$$$$$BM8",13,10
db "~'     !!!!!!MMMMMMMMMMMMMMMMMR!X$$$$$$$$$5$$$$MMM$888M$$$$$$",13,10
db "        !!!!!MMMMMMMMMMMMMM\MM!!M$$$$$$$M!!!?MMMMR$$$$$$$$$$$",13,10
db "xM.     `!!!MMMMMMMMMMMMM!X%!MMk~MR!!!!!XXX!!!!MMMMMMM$$$$$$$",13,10
db "MMM.     !!!MMMMMMMMMMMMXMMXMHXMX!!!!!!!M$$$$X!!!?M!MRMR$$$$$",13,10
db "!MM$     !!!?MMMMMMMMMXMMMMMMXX!MMMWWHX!!MM!!!!!!!!!!!!!?MMM$",13,10,0
	batchmsg db "To run this batch type runbatch and press enter.",10,13,0
bufferhelper:	db 0,0
buftxt: times 200h db 0
buf2:	times 200h db '0'
numbuf:	db 0,0
batch:	db 6,5,"tutorial",0
	db 5,4,"clear",0
	db 5,4,"echo The batch program can run all commands featured in SollerOS.",0
	db 5,4,"echo It can also run the extra ",34,"if",34," command.",0
	db 5,4,"echo Would you like a tour of the SollerOS system?",0
	db 5,4,"echo If so, you can type yes and press enter.",0
	db 5,4,"$a=",0
	db 5,4,"if $a=no",0
	db 5,4,"echo Fine then.",0
	db 5,4,"stop",0,5,4,"fi",0
	db 5,4,"if $a=yes",0
	db 5,4,"clear",0
	db 5,4,"dir",0
	db 5,4,"$b=",0
	db 5,4,"clear",0
	db 5,4,"echo ls and dir-these show all available programs",0
	db 5,4,"echo menu-this returns to the boot menu",0
	db 5,4,"echo uname-this shows the system build",0
	db 5,4,"echo help-this shows the nonexistant help file",0
	db 5,4,"echo logout-this logs the user out",0
	db 5,4,"echo clear-this clears the screen",0
	db 5,4,"echo universe-this shows a famous quote from einstein",0
	db 5,4,"echo echo-this prints text and variables to the screen",0
	db 5,4,"echo math-this is the obsolete math program",0
	db 5,4,"echo etch-a-sketch-this is a 3rd party app",0
	db 5,4,"echo space-this shows the amount of available space for variables",0
	db 5,4,"echo reload-this reloads the operating system from the floppy",0
	db 5,4,"echo runbatch-this runs batch files",0
	db 5,4,"echo showbatch-this shows the currently loaded batch file",0
	db 5,4,"echo batch-this creates a new batchfile",0
	db 5,4,"echo time-this reads the system time in an unfamiliar format",0
	db 5,4,"echo #-this evaluates expresions",0
	db 5,4,"echo %-this gives back the last answer",0
	db 5,4,"echo the $ sign is used for variables",0
	db 5,4,"echo the BATCHES ONLY!!! programs are for batches only",0
	db 5,4,"fi",0
	db 4,5,0
	times 500h db 0
variables: times 500h db 0
varend:
wordst:	times 1000h db 0
commandlst:	times 500h db 0
commandlstend:
vmem:	times 07A0h db 0