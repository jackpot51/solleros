align 4, nop
bssstart: equ $
guion equ bssstart
DriveNumber equ guion + 1
lbaad equ DriveNumber + 1
memlistbuf equ lbaad + 4
memlistend equ memlistbuf + 576
bsscopy equ memlistend
initialstack equ bsscopy
stackend equ initialstack + 4000
fileindex: equ stackend + 96
fileindexend: equ fileindex + 1024
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
variables: equ LOOPPOS + 4
varend: equ variables + 4096
buftxt2: equ varend
buftxt: equ buftxt2 + 1024
buftxtend: equ buftxt + 1024
buf2: equ buftxtend
numbuf: equ buf2 + 20
%ifdef io.serial
	lastcommandpos equ numbuf + 1
%else
	%ifdef gui.included
		graphicstable equ numbuf + 1 ;w type, dw datalocation, w locationx, w locationy, w selected, dw code
		graphicstableend equ graphicstable + 200h
		%ifdef gui.background
			backgroundbuffer equ graphicstableend
			backgroundbufferend equ backgroundbuffer + 1280*1026*2
			mousecolorbuf equ backgroundbufferend
		%else
			mousecolorbuf equ graphicstableend ;where the gui under the mouse is stored
		%endif
		mcolorend equ mousecolorbuf + 256
		videobuf equ mcolorend + 1	;1680x1050 pixels in characters
		videobufend	equ videobuf + 210*65*2
		videobuf2 equ videobufend
		videobuf2end equ videobuf2 + 210*65*2
	%else
		videobuf equ numbuf + 1
		videobufend equ videobuf + 80*30*2
		videobuf2 equ videobufend
		videobuf2end equ videobuf2 + 80*30*2
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
	rbuffend equ rbuffstart + 8212
%else
	rbuffstart equ commandbufend
	rbuffend equ commandbufend
%endif
%ifdef threads.included
	threadlist: equ rbuffend ;this buffer will hold the stack locations of all of the threads, up to 2048
	threadlistend: equ threadlist + 1024*4
	stacks:	equ threadlistend ;i use SS now for proper stack management. This makes sure stacks never screw with other memory
	stack1: equ stacks + 1024  ;woah, thats a lot of space for stacks
	bssend equ stack1 + 1024*1024
%else
	bssend equ rbuffend
%endif
dosprogloc equ 0x400000 ;from here on, it is not kernel space so apps can be loaded here.
