diskfileindex:
db "solleros.bmp",0
dd (f0-$$)/512
dd (f1-f0)/512
db "solleros.txt",0
dd (f1-$$)/512
dd (f2-f1)/512
enddiskfileindex:

align 512,db 0
f0:
incbin "included\solleros.bmp"
align 512,db 0
f1:
incbin "included\solleros.txt"
align 512,db 0
f2:
