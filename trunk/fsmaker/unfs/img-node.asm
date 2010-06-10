.root.NC: dd .root.NCEnd - .NC
	.root.bin.Node:
		dd .root.bin.Name - .IC
		db 0
		dd 0
		dd .root.bin.NC - .NC
		dd .root.Node - .NC
	.root.dostest.com.Node:
		dd .root.dostest.com.Name - .IC
		db 1
		dd 0
		dd .root.dostest.com.NC - .NC
		dd .root.Node - .NC
	.root.home.Node:
		dd .root.home.Name - .IC
		db 0
		dd 0
		dd .root.home.NC - .NC
		dd .root.Node - .NC
	.root.tutorial.sh.Node:
		dd .root.tutorial.sh.Name - .IC
		db 1
		dd 0
		dd .root.tutorial.sh.NC - .NC
		dd .root.Node - .NC
.root.NCEnd: dd 0
.root.bin.NC: dd .root.bin.NCEnd - .NC
	.root.bin.int.Node:
		dd .root.bin.int.Name - .IC
		db 1
		dd 0
		dd .root.bin.int.NC - .NC
		dd .root.bin.Node - .NC
	.root.bin.tely.Node:
		dd .root.bin.tely.Name - .IC
		db 1
		dd 0
		dd .root.bin.tely.NC - .NC
		dd .root.bin.Node - .NC
	.root.bin.unfs.Node:
		dd .root.bin.unfs.Name - .IC
		db 1
		dd 0
		dd .root.bin.unfs.NC - .NC
		dd .root.bin.Node - .NC
.root.bin.NCEnd: dd 0
.root.bin.int.NC: dd .root.bin.NCEnd - .NC
	dw 0
	dd (.root.bin.int.Bin - .h)/512
	dw 0
	dd (.root.bin.int.BinEnd - .h)/512
.root.bin.int.NCEnd: dd 0
.root.bin.tely.NC: dd .root.bin.NCEnd - .NC
	dw 0
	dd (.root.bin.tely.Bin - .h)/512
	dw 0
	dd (.root.bin.tely.BinEnd - .h)/512
.root.bin.tely.NCEnd: dd 0
.root.bin.unfs.NC: dd .root.bin.NCEnd - .NC
	dw 0
	dd (.root.bin.unfs.Bin - .h)/512
	dw 0
	dd (.root.bin.unfs.BinEnd - .h)/512
.root.bin.unfs.NCEnd: dd 0
.root.dostest.com.NC: dd .root.NCEnd - .NC
	dw 0
	dd (.root.dostest.com.Bin - .h)/512
	dw 0
	dd (.root.dostest.com.BinEnd - .h)/512
.root.dostest.com.NCEnd: dd 0
.root.home.NC: dd .root.home.NCEnd - .NC
	.root.home.user.Node:
		dd .root.home.user.Name - .IC
		db 0
		dd 0
		dd .root.home.user.NC - .NC
		dd .root.home.Node - .NC
.root.home.NCEnd: dd 0
.root.home.user.NC: dd .root.home.user.NCEnd - .NC
	.root.home.user.solleros.txt.Node:
		dd .root.home.user.solleros.txt.Name - .IC
		db 1
		dd 0
		dd .root.home.user.solleros.txt.NC - .NC
		dd .root.home.user.Node - .NC
.root.home.user.NCEnd: dd 0
.root.home.user.solleros.txt.NC: dd .root.home.user.NCEnd - .NC
	dw 0
	dd (.root.home.user.solleros.txt.Bin - .h)/512
	dw 0
	dd (.root.home.user.solleros.txt.BinEnd - .h)/512
.root.home.user.solleros.txt.NCEnd: dd 0
.root.tutorial.sh.NC: dd .root.NCEnd - .NC
	dw 0
	dd (.root.tutorial.sh.Bin - .h)/512
	dw 0
	dd (.root.tutorial.sh.BinEnd - .h)/512
.root.tutorial.sh.NCEnd: dd 0
