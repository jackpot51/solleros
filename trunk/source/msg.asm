	exitmsg db	"exit",0
	notfound1 db "Program ",34,0
	notfound2 db  34," not found.",13,10,0
	universe1 db	"Only two things are infinite, the universe and human stupidity,",13,10,"and I'm not sure about the former.",13,10,0
	pwdask	db	"Enter Password:",0
	pwd	db	"password",0
	cmd	db	"[user@SollerOS-v0.9.0$]",0
	line	db	13,10,0
	zeromsg db "0"
	unamemsg db	"SollerOS-v0.9.0 x86 Made from scratch with assembly by Jeremy Soller",10,13,0
	helpmsg db	"This operating system is way too simple to warrant the creation of a help file.",10,13,0
    msg:       db "SollerOS Beta version 0.9.0 - compiled by Jeremy Soller.",13,10,0
    menumsg:   db 13,10,"What do you want to do?",13,10,"GUI(g)",13,10,"Boot(b)",13,10,"Cold Reboot(c)",13,10,"Warm Reboot(w)",13,10,"Shutdown(s)",13,10,0
    bootmsg:   db "Booting...",13,10,"If there was something to boot...",0
    rebootmsg: db "Rebooting...",0
    shutdownmsg: db "Shuting Down...",0
    hangmsg:   db "Hanging...",0
    wrongmsg:  db "Please select one of the options above.",13,10,"You selected: ",0
	batchmsg db "To run this batch type runbatch and press enter.",10,13,0
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

;;; ZEROS-THESE DO NOT NEED TO BE COMPILED BUT ADDRESSES SHOULD BE USED
;;;[section .bss] compile these

graphicstable: ;w type, dw datalocation, w locationx, w locationy, w selected, dw code
	times 200h db 0
	graphicstableend:
mousecolorbuf: ;where the gui under the mouse is stored
times 256 db 0
mcolorend:
IFON times 1 db 0
IFTRUE times 100 db 0
BATCHPOS times 4 db 0
BATCHISON times 1 db 0
LOOPON times 1 db 0
LOOPPOS	times 4 db 0
fonts:	times 2048 db 0
fontend2:
		times 16 db 0
fontend:
fileindex: times 500h db 0	;index format can be found in SollerOS programming guide
customprograms:			;put custom index items here. I promise I won't overwrite them
				;although they may be written twice if they are in the filesystem
;;	db 5,4,"Hello World"
;;	dw 0,hello,0		;;example of a custom file descriptor
	
fileindexend:
bufferhelper:	times 2 db 0
variables: times 500h db 0
varend:
buftxt: times 200h db 0
buf2:	times 20 db 0	;;should be initialized as '0'
numbuf:	times 2 db 0
videobuf2 times 0x12C0 db 0
videobufend:
times 200 db 0

VBEMODEBLOCK:
vbesignature 	times 4 db 0	;VBE Signature
vbeversion  		times 2 db 0   ;VBE Version
oemstringptr  		times 4 db 0 ;Pointer to OEM String
capabilities 	times 4 db 0  	;Capabilities of graphics cont.
videomodeptr 		times 4 db 0	;Pointer to Video Mode List
totalmemory   		times 2 db 0    ;number of 64Kb memory blocks
oemsoftwarerev  	times 2	db 0	;VBE implementation Software revision
oemvendornameptr 	times 4 db 0	;Pointer to Vendor Name String
oemproductnameptr 	times 4 db 0	;Pointer to Product Name String
oemproductrevptr 	times 4 db 0 	;Pointer to Product Revision String
reserved	times 222 db 0	;Reserved for VBE implementation scratch area
oemdata 	times 256 db 0	;Data Area for OEM Strings


VBEMODEINFOBLOCK:
;Mandatory information for all VBE revision
modeattributes   times 2 db 0 ;Mode attributes
winaattributes   times 1 db 0 ;Window A attributes
winbattributes   times 1 db 0 ;Window B attributes
wingranularity   times 2 db 0 ;Window granularity
winsize          times 2 db 0 ;Window size
winasegment      times 2 db 0 ;Window A start segment
winbsegment      times 2 db 0 ;Window B start segment
winfuncptr       times 4 db 0 ;pointer to window function
bytesperscanline times 2 db 0 ;Bytes per scan line

;Mandatory information for VBE 1.2 and above
xresolution     times 2	db 0    ;Horizontal resolution in pixel or chars
yresolution	times 2 db 0       ;Vertical resolution in pixel or chars
xcharsize       times 1	db 0    ;Character cell width in pixel
ycharsize       times 1	db 0    ;Character cell height in pixel
numberofplanes  times 1	db 0    ;Number of memory planes
bitsperpixel    times 1	db 0    ;Bits per pixel
numberofbanks   times 1	db 0    ;Number of banks
memorymodel     times 1	db 0    ;Memory model type
banksize        times 1 db 0	    ;Bank size in KB
numberofimagepages    times 1 db 0 ;Number of images
reserved1       times 1	db 0    ;Reserved for page function

;Direct Color fields (required for direct/6 and YUV/7 memory models)
redmasksize		times 1 db 0       ;Size of direct color red mask in bits
redfieldposition	times 1	db 0    ;Bit position of lsb of red bask
greenmasksize   	times 1	db 0    ;Size of direct color green mask in bits
greenfieldposition	times 1	db 0    ;Bit position of lsb of green bask
bluemasksize		times 1 db 0     ;Size of direct color blue mask in bits
bluefieldposition	times 1	db 0    ;Bit position of lsb of blue bask
rsvdmasksize        times 1	db 0    ;Size of direct color reserved mask in bits
rsvdfieldposition	times 1	db 0    ;Bit position of lsb of reserved bask
directcolormodeinfo	times 1	db 0    ;Direct color mode attributes

;Mandatory information for VBE 2.0 and above
physbaseptr times 4 db 0        ;Physical address for flat frame buffer
offscreenmemoffset times 4 db 0 ;Pointer to start of off screen memory
offscreenmemsize times 2 db 0     ;Amount of off screen memory in 1Kb units
reserved2 times 206 db 0  ;Remainder of ModeInfoBlock
rbuffstart: ;for use with networking