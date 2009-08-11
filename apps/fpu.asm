;test the fpu-it should have already been initialized
%include "include.asm"
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
call print
jmp exit

bcdstr times 19 db 0
	   db 10,13,0	;one sign, 18 decimals, newline, one ending zero
bcdout times 10 db 0
bcdoutend:
bcd db 0x36, 0x55, 0x06, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80
real dt 2.8e1
