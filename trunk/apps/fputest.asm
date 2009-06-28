;test the fpu-it should have already been initialized
[BITS 32]
[ORG 0x400000]
db "EX"
fld tword [real]
fbld [bcd]
fadd st1
fbstp [bcdout]
mov esi, bcdoutend
dec esi
mov edi, bcdstr
mov ecx, 9
mov dh, 0
mov dl, [esi]
shr dl, 4
mov al, "+"
cmp dl, 8
jne nosign
mov al, "-"
nosign:
mov [edi], al
inc edi
dec esi
convertbcd:
mov dh, 0
mov dl, [esi]
shl dx, 4
shr dl, 4
mov ah, dl
add ah, 48
mov al, dh
add al, 48
mov [edi], ax
dec esi
add edi, 2
loop convertbcd
mov esi, bcdstr
mov al, 0
mov ah, 1
mov bl, 7
int 30h
mov ax, 0
int 30h

bcdstr times 20 db 0 ;one sign, 18 decimals, one ending zero
bcdout times 10 db 0
bcdoutend:
bcd db 0x36, 0x55, 0x06, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80
real dt 2.8e1
