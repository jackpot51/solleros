diskfileindex:
db "dosprog",0
dd (f0-$$)/512
dd (f1-f0)/512
db "exp",0
dd (f1-$$)/512
dd (f2-f1)/512
db "fork",0
dd (f2-$$)/512
dd (f3-f2)/512
db "fpu",0
dd (f3-$$)/512
dd (f4-f3)/512
db "linux",0
dd (f4-$$)/512
dd (f5-f4)/512
db "solleros.bmp",0
dd (f5-$$)/512
dd (f6-f5)/512
db "solleros.txt",0
dd (f6-$$)/512
dd (f7-f6)/512
db "sound",0
dd (f7-$$)/512
dd (f8-f7)/512
db "tely",0
dd (f8-$$)/512
dd (f9-f8)/512
db "time",0
dd (f9-$$)/512
dd (f10-f9)/512
db "tutorial.bat",0
dd (f10-$$)/512
dd (f11-f10)/512
db "unfs",0
dd (f11-$$)/512
dd (f12-f11)/512
enddiskfileindex:

