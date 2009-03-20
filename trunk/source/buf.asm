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
IFON resb 1 
IFTRUE resb 100 
BATCHPOS resb 4 
BATCHISON resb 1 
LOOPON resb 1 
LOOPPOS	resb 4 
fileindex: resb 200h 
fileindexend:
variables: 	resb 500h 
varend: resb 1 
buftxt: resb 200h 
buf2:	resb 20 
numbuf: resb 1 
videobuf2 		resb 0x12C0 
videobufend		resb 200 
;processcache:	;;eip, eax, ebx, ecx, edx, edi, esi, esp, ebp-9*4=36 bytes each
;processcacheend:
;alignb 4096		;;align 4 kbytes
;ospagedir:
;	resb 4096
;ospagedirend:
;pagetables:
;	resb 4096

rbuffstart: ;for use with networking
resb 8212
bssend:
[section .text]