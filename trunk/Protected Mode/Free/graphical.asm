startupbmp:
	dw 1000000000000010b,0000000001000000b, 0000000000000000b,0010000000000000b
	dw 0100000000000010b,0000000000100000b, 0000000000000000b,0001000000000000b
	dw 0010000000000010b,0000000000010000b, 0000000000000000b,0000100000000000b
	dw 0001000000000010b,0000000000001000b, 0000000000000000b,0000010000000000b
	dw 0000100000000010b,0000000000000100b, 0000000000000000b,0000001000000000b
	dw 0000010000000010b,0000000000000010b, 0000000000000000b,0000000100000000b
	dw 0000001000000010b,0000000000000001b, 0000000000000000b,0000000010000000b
	dw 0000000100000010b,0000000000000000b, 1000000000000000b,0000000001000000b
	dw 0000000010000010b,0000000000000000b, 0100000000000000b,0000000000100000b
	dw 0000000001000010b,0000000000000000b, 0010000000000000b,0000000000010000b
	dw 0000000000100010b,0000000000000000b, 0001000000000000b,0000000000001000b
	dw 0000000000010010b,0000000000000000b, 0000100000000000b,0000000000000100b
	dw 0000000000001010b,0000000000000000b, 0000010000000000b,0000000000000010b
	dw 0000000000000110b,0000000000000000b, 0000001000000000b,0000000000000001b
	dw 0000000000000010b,0000000000000000b, 0000000100000000b,0000000000000000b
	dw 0000000000000011b,0000000000000000b, 0000000010000000b,0000000000000000b
	dw 0000000000000010b,1000000000000000b, 0000000001000000b,0000000000000000b
	dw 0000000000000010b,0100000000000000b, 0000000000100000b,0000000000000000b
	dw 0000000000000010b,0010000000000000b, 0000000000010000b,0000000000000000b
	dw 0000000000000010b,0001000000000000b, 0000000000001000b,0000000000000000b
	dw 0000000000000010b,0000100000000000b, 0000000000000100b,0000000000000000b
	dw 0000000000000010b,0000010000000000b, 0000000000000010b,0000000000000000b
	dw 0000000000000010b,0000001000000000b, 0000000000000001b,0000000000000000b
	dw 0000000000000010b,0000000100000000b, 0000000000000000b,1000000000000000b
	dw 0000000000000010b,0000000010000000b, 0000000000000000b,0100000000000000b

oldbx2 db 0,0
olddi db 0,0
oldax db 0,0
oldbx db 0,0
oldcx db 0,0
olddx db 0,0
oldsi db 0,0
endscan dw 0FA1h
startscan dw 0
mousecursorposition dw 30,30
lastcursorposition dw 0,0
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
	mov ax, 0FA0h
	jmp donevideobufcolumn
	mov cl, [enddh]
	mov al, [enddl]
	mov bx, 0
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
	mov si, font
	mov di, fontend
	mov cx, 0
	sub si, 16
fontfindnobx:
	add si, 16
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
	cmp cx, 14
	je doneshowfontnobx
	jmp fontshownobx
doneshowfontnobx:
	sub bx, 1120
nofontfoundnobx:
	inc dx
	cmp dx, 80
	jne norowchangenobx
	mov dx, 0
	add bx, 1120
norowchangenobx:
	inc bx
	mov [graphicspos], bx
	mov bx, [oldbx2]
	add bx, 2
	mov ax, 0
	cmp bx, [endscan]
	jbe videobuf2copy11
donebuf2copy:
	mov ax, [oldax]
	mov bx, [oldbx]
	mov cx, [oldcx]
	mov dx, [olddx]
	mov si, [oldsi]
	mov di, [olddi]
	ret

graphicsset db 0
graphicspos db 0,0

bluescreen:
	mov edi, [physbaseptr]
	mov cx, 0ffffh
	mov ax, 0FFh
bluescreenloop
	mov [edi], ax
	add edi, 2
	loop bluescreenloop
donebluescreen:
	jmp donebluescreen


graphical:	
	mov si, startupbmp
	mov dx, 8
	mov cx, 8
	mov ax, 64
	mov bx, 25
	;call showbmp
	mov bx, 0
	mov dx, 100
	mov cx, 1
	mov ax, 'S'
	call showfont
	jmp graphical
	


widthoffset db 0,0
width db 0,0
height db 0,0
dxolder db 0,0
widthdived db 0,0
endwidth db 0,0
bxset db 0
showbmp:				;bmp location in si
					;location in (dx, cx)
					;dimensions in (ax, bx)		
dec si
mov [dxolder], dx
mov [endwidth], dx
add [endwidth], ax
mov dx, 0
mov [width], ax
mov [height], bx
mov word [widthoffset], 80
mov bx, 8
div bx
mov dx, [dxolder]
sub [widthoffset], ax
mov [widthdived], ax
mov bx, 0
jmp foundfontdone

showfont:
	mov [cxcache3], cx
	mov si, font	
	mov word [width], 8
	mov [endwidth], dx
	add word [endwidth], 8
	mov word [height], 14
	mov word [widthoffset], 80
	sub word [widthoffset], 1
	mov word [widthdived], 1
    findfontloop:
	cmp [si], al
	je foundfontdone
	cmp si, fontend
	jae nofontfound
	add si, 16
	jmp findfontloop
   nofontfound:
	mov cx, [cxcache3]
	ret

fixtherow:
	sub dx, 640
	add bx, 80
	add cx, 14
	mov [cxcache3], cx
	jmp donefixingtehrow

cxcache3 db 0,0
remainder db 0,0
dxcache4 db 0,0
foundfontdone:
	inc si
	cmp cx, 480
	jae nofontfound
	cmp dx, 640
	jae fixtherow
donefixingtehrow:
	mov ax, dx
	mov [cxcache3], cx
	mov ecx, 0
	mov cx, dx
	mov dx, 0
	mov bx, 8
	div bx
	mov bl, al
	mov bh, 0
	mov [remainder], dx
	mov dx, cx
	mov cx, [cxcache3]
	mov di, 0
	cmp cx, 0
	je doneloadcolumn
loadcolumn:
	mov ax, 80
	mov [dxcache4], dx
	mov dx, 0
	mul cx
	add bx, ax
	mov dx, [dxcache4]
doneloadcolumn:
	mov cx, [cxcache3]
	mov ah, 0
	mov al, [si]
	ror al, 1
	cmp byte [mouseselecton], 1
	je notcheck
notcheckdone:
	mov cx, [remainder]
	mov ah, 0
	cmp cx, 0
	jne loadcharpos
loadcharposdone:
	mov cx, [cxcache3]
	mov [gs:bx], al
	inc bx
	or [gs:bx], ah
	;	inc si
	;	add dx, 8
	;	cmp dx, [endwidth]
	;	jb doneloadcolumn
	;	sub dx, 8
	;	dec si
	add bx, [widthoffset]
	inc di
	inc si
	cmp di, [height]
	jbe doneloadcolumn
	mov cx, [cxcache3]
	ret

loadcharpos:
	ror ax, 1
	loop loadcharpos
	jmp loadcharposdone

notcheck:
	not al
	jmp notcheckdone
		

mouseselecton db 0

VBEMODEBLOCK:
vbesignature 	times 4 db 0   	;VBE Signature
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

db "MODE BLOCK HERE:"

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