bssstart: equ $
stack: equ bssstart
stackend: equ stack + 4096
graphicstable equ stackend;w type, dw datalocation, w locationx, w locationy, w selected, dw code
	graphicstableend equ graphicstable + 200h
mousecolorbuf equ graphicstableend ;where the gui under the mouse is stored
mcolorend equ mousecolorbuf + 256
fileindex: equ mcolorend
fileindexend: equ fileindex + 1024
uid equ fileindexend
IFON equ uid + 4
IFTRUE equ IFON + 1
BATCHPOS equ IFTRUE + 100
BATCHISON equ BATCHPOS + 4
LOOPON equ BATCHISON + 1
LOOPPOS	equ LOOPON + 1
variables: equ LOOPPOS + 4
varend: equ variables + 4096
buftxt2: equ varend
buftxt: equ buftxt2 + 1024 + 10
buftxtend: equ buftxt + 1024
buf2: equ buftxtend
numbuf: equ buf2 + 20
videobuf equ numbuf + 1	;1280x1024pixels in characters
videobufend	equ videobuf + 160*64*2
videobuf2 equ videobufend + 160*2
videobuf2end equ videobuf2 + 160*64*2
lastcommandpos: equ videobuf2end + 160*2
currentcommandpos: equ lastcommandpos + 4
commandbuf: equ currentcommandpos + 4
commandbufend: equ commandbuf + 4096 ;this is where kernel space only ends, the rest is for threading
rbuffstart: equ commandbufend ;for use with networking
threadlist: equ rbuffstart + 8212 ;this buffer will hold the stack locations of all of the threads, up to 2048
threadlistend: equ threadlist + 2050*4
stacks:	equ threadlistend ;the stacks will go on forever until end of memory
stackdummy: equ stacks + 1024
stack1: equ stackdummy + 1024  ;woah, thats a lot of space for stacks
bssend:	equ stack1 + 1024*2050	;from here on, it is not kernel space so apps can be loaded here.
dosprogloc equ 0x400000