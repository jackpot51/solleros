	BATCHISON db 0
	exitmsg db	"exit",0
	mathmsg	db	"Type ",34,"exit",34," to exit math mode or press enter to calculate.",10,13,"Note that you can use variables($) in the numbers.",13,10,"However, only positive answers under a certain amount can be displayed.",13,10,"No decimal points or signs are allowed.",13,10,0
	mathmsg2 db	"Math:",0
	hours	db	"Hours",13,10,0
	minutes db	"Minutes",13,10,0
	notfound1 db "Program ",34,0
	cleanmsg times 60 db ' '
	notfound2 db  34," not found.",13,10,0
	charmsg db	"Enter char:",10,13,0
	universe1 db	"Only two things are infinite, the universe and human stupidity,",13,10,"and I'm not sure about the former.",13,10,0
	wrongpass db	"Wrong password!",13,10,0
	fullmsg	db	13,10,"Buffer Full",7,0
	pwdask	db	"Enter Password:",0
	pwd	db	"password",0
	cmd	db	"[user@SollerOS-v0.8.5$]",0
	dosmode db "Horrible DOS Compatability enabled.",13,10,0
	line	db	13,10,0
	blankmsg db 0
	zeromsg db "0"
	unamemsg db	"SollerOS-v0.8.5 x86 Made from scratch with assembly by Jeremy Soller",10,13,0
	helpmsg db	"This operating system is way too simple to warrant the creation of a help file.",10,13,0
    msg:       db "SollerOS Beta version 0.8.5 - compiled by Jeremy Soller.",13,10,0
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
db "               '!!~     '!!!MM!!!!~    `SMMMMMMMM!!!XX!:",13,10
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
db "!MM$     !!!?MMMMMMMMMXMMMMMMXX!MMMWWHX!!MM!!!!!!!!!!!!!?MMM$",13,10,0,0

	batchmsg db "To run this batch type runbatch and press enter.",10,13,0
font:	
	db	' '
	times 15 db 0
	db	10
	times 15 db 0
	db	13
	times 15 db 0
	db	'A'
		times 15 db 0
	db	'B'
		times 15 db 0
	db	'C'
		times 15 db 0
	db	'D'
		times 15 db 0
	db	'E'
		times 15 db 0
	db	'F'
		times 15 db 0
	db	'G'
		times 15 db 0
	db	'H'	
		times 15 db 0
	db	'I'
		times 15 db 0
	db	'J'
		times 15 db 0
	db	'K'
		times 15 db 0
	db	'L'
		times 15 db 0
	db	'M'
		times 15 db 0
	db	'N'
		times 15 db 0
	db	'O'
		times 15 db 0
	db	'P'
		times 15 db 0
	db	'Q'
		times 15 db 0
	db	'R'
		times 15 db 0
	db	'S'
		times 15 db 0
	db	'T'
		times 15 db 0
	db	'U'
		times 15 db 0
	db	'V'
		times 15 db 0
	db	'W'
		times 15 db 0
	db	'X'
		times 15 db 0
	db	'Y'
		times 15 db 0
	db	'Z'
		times 15 db 0
	db	'a'
		times 15 db 0
	db	'b'
		times 15 db 0
	db	'c'
		times 15 db 0
	db	'd'
		times 15 db 0
	db	'e'
		times 15 db 0
	db	'f'
		times 15 db 0
	db	'g'
		times 15 db 0
	db	'h'
		times 15 db 0
	db	'i'
		times 15 db 0
	db	'j'
		times 15 db 0
	db	'k'
		times 15 db 0
	db	'l'
		times 15 db 0
	db	'm'
		times 15 db 0
	db	'n'
		times 15 db 0
	db	'o'
		times 15 db 0
	db	'p'
		times 15 db 0
	db	'q'
		times 15 db 0
	db	'r'
		times 15 db 0
	db	's'
		times 15 db 0
	db	't'
		times 15 db 0
	db	'u'
		times 15 db 0
	db	'v'
		times 15 db 0
	db	'w'
		times 15 db 0
	db	'x'
		times 15 db 0
	db	'y'
		times 15 db 0
	db	'z'
		times 15 db 0
	db	'1'
		times 15 db 0
	db	'2'
		times 15 db 0
	db	'3'
		times 15 db 0
	db	'4'
		times 15 db 0
	db	'5'
		times 15 db 0
	db	'6'
		times 15 db 0
	db	'7'
		times 15 db 0
	db	'8'
		times 15 db 0
	db	'9'
		times 15 db 0
	db	'0'
		times 15 db 0
	db	'`'
		times 15 db 0
	db	'~'
		times 15 db 0
	db	'!'
		times 15 db 0
	db	'@'
		times 15 db 0
	db	'#'
		times 15 db 0
	db	'$'
		times 15 db 0
	db	'%'
		times 15 db 0
	db	'^'
		times 15 db 0
	db	'&'
		times 15 db 0
	db	'*'
		times 15 db 0
	db	'('
		times 15 db 0
	db	')'
		times 15 db 0
	db	'_'
		times 15 db 0
	db	'-'
		times 15 db 0
	db	'+'
		times 15 db 0
	db	'='
		times 15 db 0
	db	'['
		times 15 db 0
	db	']'
		times 15 db 0
	db	'{'
		times 15 db 0
	db	'}'
		times 15 db 0
	db	';'
		times 15 db 0
	db	':'
		times 15 db 0
	db	27h
		times 15 db 0
	db	22h
		times 15 db 0
	db	','
		times 15 db 0
	db	'.'
		times 15 db 0
	db	'/'
		times 15 db 0
	db	'<'
		times 15 db 0
	db	'>'
		times 15 db 0
	db	'?'
		times 15 db 0
	db	'\'
		times 15 db 0
	db	'_'
		times 15 db 0
	db	'|'
		times 15 db 0
	db	21
		times 15 db 0
fontend:
charbitmap:
	db	0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0
charbitmapend:

bufferhelper:	db 0,0
variables: times 500h db 0
varend:
buftxt: times 200h db 0
buf2:	times 50h db '0'
numbuf:	db 0,0
copybuffer times 500h db 0
videobuf2 times 0Fa0h 	db 0
videobufend:

stack1:	times 500h db 0
stack2: times 500h db 0