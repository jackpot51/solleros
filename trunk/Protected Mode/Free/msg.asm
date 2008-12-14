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
[section .bss]

graphicstable: ;w type, w datalocation, w locationx, w locationy, w selected, w code
	resb 200h
	graphicstableend:
mousecolorbuf: ;where the gui under the mouse is stored
resb 256
mcolorend:
IFON resb 1
IFTRUE resb 100
BATCHPOS resb 2
BATCHISON resb 1
LOOPON resb 1
LOOPPOS	resb 2
fonts:	resb 2048
fontend2:
		resb 16
fontend:
fileindex: resb 500h	;index format can be found in SollerOS programming guide
customprograms:			;put custom index items here. I promise I won't overwrite them
				;although they may be written twice if they are in the filesystem
;;	db 5,4,"Hello World"
;;	dw 0,hello,0		;;example of a custom file descriptor
	
fileindexend:
bufferhelper:	resb 2
variables: resb 500h
varend:
buftxt: resb 200h
buf2:	resb 20	;;should be initialized as '0'
numbuf:	resb 2
videobuf2 resb 0x12C0
videobufend:
resb 200

VBEMODEBLOCK:
vbesignature 	resb 4 	;VBE Signature
vbeversion  		resb 2    ;VBE Version
oemstringptr  		resb 4  ;Pointer to OEM String
capabilities 	resb 4   	;Capabilities of graphics cont.
videomodeptr 		resb 4  ;Pointer to Video Mode List
totalmemory   		resb 2    ;number of 64Kb memory blocks
oemsoftwarerev  	resb 2	;VBE implementation Software revision
oemvendornameptr 	resb 4 	;Pointer to Vendor Name String
oemproductnameptr 	resb 4 	;Pointer to Product Name String
oemproductrevptr 	resb 4	;Pointer to Product Revision String
reserved	resb 222	;Reserved for VBE implementation scratch area
oemdata 	resb 256	;Data Area for OEM Strings


VBEMODEINFOBLOCK:
;Mandatory information for all VBE revision
modeattributes   resb 2  ;Mode attributes
winaattributes   resb 1  ;Window A attributes
winbattributes   resb 1  ;Window B attributes
wingranularity   resb 2  ;Window granularity
winsize          resb 2  ;Window size
winasegment      resb 2 ;Window A start segment
winbsegment      resb 2  ;Window B start segment
winfuncptr       resb 4  ;pointer to window function
bytesperscanline resb 2  ;Bytes per scan line

;Mandatory information for VBE 1.2 and above
xresolution     resb 2	    ;Horizontal resolution in pixel or chars
yresolution	resb 2        ;Vertical resolution in pixel or chars
xcharsize       resb 1	    ;Character cell width in pixel
ycharsize       resb 1	    ;Character cell height in pixel
numberofplanes  resb 1	    ;Number of memory planes
bitsperpixel    resb 1	    ;Bits per pixel
numberofbanks   resb 1	    ;Number of banks
memorymodel     resb 1	    ;Memory model type
banksize        resb 1 	    ;Bank size in KB
numberofimagepages    resb 1  ;Number of images
reserved1       resb 1	    ;Reserved for page function

;Direct Color fields (required for direct/6 and YUV/7 memory models)
redmasksize		resb 1        ;Size of direct color red mask in bits
redfieldposition	resb 1	    ;Bit position of lsb of red bask
greenmasksize   	resb 1	    ;Size of direct color green mask in bits
greenfieldposition	resb 1	    ;Bit position of lsb of green bask
bluemasksize		resb 1      ;Size of direct color blue mask in bits
bluefieldposition	resb 1	    ;Bit position of lsb of blue bask
rsvdmasksize        resb 1	    ;Size of direct color reserved mask in bits
rsvdfieldposition	resb 1	    ;Bit position of lsb of reserved bask
directcolormodeinfo	resb 1	    ;Direct color mode attributes

;Mandatory information for VBE 2.0 and above
physbaseptr resb 4         ;Physical address for flat frame buffer
offscreenmemoffset resb 4  ;Pointer to start of off screen memory
offscreenmemsize resb 2      ;Amount of off screen memory in 1Kb units
reserved2 resb 206   ;Remainder of ModeInfoBlock
rbuffstart: ;for use with networking

;oldstuff:
