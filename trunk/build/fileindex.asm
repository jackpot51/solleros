diskfileindex:
db "argtest.elf",0
dd (f0-$$)/512
dd (f1-f0)/512
db "boot.sh",0
dd (f1-$$)/512
dd (f2-f1)/512
db "chartest.elf",0
dd (f2-$$)/512
dd (f3-f2)/512
db "dostest.com",0
dd (f3-$$)/512
dd (f4-f3)/512
db "execl",0
dd (f4-$$)/512
dd (f5-f4)/512
db "finalcount.snd",0
dd (f5-$$)/512
dd (f6-f5)/512
db "fork",0
dd (f6-$$)/512
dd (f7-f6)/512
db "helloworld.elf",0
dd (f7-$$)/512
dd (f8-f7)/512
db "int",0
dd (f8-$$)/512
dd (f9-f8)/512
db "lostwoods.snd",0
dd (f9-$$)/512
dd (f10-f9)/512
db "mario.snd",0
dd (f10-$$)/512
dd (f11-f10)/512
db "solleros.bmp",0
dd (f11-$$)/512
dd (f12-f11)/512
db "solleros.txt",0
dd (f12-$$)/512
dd (f13-f12)/512
db "songotime.snd",0
dd (f13-$$)/512
dd (f14-f13)/512
db "stdiotest.elf",0
dd (f14-$$)/512
dd (f15-f14)/512
db "tely",0
dd (f15-$$)/512
dd (f16-f15)/512
db "timetest.elf",0
dd (f16-$$)/512
dd (f17-f16)/512
db "tutorial.sh",0
dd (f17-$$)/512
dd (f18-f17)/512
db "unfs",0
dd (f18-$$)/512
dd (f19-f18)/512
db "victory.wav",0
dd (f19-$$)/512
dd (f20-f19)/512
db "_img.bin",0
dd (f20-$$)/512
dd (f21-f20)/512
enddiskfileindex:

