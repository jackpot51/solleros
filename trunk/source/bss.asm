bssstart: equ $
initialstack equ bssstart
stackend equ initialstack + 4000
fileindex: equ stackend + 96
fileindexend: equ fileindex + 1024
uid equ fileindexend
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
%ifdef gui.included
	graphicstable equ numbuf + 1 ;w type, dw datalocation, w locationx, w locationy, w selected, dw code
	graphicstableend equ graphicstable + 200h
	mousecolorbuf equ graphicstableend ;where the gui under the mouse is stored
	mcolorend equ mousecolorbuf + 256
	videobuf equ mcolorend + 1	;1280x1024pixels in characters
	videobufend	equ videobuf + 160*64*2
	videobuf2 equ videobufend
	videobuf2end equ videobuf2 + 160*64*2
%else
	videobuf equ numbuf + 1
	videobufend equ videobuf + 80*30*2
	videobuf2 equ videobufend
	videobuf2end equ videobuf2 + 160*64*2
%endif
lastcommandpos: equ videobuf2end
currentcommandpos: equ lastcommandpos + 4
commandbuf: equ currentcommandpos + 4
commandbufend: equ commandbuf + 4096 ;this is where kernel space only ends, the rest is for threading
rbuffstart: equ commandbufend ;for use with networking
threadlist: equ rbuffstart + 8212 ;this buffer will hold the stack locations of all of the threads, up to 2048
threadlistend: equ threadlist + 1024*4
stacks:	equ threadlistend ;i use SS now for proper stack management. This makes sure stacks never screw with other memory
stackdummy: equ stacks + 1024
stack1: equ stackdummy + 1024  ;woah, thats a lot of space for stacks
bssend equ stack1 + 1024*1024
dosprogloc equ 0x400000 ;from here on, it is not kernel space so apps can be loaded here.
