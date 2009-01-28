diskfileindex:
db "solleros.bmp",0
dd (f0-$$)/512
dd (f1-f0)/512
db "solleros.txt",0
dd (f1-$$)/512
dd (f2-f1)/512
db "tutorial.bat",0
dd (f2-$$)/512
dd (f3-f2)/512
db "tely",0
dd (af0-$$)/512
dd (af1-af0)/512
db "time",0
dd (af1-$$)/512
dd (af2-af1)/512
enddiskfileindex:

align 512,db 0
f0:
incbin "included/solleros.bmp"
align 512,db 0
f1:
incbin "included/solleros.txt"
align 512,db 0
f2:
incbin "included/tutorial.bat"
align 512,db 0
f3:
af0:
%include "apps/tely.asm"
align 512,db 0
af1:
%include "apps/time.asm"
align 512,db 0
af2:
