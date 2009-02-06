[BITS 32]
[ORG 0x200000]
db "EX"
mov esi, zomgitworks
mov ah, 1
mov al, 0
mov bx, 7
int 30h
mov ah, 0
int 30h
zomgitworks db "Whooptie Dooptie in my Hooptie.",13,10,0