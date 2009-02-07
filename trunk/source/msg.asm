	exitmsg db	"exit",0
	notfound1 db "Program ",34,0
	notfound2 db  34," not found.",13,10,0
	pwdask	db	"Enter Password:",0
	pwd	db	"password",0
	cmd	db	"[user@SollerOS-v0.9.0$]",0
	line	db	13,10,0
    msg:       db "SollerOS Beta version 0.9.0 - compiled by Jeremy Soller.",13,10,0
    wrongmsg:  db "Please select one of the options above.",13,10,"You selected: ",0
	batchmsg db "To run this batch type runbatch and press enter.",10,13,0
	
fonts:	incbin 'source/precompiled/fonts.pak'
fontend2:
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
fontend:

cursorbmp:
	db	1,0,0,0,0,0,0,0
	db	1,1,0,0,0,0,0,0
	db	1,1,1,0,0,0,0,0
	db	1,1,1,1,0,0,0,0
	db	1,1,1,1,1,0,0,0
	db	1,1,1,1,1,1,0,0
	db	1,1,1,1,1,1,1,0
	db	1,1,1,1,1,1,1,1
	db	1,1,1,1,1,1,0,0
	db	1,1,0,1,1,1,0,0
	db	1,0,0,1,1,1,0,0
	db	0,0,0,0,1,1,1,0
	db	0,0,0,0,1,1,1,0
	db	0,0,0,0,0,1,1,1
	db	0,0,0,0,0,1,1,1
	db	0,0,0,0,0,1,1,0
cursorbmpend:
;;; ZEROS-THESE DO NOT NEED TO BE COMPILED BUT ADDRESSES SHOULD BE USED
;;[section .bss] compile these

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
fileindex: times 200h db 0	
fileindexend:
bufferhelper:	db 0
variables: 	times 500h db 0
varend:
buftxt: times 200h db 0
buf2:	times 20 db 0	;;should be initialized as '0'
numbuf:  db 0
videobuf2 	times 0x12C0 db 0
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