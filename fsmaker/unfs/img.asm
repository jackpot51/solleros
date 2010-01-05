fsys:
.h:
	db 4
	db "UnFS"
	dw 1
	db 6
	db 4
	db 2
	db 9
	db 0
	dd .NC.Node
	dd .IC.Node
.NC.Node: dd .NC.NodeEnd
	dw 0
	dd (.NC - .h)/512
	dw 0
	dd (.NCEnd - .h)/512
.NC.NodeEnd: dd 0
.IC.Node: dd .IC.NodeEnd
	dw 0
	dd (.IC - .h)/512
	dw 0
	dd (.ICEnd - .h)/512
.IC.NodeEnd: dd 0
align 512, db 0
.NC:
.SRoot.Node: dd .SRoot.NodeEnd - .h
	.root.Node:
		dd .root.Name - .IC
		db 0
		dd 0
		dd .root.NC - .h
		dd 0
.SRoot.NodeEnd: dd 0
%include "img-node.asm"
align 512, db 0
.NCEnd:
.IC:
.root.Name: dd .root.Node - .NC
	db "",0
%include "img-index.asm"
align 512, db 0
.ICEnd:
%include "img-inc.asm"
