diskfileindex:
db "exp",0
dd (f0-$$)/512
dd (f1-f0)/512
db "solleros.bmp",0
dd (f1-$$)/512
dd (f2-f1)/512
db "solleros.txt",0
dd (f2-$$)/512
dd (f3-f2)/512
db "tely",0
dd (f3-$$)/512
dd (f4-f3)/512
db "time",0
dd (f4-$$)/512
dd (f5-f4)/512
db "tutorial.bat",0
dd (f5-$$)/512
dd (f6-f5)/512
enddiskfileindex:

