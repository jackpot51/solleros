align 512, db 0
bssstart equ $
bsscopy equ $
initialstack equ bsscopy
stackend equ initialstack + 8192
sigtable equ stackend + 4
fileindex equ sigtable + 4
fileindexend equ fileindex + 1024
previousstack equ fileindexend
lastfolderloc equ previousstack + 4
currentfolderloc equ lastfolderloc + 4
currentfolder equ currentfolderloc + 4
currentfolderend equ currentfolder + 512
uid equ currentfolderend
ranboot equ uid + 4
IFON equ ranboot + 1
IFTRUE equ IFON + 1
BATCHPOS equ IFTRUE + 100
BATCHISON equ BATCHPOS + 4
LOOPON equ BATCHISON + 1
LOOPPOS	equ LOOPON + 1
variables equ LOOPPOS + 4
varend equ variables + 4096
buftxt2 equ varend
buftxt equ buftxt2 + 1024
buftxtend equ buftxt + 1024
buf2 equ buftxtend
numbuf equ buf2 + 20
%ifdef io.serial
	lastcommandpos equ numbuf
%else
	%ifdef gui.included
		graphicstable equ numbuf ;w type, dw datalocation, w locationx, w locationy, w selected, dw code
		graphicstableend equ graphicstable + 512
		%ifdef gui.background
			backgroundbuffer equ graphicstableend
			backgroundbufferend equ backgroundbuffer + 1280*1026*2
			mousecolorbuf equ backgroundbufferend
		%else
			mousecolorbuf equ graphicstableend ;where the gui under the mouse is stored
		%endif
		mcolorend equ mousecolorbuf + 256
		videobuf equ mcolorend	;1680x1050 pixels in characters
		videobufend	equ videobuf + 210*65*4;2
		videobuf2 equ videobufend
		videobuf2end equ videobuf2 + 210*65*4;2
	%else
		videobuf equ numbuf
		videobufend equ videobuf + 80*30*4
		videobuf2 equ videobufend
		videobuf2end equ videobuf2 + 80*30*4
	%endif
	lastcommandpos: equ videobuf2end
%endif
	commandbufpos: equ lastcommandpos + 4
	commandlistentries: equ commandbufpos + 4
	commandsentered: equ commandlistentries + 4
	commandbuf: equ commandsentered + 4
	commandbufend: equ commandbuf + 4096 ;this is where kernel space only ends, the rest is for threading
%ifdef network.included
	rbuffstart: equ commandbufend ;for use with networking
	rbuffend equ rbuffstart + 8192 + 16 ;extra space used for the WRAP bit in rtl8139
	rbuffoverflow equ rbuffend + 1500
%else
	rbuffstart equ commandbufend
	rbuffend equ commandbufend
%endif
%ifdef threads.included
	threadlist: equ rbuffend ;this buffer will hold the stack locations of all of the threads, up to 1024
	threadlistend: equ threadlist + 1024*4
	stacks:	equ threadlistend ;NOT TRUE:i use SS now for proper stack management. This makes sure stacks never screw with other memory
	stack1: equ stacks + 2048  ;woah, thats a lot of space for stacks
	bssend equ stack1 + 1024*2048
%else
	bssend equ rbuffend
%endif
dosprogloc equ 0x400000 ;from here on, it is not kernel space so apps can be loaded here.
