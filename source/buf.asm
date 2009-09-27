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
