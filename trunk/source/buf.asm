[section .bss]
bssstart:
stack:
	resb 4096
stackend:

graphicstable: ;w type, dw datalocation, w locationx, w locationy, w selected, dw code
	resb 200h 
	graphicstableend:
mousecolorbuf: ;where the gui under the mouse is stored
	resb 256
mcolorend:
fileindex: resb 200h
fileindexend:
IFON resb 1 
IFTRUE resb 100 
BATCHPOS resb 4 
BATCHISON resb 1 
LOOPON resb 1 
LOOPPOS	resb 4 
variables: 	resb 500h 
varend: resb 1
buftxt2: resb 100h
resb 10
buftxt: resb 200h 
buftxtend:
buf2:	resb 20 
numbuf: resb 1 
videobuf 		resb (160*64*2)	;1280x1024pixels in characters
videobufend		resb 200
lastcommandpos: resb 4
currentcommandpos: resb 4
commandbuf:
resb 1024
commandbufend:	;this is where kernel space only ends, the rest is for threading

VBEMODEBLOCK:
vbesignature 		resb 4 	;VBE Signature
vbeversion  		resb 2 	;VBE Version
oemstringptr  		resb 4 	;Pointer to OEM String
capabilities 		resb 4 	;Capabilities of graphics cont.
videomodeptr 		resb 4 	;Pointer to Video Mode List
totalmemory   		resb 2 	;number of 64Kb memory blocks
oemsoftwarerev  	resb 2 	;VBE implementation Software revision
oemvendornameptr 	resb 4 	;Pointer to Vendor Name String
oemproductnameptr 	resb 4 	;Pointer to Product Name String
oemproductrevptr 	resb 4 	;Pointer to Product Revision String
reserved			resb 222 	;Reserved for VBE implementation scratch area
oemdata 			resb 256 	;Data Area for OEM Strings

VBEMODEINFOBLOCK:
;Mandatory information for all VBE revision
modeattributes   	resb 2 	;Mode attributes
winaattributes   	resb 1 	;Window A attributes
winbattributes   	resb 1 	;Window B attributes
wingranularity   	resb 2 	;Window granularity
winsize          	resb 2 	;Window size
winasegment      	resb 2 	;Window A start segment
winbsegment      	resb 2 	;Window B start segment
winfuncptr       	resb 4 	;pointer to window function
bytesperscanline 	resb 2 	;Bytes per scan line

;Mandatory information for VBE 1.2 and above
xresolution     	resb 2 	;Horizontal resolution in pixel or chars
yresolution	    	resb 2 	;Vertical resolution in pixel or chars
xcharsize       	resb 1 	;Character cell width in pixel
ycharsize       	resb 1 	;Character cell height in pixel
numberofplanes  	resb 1 	;Number of memory planes
bitsperpixel    	resb 1 	;Bits per pixel
numberofbanks   	resb 1 	;Number of banks
memorymodel     	resb 1 	;Memory model type
banksize        	resb 1 	;Bank size in KB
numberofimagepages	resb 1 	;Number of images
reserved1       	resb 1 	;Reserved for page function

;Direct Color fields (required for direct/6 and YUV/7 memory models)
redmasksize			resb 1 	;Size of direct color red mask in bits
redfieldposition	resb 1 	;Bit position of lsb of red bask
greenmasksize   	resb 1 	;Size of direct color green mask in bits
greenfieldposition	resb 1 	;Bit position of lsb of green bask
bluemasksize		resb 1 	;Size of direct color blue mask in bits
bluefieldposition	resb 1 	;Bit position of lsb of blue bask
rsvdmasksize        resb 1		;Size of direct color reserved mask in bits
rsvdfieldposition	resb 1		;Bit position of lsb of reserved bask
directcolormodeinfo	resb 1 	;Direct color mode attributes

;Mandatory information for VBE 2.0 and above
physbaseptr 		resb 4 	;Physical address for flat frame buffer
offscreenmemoffset 	resb 4 	;Pointer to start of off screen memory
offscreenmemsize 	resb 2     ;Amount of off screen memory in 1Kb units
reserved2 			resb 206   ;Remainder of ModeInfoBlock

rbuffstart: ;for use with networking
;resb 8212
threadlist:	;;this buffer will hold the stack locations of all of the threads, up to 2048
	resb 2050*4
threadlistend:
stacks:		;;the stacks will go on forever until end of memory
	resb 1024
stackdummy:
	resb 1024
stack1:
	resb 1024*2050	;;woah, thats a lot of space for stacks
bssend:		;;from here on, it is not kernel space so apps can be loaded here.
align 4192, resb 0
dosprogloc equ $
[section .text]
