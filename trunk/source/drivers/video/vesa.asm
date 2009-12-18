[BITS 16]
guiswitch:
	cmp cx, 0
	jne guiswitchdefnum
	mov ax, 12h
	xor bx, bx
	int 10h
	call guiloadagain
guiswitchnocando:
	ret	;return without switching as mode number is bad
guiswitchdefnum:	;switch to a defined mode number
	mov ax, 0x4F00
	mov di, VBEMODEBLOCK
	int 10h
	mov si, reserved
	sub si, 2
.loop:
	add si, 2
	cmp si, oemdata
	je guiswitchnocando
	cmp word [si], 0xFFFF
	je guiswitchnocando
	cmp [si], cx
	jne .loop
	mov [videomodecache], si
	or cx, 0x4000	;make sure linear frame buffer is selected
	mov ax, 0x4F01
	mov di, VBEMODEINFOBLOCK
	mov [vesamode], cx
	int 10h
	jmp selectedvesa
guiload:
	mov si, bootmsg
	call printrm
	xor ax, ax
	int 16h
	cmp al, "y"
	jne near vgaset
	mov si, crlf
	call printrm
guiloadagain:
	mov ax, 04F00h
	mov di, VBEMODEBLOCK
	int 10h
	mov si, reserved
	sub si, 2
findvideomodes:
	add si, 2
	mov cx, [si]
	cmp cx, 0xFFFF
	je near nextvmode
	cmp si, oemdata
	jae near vgaset	;;kill if no valid list is found
	jmp findvideomodes 	
;;debug,shows vmodes available
nextvmode:
	sub si, 2
	cmp si, reserved
	jb near guiloadagain
	mov cx, [si]
	cmp cx, 0xFFFF
	je near nextvmode
	or cx, 0x4000 		;;Linear Frame Buffer
	mov ax, 04F01h
	mov di, VBEMODEINFOBLOCK
	mov [vesamode], cx
	int 10h
	mov al, [bitsperpixel]
	cmp al, 16
	jne nextvmode
	mov [videomodecache], si
	test ah, ah
	jz near setvesamode
	jmp nextvmode
isthisvideook db 10,13,"Is this video mode OK?(y/n)",13,10,0
setvesamode:
	mov cx, [resolutionx]
	call decshow
	mov al, "x"
	call char
	mov cx, [resolutiony]
	call decshow
	mov al, "@"
	call char
	xor cx, cx
	mov cl, [bitsperpixel]
	call decshow
	mov si, isthisvideook
	call printrm
	xor ax, ax
	int 16h
	mov si, [videomodecache]
	cmp al, "y"
	jne near nextvmode
selectedvesa:
	mov dx, [resolutionx]
	add dx, dx
	mov [resolutionx2], dx
	xor dx, dx
	xor cx, cx
	mov ax, 04F02h
	mov bx, [vesamode]
	int 10h		;;enter VESA mode
	mov byte [guion], 1
	call getmemorysize;get the memory map after the video is initialized
	ret
	
vesamode dw 0
videomodecache dw 0

    printrm:			; 'si' comes in with string address
	    mov bx,07		; write to display
	    mov ah,0Eh		; screen function
    prs2:    mov al,[si]         ; get next character
	    cmp al,0		; look for terminator 
            je finpr2		; zero byte at end of string
	    int 10h		; write character to screen.    
     	    inc si	     	; move to next character
	    jmp prs2		; loop
    finpr2: ret

dcnm db 0,0,0,0,0
dcnmend db 0,0


decshow:
	mov si, dcnm
decclear:
	mov al, "0"
	mov [si], al
	inc si
	cmp si, dcnmend
	jbe decclear
	dec si
	call convertrm
	mov si, dcnm
dectst:
	mov al, [si]
	inc si
	cmp si, dcnmend
	ja dectstend
	cmp al, "0"
	jbe dectst
dectstend:
	dec si
	call printrm
	ret
	
	
convertrm:
	dec si
	mov bx, si		;place to convert into must be in si, number to convert must be in cx
cnvrtrm:
	mov si, bx
	sub si, 3
ten3rm:	inc si
	cmp cx, 1000
	jb ten2rm
	sub cx, 1000
	inc byte [si]
	jmp cnvrtrm
ten2rm:	inc si
	cmp cx, 100
	jb ten1rm
	sub cx, 100
	inc byte [si]
	jmp cnvrtrm
ten1rm:	inc si
	cmp cx, 10
	jb ten0rm
	sub cx, 10
	inc byte [si]
	jmp cnvrtrm
ten0rm:	inc si
	cmp cx, 1
	jb tendnrm
	sub cx, 1
	inc byte [si]
	jmp cnvrtrm
tendnrm:
	ret

    char: 		    ;char must be in al
       mov bx, 07
	   mov ah, 0Eh
	   int 10h
	   ret

bootmsg:	db "Boot into the GUI?(y/n)",0


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
mcursorend:


VBEMODEBLOCK:
vbesignature 		times  4 db 0 	;VBE Signature
vbeversion  		times  2 db 0	;VBE Version
oemstringptr  		times  4 db 0	;Pointer to OEM String
capabilities 		times  4 db 0	;Capabilities of graphics cont.
videomodeptr 		times  4 db 0	;Pointer to Video Mode List
totalmemory   		times  2 db 0	;number of 64Kb memory blocks
oemsoftwarerev  	times  2 db 0	;VBE implementation Software revision
oemvendornameptr 	times  4 db 0	;Pointer to Vendor Name String
oemproductnameptr 	times  4 db 0	;Pointer to Product Name String
oemproductrevptr 	times  4 db 0	;Pointer to Product Revision String
reserved			times  222 db 0	;Reserved for VBE implementation scratch area
oemdata 			times  256 db 0	;Data Area for OEM Strings

VBEMODEINFOBLOCK:
;Mandatory information for all VBE revision
modeattributes   	times  2 db 0	;Mode attributes
winaattributes   	times  1 db 0	;Window A attributes
winbattributes   	times  1 db 0	;Window B attributes
wingranularity   	times  2 db 0	;Window granularity
winsize          	times  2 db 0	;Window size
winasegment      	times  2 db 0	;Window A start segment
winbsegment      	times  2 db 0	;Window B start segment
winfuncptr       	times  4 db 0	;pointer to window function
bytesperscanline 	times  2 db 0	;Bytes per scan line

;Mandatory information for VBE 1.2 and above
resolutionx     	times  2 db 0	;Horizontal resolution in pixel or chars
resolutiony	    	times  2 db 0	;Vertical resolution in pixel or chars
xcharsize       	times  1 db 0	;Character cell width in pixel
ycharsize       	times  1 db 0	;Character cell height in pixel
numberofplanes  	times  1 db 0	;Number of memory planes
bitsperpixel    	times  1 db 0	;Bits per pixel
numberofbanks   	times  1 db 0	;Number of banks
memorymodel     	times  1 db 0	;Memory model type
banksize        	times  1 db 0	;Bank size in KB
numberofimagepages	times  1 db 0	;Number of images
reserved1       	times  1 db 0	;Reserved for page function

;Direct Color fields (required for direct/6 and YUV/7 memory models)
redmasksize			times  1 db 0	;Size of direct color red mask in bits
redfieldposition	times  1 db 0	;Bit position of lsb of red bask
greenmasksize   	times  1 db 0	;Size of direct color green mask in bits
greenfieldposition	times  1 db 0	;Bit position of lsb of green bask
bluemasksize		times  1 db 0	;Size of direct color blue mask in bits
bluefieldposition	times  1 db 0	;Bit position of lsb of blue bask
rsvdmasksize        times  1 db 0		;Size of direct color reserved mask in bits
rsvdfieldposition	times  1 db 0		;Bit position of lsb of reserved bask
directcolormodeinfo	times  1 db 0	;Direct color mode attributes

;Mandatory information for VBE 2.0 and above
physbaseptr 		times  4 db 0	;Physical address for flat frame buffer
offscreenmemoffset 	times  4 db 0	;Pointer to start of off screen memory
offscreenmemsize 	times  2 db 0    ;Amount of off screen memory in 1Kb units
reserved2 			times  206 db 0  ;Remainder of ModeInfoBlock

resolutionx2 dw 0	;this is not part of the VBE but is necessary GUI info
VBEEND:
[BITS 32]