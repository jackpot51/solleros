oldbx2 db 0,0
olddi db 0,0
oldax db 0,0
oldbx db 0,0
oldcx db 0,0
olddx db 0,0
oldsi db 0,0
endscan dw 0FA1h
startscan dw 0

checkcursorselect:
	mov byte [mouseselecton], 1
	jmp checkcursorselectdone
videobuf2copy:
	mov [oldax], ax
	mov [oldbx], bx
	mov [oldcx], cx
	mov [olddx], dx
	mov [oldsi], si
	mov [olddi], di
	mov ax, videobufend
	sub ax, videobuf2
	jmp donevideobufcolumn
	mov cl, [enddh]
	mov al, [enddl]
	mov ebx, 0
	mov ah, 0
	mov ch, 0
	cmp cx, 0
	je donevideobufcolumn
videobufcolumn:
	mov dx, 0
	mov bx, ax
	mov ax, 160
	mul cx
	add ax, bx
donevideobufcolumn:
	mov [endscan], ax
	mov cx, 0
	mov dx, 0
	mov bx, 0
	mov [graphicspos], bx
videobuf2copy11:
	mov ax, [fs:bx]
	mov byte [mouseselecton], 0
	cmp ah, 0F8h
	je checkcursorselect
checkcursorselectdone:
	mov [oldbx2], bx
	mov bx, [graphicspos]
	mov ah, 0
	mov si, fonts
	mov di, fontend
	mov cx, 0
	sub si, 17
fontfindnobx:
	add si, 17
	cmp si, di
	jae nofontfoundnobx
	cmp al, [si]
	jne fontfindnobx
fontshownobx:
	inc si
	mov al, [si]
	ror al, 1
	cmp byte [mouseselecton], 1
	jne donotnotal
	not al
donotnotal:	
	mov [gs:bx], al
	add bx, 80
	inc cx
	cmp cx, 15
	je doneshowfontnobx
	jmp fontshownobx
doneshowfontnobx:
	mov al, 0
	mov [gs:bx], al
	sub bx, 1200
nofontfoundnobx:
	inc dx
	cmp dx, 80
	jne norowchangenobx
	mov dx, 0
	add bx, 1200
norowchangenobx:
	inc bx
	mov [graphicspos], bx
	mov bx, [oldbx2]
	add bx, 2
	mov ax, 0
	cmp bx, [endscan]
	jbe videobuf2copy11
donebuf2copy:	
	mov byte [mouseselecton], 0
	mov byte [termcopyon], 1
	cmp byte [guion], 1
	je near windowvideocopy
	mov ax, [oldax]
	mov bx, [oldbx]
	mov cx, [oldcx]
	mov dx, [olddx]
	mov si, [oldsi]
	mov di, [olddi]
	ret
	
termcopyon db 0
graphicsset db 0
graphicspos db 0,0
showcursorfonton db 0
savefonton db 0
mouseselecton db 0


VBEMODEBLOCK:
vbesignature 	times 4 db 0 	;VBE Signature
vbeversion  		dw 0    ;VBE Version
oemstringptr  		dw 0,0  ;Pointer to OEM String
capabilities 	times 4 db 0   	;Capabilities of graphics cont.
videomodeptr 		dw 0,0  ;Pointer to Video Mode List
totalmemory   		dw 0    ;number of 64Kb memory blocks
oemsoftwarerev  	dw 0  	;VBE implementation Software revision
oemvendornameptr 	dw 0,0 	;Pointer to Vendor Name String
oemproductnameptr 	dw 0,0 	;Pointer to Product Name String
oemproductrevptr 	dw 0,0	;Pointer to Product Revision String
reserved	times 222 db 0	;Reserved for VBE implementation scratch area
oemdata 	times 256 db 0	;Data Area for OEM Strings


VBEMODEINFOBLOCK:
;Mandatory information for all VBE revision
modeattributes   dw 0  ;Mode attributes
winaattributes   db 0  ;Window A attributes
winbattributes   db 0  ;Window B attributes
wingranularity   dw 0  ;Window granularity
winsize          dw 0  ;Window size
winasegment      dw 0  ;Window A start segment
winbsegment      dw 0  ;Window B start segment
winfuncptr       dw 0,0  ;pointer to window function
bytesperscanline dw 0  ;Bytes per scan line

;Mandatory information for VBE 1.2 and above
xresolution     dw 0	    ;Horizontal resolution in pixel or chars
yresolution	dw 0        ;Vertical resolution in pixel or chars
xcharsize       db 0	    ;Character cell width in pixel
ycharsize       db 0	    ;Character cell height in pixel
numberofplanes  db 0	    ;Number of memory planes
bitsperpixel    db 0	    ;Bits per pixel
numberofbanks   db 0	    ;Number of banks
memorymodel     db 0	    ;Memory model type
banksize        db 0 	    ;Bank size in KB
numberofimagepages    db 0  ;Number of images
reserved1       db 0	    ;Reserved for page function

;Direct Color fields (required for direct/6 and YUV/7 memory models)
redmasksize		db 0        ;Size of direct color red mask in bits
redfieldposition	db 0	    ;Bit position of lsb of red bask
greenmasksize   	db 0	    ;Size of direct color green mask in bits
greenfieldposition	db 0	    ;Bit position of lsb of green bask
bluemasksize		db 0        ;Size of direct color blue mask in bits
bluefieldposition	db 0	    ;Bit position of lsb of blue bask
rsvdmasksize        	db 0	    ;Size of direct color reserved mask in bits
rsvdfieldposition	db 0	    ;Bit position of lsb of reserved bask
directcolormodeinfo	db 0	    ;Direct color mode attributes

;Mandatory information for VBE 2.0 and above
physbaseptr dw 0,0         ;Physical address for flat frame buffer
offscreenmemoffset dw 0,0  ;Pointer to start of off screen memory
offscreenmemsize dw 0      ;Amount of off screen memory in 1Kb units
reserved2 times 206 db 0   ;Remainder of ModeInfoBlock
